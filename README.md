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
        │     README.md         │   │   CLAUDE.md          │   │ implementation-    │
        │                       │   │                      │   │ plan.md            │
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
├── .claude/                    # Claude Code Editor configuration
│   └── settings.local.json     # Local Claude settings
│
├── .github/                    # GitHub-specific configurations
│   └── workflows/              # GitHub Actions workflows
│       └── audit-check.yml     # Automated audit validation
│
├── CLAUDE.md                   # AI assistant persistent context and rules
├── README.md                   # This file - repository overview
├── implementation-plan.md      # Phase tracking and implementation roadmap
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
│   ├── audits/                 # Phase audit reports
│   │   └── phase-01-audit.md   # Generated audit reports for phases
│   │
│   ├── decisions/              # Architecture Decision Records (ADRs)
│   │   └── adr-template.md     # Template for creating new ADRs
│   │
│   └── glossary/               # Term and file contracts
│       ├── glossary.md         # System terminology definitions
│       └── markdown-glossary.md # Central hub: authoritative source for update triggers
│
├── scripts/                    # Automation scripts
│   └── hooks/                  # Git hooks for enforcement
│       ├── README.md           # Git hooks documentation
│       ├── commit-msg          # Commit message validation hook
│       └── pre-commit          # Pre-commit validation hook
│
└── skills/                     # LLM-enforced procedures and skills
    └── llm/                    # LLM-specific skills and capabilities
        ├── codebase-health.md  # Skill for monitoring codebase health
        └── phase-audit.md      # Skill for enforcing phase completion protocol
```

## Purpose

Each file in this repository is designed to become a reusable template for spec-driven development workflows where:

1. Specifications are written first
2. LLMs implement against those specs
3. Governance ensures compliance
4. Documentation stays synchronized with reality

## Getting Started

See [docs/vision.md](docs/vision.md) for the system philosophy.

See [docs/glossary/markdown-glossary.md](docs/glossary/markdown-glossary.md) for file-level contracts.
