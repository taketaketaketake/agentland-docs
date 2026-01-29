#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const readline = require('readline');

const TEMPLATES_DIR = path.join(__dirname, '..', 'templates');
const COMMANDS = ['init', 'help'];

function printHelp() {
  console.log(`
spec-driven-docs - Documentation templates for spec-driven development

Usage:
  npx spec-driven-docs <command> [options]

Commands:
  init [--force]    Copy documentation templates to current directory
  help              Show this help message

Options:
  --force           Overwrite existing files without prompting
  --no-configure    Skip the interactive configuration walkthrough
`);
}

function ask(rl, question) {
  return new Promise((resolve) => {
    rl.question(question, (answer) => {
      resolve(answer.trim());
    });
  });
}

function replaceInFile(filePath, replacements) {
  if (!fs.existsSync(filePath)) return;
  let content = fs.readFileSync(filePath, 'utf8');
  for (const [search, replace] of replacements) {
    content = content.split(search).join(replace);
  }
  fs.writeFileSync(filePath, content, 'utf8');
}

async function configure() {
  const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
  });

  console.log('\n--- Project Configuration ---\n');
  console.log('Answer the following to customize your docs. Press Enter to skip any question.\n');

  const systemName = await ask(rl, '  What is your system/project name?\n  > ');
  const purpose = await ask(rl, '\n  What is the system\'s purpose? (one sentence)\n  > ');
  const layers = await ask(rl, '\n  What are your architectural layers? (comma-separated, e.g. "Postgres, Temporal, Redis")\n  > ');
  const boundary = await ask(rl, '\n  What is your sacred boundary rule? (e.g. "Execution code must not reason")\n  > ');
  const nonGoals = await ask(rl, '\n  What should this system NOT be? (comma-separated)\n  > ');

  rl.close();

  const visionPath = path.join(process.cwd(), 'docs', 'vision.md');
  const claudePath = path.join(process.cwd(), 'CLAUDE.md');

  const visionReplacements = [];
  const claudeReplacements = [];

  if (systemName) {
    visionReplacements.push(['**[describe your system]**', `**${systemName}**`]);
    claudeReplacements.push(['**[describe your system here]**', `**${systemName}**`]);
  }

  if (purpose) {
    visionReplacements.push(['The long-term objective is to [long-term goal].', `The long-term objective is to ${purpose}`]);
  }

  if (layers) {
    const items = layers.split(',').map(s => s.trim()).filter(Boolean);
    const mentalModel = items.map(item => `- ${item} = [role]`).join('\n');
    claudeReplacements.push(['- [Component] = [role]\n- [Component] = [role]\n- [Component] = [role]', mentalModel]);
  }

  if (boundary) {
    claudeReplacements.push(['- [boundary rule 1]\n   - [boundary rule 2]\n   - [boundary rule 3]', `- ${boundary}`]);
  }

  if (nonGoals) {
    const items = nonGoals.split(',').map(s => s.trim()).filter(Boolean);
    const nonGoalLines = items.map(item => `- ${item}`).join('\n');
    visionReplacements.push(
      ['- [Non-goal 1]\n- [Non-goal 2]\n- [Non-goal 3]\n- [Non-goal 4]', nonGoalLines]
    );
  }

  if (visionReplacements.length > 0) {
    replaceInFile(visionPath, visionReplacements);
    console.log('\n  Updated: docs/vision.md');
  }
  if (claudeReplacements.length > 0) {
    replaceInFile(claudePath, claudeReplacements);
    console.log('  Updated: CLAUDE.md');
  }

  if (visionReplacements.length === 0 && claudeReplacements.length === 0) {
    console.log('\n  No changes made. You can edit the files manually.');
  }
}

function copyRecursive(src, dest, force = false) {
  const stats = fs.statSync(src);

  if (stats.isDirectory()) {
    if (!fs.existsSync(dest)) {
      fs.mkdirSync(dest, { recursive: true });
    }

    const entries = fs.readdirSync(src);
    for (const entry of entries) {
      copyRecursive(
        path.join(src, entry),
        path.join(dest, entry),
        force
      );
    }
  } else {
    if (fs.existsSync(dest) && !force) {
      console.log(`  SKIP: ${path.relative(process.cwd(), dest)} (already exists, use --force to overwrite)`);
      return;
    }

    // Ensure parent directory exists
    const parentDir = path.dirname(dest);
    if (!fs.existsSync(parentDir)) {
      fs.mkdirSync(parentDir, { recursive: true });
    }

    fs.copyFileSync(src, dest);
    console.log(`  COPY: ${path.relative(process.cwd(), dest)}`);
  }
}

async function init(force = false, skipConfigure = false) {
  console.log('\nInitializing spec-driven documentation...\n');

  if (!fs.existsSync(TEMPLATES_DIR)) {
    console.error('Error: Templates directory not found. Package may be corrupted.');
    process.exit(1);
  }

  const entries = fs.readdirSync(TEMPLATES_DIR);

  for (const entry of entries) {
    const srcPath = path.join(TEMPLATES_DIR, entry);
    const destPath = path.join(process.cwd(), entry);
    copyRecursive(srcPath, destPath, force);
  }

  console.log('\nDone! Documentation templates have been added to your project.');

  if (skipConfigure) {
    console.log('\nCustomize your docs by editing:');
    console.log('  1. CLAUDE.md');
    console.log('  2. docs/vision.md');
    console.log('  3. implementation-plan.md');
    console.log('');
    return;
  }

  const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
  });

  const answer = await ask(rl, '\nWould you like to configure your project now? (Y/n) ');
  rl.close();

  if (answer === '' || answer.toLowerCase() === 'y' || answer.toLowerCase() === 'yes') {
    await configure();
    console.log('\nSetup complete! Review and refine your docs as needed.\n');
  } else {
    console.log('\nYou can customize the files manually later.');
    console.log('Key files to edit:');
    console.log('  1. CLAUDE.md');
    console.log('  2. docs/vision.md');
    console.log('  3. implementation-plan.md');
    console.log('');
  }
}

// Parse arguments
const args = process.argv.slice(2);
const command = args[0];
const force = args.includes('--force');
const skipConfigure = args.includes('--no-configure');

if (!command || command === 'help' || command === '--help' || command === '-h') {
  printHelp();
  process.exit(0);
}

if (command === 'init') {
  init(force, skipConfigure).catch((err) => {
    console.error('Error:', err.message);
    process.exit(1);
  });
} else {
  console.error(`Unknown command: ${command}`);
  console.error('Run "spec-driven-docs help" for usage information.');
  process.exit(1);
}
