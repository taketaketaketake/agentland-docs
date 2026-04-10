# Spec-Driven Development Template

A documentation framework that keeps docs in sync with code during LLM-assisted development.

## The Problem

LLMs are fast at writing code but terrible at maintaining documentation. Docs drift within hours. By the end of a build phase, your README describes a system that no longer exists. This framework treats documentation as enforceable contracts — when code changes, the system knows which docs need updating and blocks progress until they're current.

## Quick Start

### 1. Install the templates

```bash
npx spec-driven-docs init
```

This copies all documentation templates, hooks, and skills into your project. Use `--force` to overwrite existing files.

### 2. Tell the LLM about your project

Open Claude Code (or your LLM of choice) in the project directory and prompt it to fill out the docs. For example:

> "Read the documentation templates in this repo. Fill out CLAUDE.md, vision.md, and plan-template.md based on what this project does. Delete any docs that aren't relevant."

The LLM reads your codebase, fills in the templates with project-specific content, and removes what doesn't apply.

### 3. Delete what you don't need

Not every project needs every file. A simple CLI tool doesn't need `artifacts.md` or `contracts.md`. A data pipeline might not need `stubs.md`. **Delete freely** — the glossary and hooks adapt to what's present.

The only files that should always exist:
- `CLAUDE.md` — LLM instructions for your project
- `docs/glossary/markdown-glossary.md` — the routing table that drives enforcement
- `docs/plan/plan-template.md` — phase tracking

Everything else is opt-in.

### 4. Work in phases

From here, work normally. The hooks and skills enforce documentation stays in sync as you build:
- Edit source code → hooks warn if docs need updating
- Complete a phase → phase-audit skill verifies everything before marking done
- Commit → pre-commit hook blocks if docs are incomplete

## What You Get

- **CLAUDE.md** — persistent LLM context and rules
- **vision.md** — system intent and principles
- **architecture.md** — structural overview
- **invariants.md** — non-negotiable constraints
- **models.md** — data model definitions
- **contracts.md** — interface completeness tracking
- **stubs.md** — stub registry
- **artifacts.md** — artifact type registry
- **plan-template.md** — phase tracking
- **glossary.md** — term definitions
- **markdown-glossary.md** — the central routing table that drives everything
- **adr-template.md** — architecture decision record template
- **health-log.md** — codebase health assessment log

## Enforcement

The framework includes three layers of enforcement that prevent LLMs from ignoring documentation:

### Claude Code Hook (automatic)

Shipped via `npx spec-driven-docs init`. No setup required.

| Hook | Event | Behavior |
|------|-------|----------|
| `session-context.sh` | SessionStart | Loads the glossary routing table into Claude's context so it knows which docs to update |

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

## Learn More

- [docs/glossary/markdown-glossary.md](docs/glossary/markdown-glossary.md) — file-level contracts and the routing table that drives enforcement
- [docs/markdown-map.md](docs/markdown-map.md) — full documentation relationship analysis
