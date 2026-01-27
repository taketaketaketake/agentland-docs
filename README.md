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
docs/           # Authoritative documentation templates
  architecture.md
  invariants.md
  models.md
  vision.md
  glossary/     # Term and file contracts
  decisions/    # ADR templates

skills/         # LLM-enforced procedures
  llm/          # LLM-specific skills

ai/             # AI context (design-time and runtime)
  design-time/  # Static reasoning context
  runtime/      # Operational contracts
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
