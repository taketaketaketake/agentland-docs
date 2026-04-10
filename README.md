# Spec-Driven Development Template

Documentation templates for **spec-driven development** of AI-native systems.

## What This Is

This repository contains structured documentation that serves as:

- **Templates** for building AI-native control planes
- **Contracts** that define how LLMs should reason about systems
- **Governance structures** for agent-based architectures

Particularly useful for teams building agentic systems where governance, auditability, and clear boundaries matter.

## Documentation Relationship Map

```
                                    ┌─────────────────────────┐
                                    │  markdown-glossary.md   │
                                    │  (Central Hub)          │
                                    │  Authoritative source   │
                                    │  for update triggers    │
                                    └───────────┬─────────────┘
                                                │
                    ┌───────────────────────────┼──────────────────────────┐
                    │                           │                          │
        ┌───────────▼───────────┐   ┌───────────▼──────────┐   ┌──────────▼─────────┐
        │     README.md         │   │   CLAUDE.md          │   │ plan-template.md   │
        │                       │   │                      │   │                    │
        │  - Entry point        │   │  - AI instructions   │   │                    │
        │  - Overview           │   │  - Phase protocol    │   │  - Phase tracking  │
        └───────────────────────┘   └──────────┬───────────┘   └─────────┬──────────┘
                                               │                          │
                                    ┌──────────▼──────────┐              │
                                    │   vision.md         │              │
                                    │   architecture.md   │              │
                                    │   invariants.md     │              │
                                    │   models.md         │              │
                                    └─────────────────────┘              │
                                                                         │
        ┌────────────────────────────────────────────────────────────────┘
        │
        │         ┌─────────────────────────┐           ┌──────────────────────────┐
        └────────►│  phase-audit.md         │──────────►│  phase-NN-audit.md      │
                  │  (Skill/Enforcement)    │  creates  │  (Generated reports)     │
                  │                         │           │                          │
                  └────┬────────────────────┘           └──────────────────────────┘
                       │
                       │ validates
                       │
                  ┌────▼────────────────────┐
                  │  adr-template.md        │
                  │                         │
                  └─────────────────────────┘
                       │
                       │ used by
                       │
                  ┌────▼────────────────────┐
                  │  adr-001-*.md           │
                  │  (Actual ADRs)          │
                  └─────────────────────────┘


        ┌─────────────────────────┐           ┌──────────────────────────┐
        │  codebase-health.md     │──────────►│  health-log.md          │
        │  (Skill/Monitoring)     │  appends  │  (Health reports)        │
        │                         │           │                          │
        └─────────────────────────┘           └──────────────────────────┘


        ┌─────────────────────────┐
        │  stubs.md               │
        │  artifacts.md           │◄──────── Referenced by phase-audit.md
        │  contracts.md           │          (Retrospective checks)
        │  glossary.md            │
        └─────────────────────────┘
```

See [docs/markdown-map.md](docs/markdown-map.md) for the full relationship analysis.

## Repository Structure

```
.
├── .claude/                    # Claude Code configuration
│   ├── settings.json           # Hook wiring (SessionStart, PostToolUse, PreToolUse)
│   ├── settings.local.json     # Local Claude settings (gitignored)
│   ├── hooks/                  # Claude Code hooks (enforcement)
│   │   ├── session-context.sh  # Loads glossary routing table on session start
│   │   ├── check-doc-triggers.sh  # Warns after source edits if docs need updating
│   │   └── pre-commit-docs.sh # Blocks commits if docs are incomplete
│   └── skills/                 # LLM-enforced procedures (Claude Code convention)
│       ├── codebase-health/    # Skill for monitoring codebase health
│       │   └── SKILL.md        # Skill entrypoint with frontmatter
│       └── phase-audit/        # Skill for enforcing phase completion protocol
│           └── SKILL.md        # Skill entrypoint with frontmatter
│
├── .github/                    # GitHub-specific configurations
│   └── workflows/              # GitHub Actions workflows
│       └── audit-check.yml     # Automated audit validation
│
├── CLAUDE.md                   # AI assistant persistent context and rules
├── README.md                   # This file - repository overview
├── docs/plan/plan-template.md      # Phase tracking and implementation roadmap
│
├── docs/                       # Authoritative documentation templates
│   ├── architecture.md         # System architecture specification
│   ├── artifacts.md            # Artifact definitions and contracts
│   ├── contracts.md            # System contracts and interfaces
│   ├── health-log.md           # Codebase health monitoring log
│   ├── invariants.md           # Non-negotiable system constraints
│   ├── markdown-map.md         # Documentation relationship analysis
│   ├── models.md               # Data models and schemas
│   ├── stubs.md                # Stub definitions for development
│   ├── vision.md               # System philosophy and long-term goals
│   │
│   ├── audits/                 # Phase audit reports (generated per phase)
│   │
│   ├── decisions/              # Architecture Decision Records (ADRs)
│   │   └── adr-template.md     # Template for creating new ADRs
│   │
│   └── glossary/               # Term and file contracts
│       ├── glossary.md         # System terminology definitions
│       └── markdown-glossary.md # Central hub: authoritative source for update triggers
│
└── scripts/                    # Automation scripts
    └── hooks/                  # Git hooks for enforcement
        ├── README.md           # Git hooks documentation
        ├── commit-msg          # Commit message validation hook
        └── pre-commit          # Pre-commit validation hook
```

## Enforcement

The framework includes three layers of enforcement that prevent LLMs from ignoring documentation:

### Claude Code Hooks (automatic)

Shipped via `npx spec-driven-docs init`. No setup required.

| Hook | Event | Behavior |
|------|-------|----------|
| `session-context.sh` | SessionStart | Loads the glossary routing table into Claude's context so it knows which docs to update |
| `check-doc-triggers.sh` | PostToolUse (Edit/Write) | After any source file edit, warns Claude if glossary-triggered docs weren't updated |
| `pre-commit-docs.sh` | PreToolUse (git commit) | **Blocks commits** if: phase marked COMPLETE without audit file, stubs exist without registry entry, or interface files changed without contracts.md update |

### Claude Code Skills (LLM-enforced)

| Skill | Trigger | Behavior |
|-------|---------|----------|
| `phase-audit` | Before marking any phase COMPLETE | Verifies documentation updates, ADRs, and validation scripts. Hard gate. |
| `codebase-health` | On demand (`/codebase-health`) | Structured assessment appended to health-log.md |

### Git Hooks (local)

| Hook | Behavior |
|------|----------|
| `pre-commit` | Blocks commits containing AI co-authorship attributions in staged files |
| `commit-msg` | Blocks commits containing AI co-authorship attributions in commit messages |

## Purpose

Each file in this repository is designed to become a reusable template for spec-driven development workflows where:

1. Specifications are written first
2. LLMs implement against those specs
3. Governance ensures compliance
4. Documentation stays synchronized with reality

## Quick Start

```bash
npx spec-driven-docs init
```

This copies all documentation templates into your current project directory. Use `--force` to overwrite existing files.

Then:
1. Customize `CLAUDE.md` for your project
2. Fill in `docs/vision.md` with your system intent
3. Update `docs/plan/plan-template.md` with your phases

## Learn More

See [docs/vision.md](docs/vision.md) for the system philosophy.

See [docs/glossary/markdown-glossary.md](docs/glossary/markdown-glossary.md) for file-level contracts.
