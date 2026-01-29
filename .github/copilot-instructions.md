# GitHub Copilot Instructions

This file provides instructions for GitHub Copilot coding agent when working in this repository.

---

## Repository Purpose

This is a **documentation template repository** for spec-driven development of AI-native systems.

**What this repository is:**
- Templates for building AI-native control planes
- Contracts that define how LLMs should reason about systems
- Governance structures for agent-based architectures
- Infrastructure-first, governance-driven documentation

**What this repository is NOT:**
- A business application
- An agent demo or prompt playground
- A replacement for production code
- A place to add business logic or project-specific agents

---

## Development Philosophy

### Core Principles

1. **Specification-First Development**
   - Specifications are written first
   - LLMs implement against those specs
   - Governance ensures compliance
   - Documentation stays synchronized with reality

2. **Infrastructure Only**
   - This repo provides infrastructure templates only
   - Do not introduce business logic unless explicitly instructed
   - Do not invent agents, prompts, or workflows
   - Only implement what is specified in the current phase or PRD

3. **Explicit Structure Over Abstractions**
   - Boring, readable code is preferred
   - Avoid meta-programming and hidden control flow
   - Keep things simple and maintainable

4. **Minimal Changes**
   - Make absolutely minimal modifications
   - Change as few lines as possible to achieve goals
   - Ignore unrelated bugs or broken tests
   - Never delete/remove/modify working files unless absolutely necessary

---

## Working with Phases

**Important:** This repository uses a phase-based development approach.

### Phase Rules

When implementing a phase:
- Implement only the stated goals
- Do not "prepare" for future phases
- Do not refactor unrelated code
- Stop when the phase is complete

Each phase should result in:
- Working infrastructure
- Minimal scope
- Clear validation steps

### Phase Completion Protocol (MANDATORY)

**No phase may transition to COMPLETE without a passing phase audit.**

Before marking a phase complete, you MUST:

1. Invoke the `phase_audit` skill (`skills/llm/phase-audit.md`)
2. Provide all required inputs:
   - `phase_number`: The phase being completed
   - `phase_description`: What the phase accomplished
   - `changes_made`: All infrastructure, schema, or component changes
3. Wait for the audit verdict
4. Act on the verdict:
   - If `PASS`: Proceed with marking the phase complete
   - If `FAIL`: Stop. Complete all remediation actions first.

**Hard Gate Enforcement:**
- The audit must be RUN — not just passed
- You must refuse to proceed if the audit returns FAIL
- You must refuse to mark complete if the audit was not run

This ensures documentation stays synchronized with changes.

---

## Key Documentation Files

Always reference these files when working in this repository:

### Primary Context Files
- **`CLAUDE.md`**: Persistent, high-signal context for LLMs - READ THIS FIRST
- **`README.md`**: Repository overview and entry point
- **`docs/vision.md`**: Long-term intent and system philosophy
- **`docs/architecture.md`**: Structural reality
- **`docs/invariants.md`**: Non-negotiable constraints (especially §15 and §16)
- **`implementation-plan.md`**: Phase tracking and status

### Governance Files
- **`docs/glossary/markdown-glossary.md`**: Authoritative source for update triggers and documentation contracts
- **`skills/llm/phase-audit.md`**: Phase completion audit procedure
- **`docs/decisions/`**: Architecture Decision Records (ADRs)

### Reference Files
- **`docs/markdown-map.md`**: Documentation relationship analysis
- **`docs/contracts.md`**: System contracts
- **`docs/stubs.md`**: Stub registry
- **`docs/artifacts.md`**: Artifact definitions

---

## Files and Directories to NEVER Modify

Do not modify these files unless explicitly instructed:

- `.github/copilot-instructions.md` (this file)
- `docs/glossary/markdown-glossary.md` (only updated per its own triggers)
- `CLAUDE.md` (rare, deliberate updates only)
- `docs/invariants.md` (system-level changes only)
- Any files in `docs/audits/` (generated reports, read-only)

---

## Commands and Tools

### Git Commands

Always use these patterns:
```bash
# Check status and diff together
git --no-pager status && git --no-pager diff

# View specific commits
git --no-pager show <commit> -- <file>

# Always disable pagers to avoid interactive output issues
git --no-pager <command>
```

**Important:** Do not use `git` directly to commit, push, or update PRs. Use the `report_progress` tool instead.

### Testing and Validation

Currently, this is a documentation repository with no code to test. If testing infrastructure is added in the future:

- Run linters, builds, and tests that already exist
- Do not add new testing tools unless necessary
- Always validate changes against existing infrastructure

---

## Code Style and Conventions

### Documentation Style

- Use clear, precise language
- Prefer explicit structure over clever abstractions
- Match the style of existing documentation
- Keep documentation synchronized with reality

### Markdown Conventions

- Use proper heading hierarchy (# → ## → ###)
- Include horizontal rules (---) to separate major sections
- Use code blocks with language identifiers
- Keep line lengths reasonable for readability
- Use tables for structured data

### Commit Messages

- Use clear, descriptive commit messages
- Follow conventional commit format when appropriate
- Describe what changed and why, not how

---

## Multi-LLM Support

**Important:** Do not assume a single LLM.

All designs must support multiple models with differing capabilities:
- Postgres = truth
- Directives = frozen intent
- Temporal = coordination and durability
- Execution modules = bounded action
- Agents = replaceable reasoning components
- Memory = external, inspectable, persistent

Never collapse these layers.

---

## Architectural Boundaries

**Sacred Rule:** Respect these boundaries at all times:

- **Execution code must not reason**
- **Cognition must not execute**
- **Temporal must not decide**

These are fundamental separation of concerns.

---

## When You're Unsure

**If unsure, stop and ask.**

Do not guess intent. List assumptions and wait for confirmation.

This repository values correctness over speed, and clarity over cleverness.

---

## Getting Help

1. Read `CLAUDE.md` first — it contains persistent context
2. Check `docs/glossary/markdown-glossary.md` for file responsibilities
3. Review `docs/invariants.md` for constraints
4. Consult `implementation-plan.md` for current phase context
5. Ask the user if still unclear

---

## Summary: Top Rules for Success

1. ✅ Read `CLAUDE.md` before starting any work
2. ✅ Make minimal, surgical changes only
3. ✅ Follow the phase completion protocol exactly (§15 invariant)
4. ✅ Never modify documentation governance files without explicit instruction
5. ✅ Respect architectural boundaries (no mixing of layers)
6. ✅ Use `report_progress` tool for commits, not git directly
7. ✅ Stop and ask if unsure rather than guessing
8. ✅ Keep documentation synchronized with reality
9. ✅ Support multiple LLMs, not just one
10. ✅ Prefer boring, explicit code over clever abstractions

---

**Remember:** This is infrastructure for governance-driven, spec-first development. Every file has a purpose. Every change should be deliberate and minimal.
