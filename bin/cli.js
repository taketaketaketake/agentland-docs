#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

const TEMPLATES_DIR = path.join(__dirname, '..', 'templates');
const COMMANDS = ['init', 'help'];

function printHelp() {
  console.log(`
agentland-docs - Documentation templates for spec-driven development

Usage:
  npx agentland-docs <command> [options]

Commands:
  init [--force]    Copy documentation templates to current directory
  help              Show this help message

Options:
  --force           Overwrite existing files without prompting

Examples:
  npx agentland-docs init
  npx agentland-docs init --force
`);
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

function init(force = false) {
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
  console.log('\nNext steps:');
  console.log('  1. Review and customize CLAUDE.md for your project');
  console.log('  2. Fill in docs/vision.md with your system intent');
  console.log('  3. Update implementation-plan.md with your phases');
  console.log('');
}

// Parse arguments
const args = process.argv.slice(2);
const command = args[0];
const force = args.includes('--force');

if (!command || command === 'help' || command === '--help' || command === '-h') {
  printHelp();
  process.exit(0);
}

if (command === 'init') {
  init(force);
} else {
  console.error(`Unknown command: ${command}`);
  console.error('Run "spec-driven-docs help" for usage information.');
  process.exit(1);
}
