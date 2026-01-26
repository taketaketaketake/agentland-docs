@docs/vision.md
@README.md
@docs/glossary/markdown-glossary.md

# CLAUDE.md

This file provides **persistent, high-signal context** for Claude when
working in this repository.

It defines how you should reason, what assumptions you must not make,
and how to interact with the system.

---

## What This Repository Is

This repository implements a **control-plane architecture** for an
LLM-enabled management and execution system.

It is:
- infrastructure-first
- governance-driven
- designed for long-lived evolution

It is **not**:
- a business application
- an agent demo
- a prompt playground
- a replacement for production code

---

## How to Think About the System

Use this mental model:

- Postgres = truth
- Directives = frozen intent
- Temporal = coordination and durability
- Execution modules = bounded action
- Agents = replaceable reasoning components
- Memory = external, inspectable, persistent

Never collapse these layers.

---

## Rules You Must Follow

1. **Do not introduce business logic**
   - This repo provides infrastructure only unless explicitly instructed.

2. **Do not invent agents, prompts, or workflows**
   - Only implement what is specified in the current phase or PRD.

3. **Respect architectural boundaries**
   - Execution code must not reason.
   - Cognition must not execute.
   - Temporal must not decide.

4. **Prefer explicit structure over clever abstractions**
   - Boring, readable code is preferred.
   - Avoid meta-programming and hidden control flow.

5. **Do not assume a single LLM**
   - All designs must support multiple models with differing capabilities.

6. **If unsure, stop and ask**
   - Do not guess intent.
   - List assumptions and wait for confirmation.

7. **Always use best practices**
   - Do not take shortcuts simply because shortcuts are convenient. Identify root cause and address the core issue.
---

## How to Work in Phases

When implementing a phase:
- Implement only the stated goals.
- Do not "prepare" for future phases.
- Do not refactor unrelated code.
- Stop when the phase is complete.

Each phase should result in:
- working infrastructure
- minimal scope
- clear validation steps

---

## Phase Completion Protocol (Mandatory)

**This rule is non-negotiable and must be followed exactly.**

**Invariant:** No phase may transition to COMPLETE without a passing phase audit.
(See `docs/invariants.md` §15)

Before ANY of the following:
- Marking a phase as COMPLETE
- Claiming a phase is complete
- Being asked to mark a phase complete
- Updating `implementation-plan.md` to indicate phase completion

Claude MUST:

1. **Invoke the `phase_audit` skill** (`skills/llm/phase-audit.md`)
2. **Provide all required inputs:**
   - `phase_number`: The phase being completed
   - `phase_description`: What the phase accomplished
   - `changes_made`: All infrastructure, schema, or component changes
3. **Wait for the audit verdict**
4. **Act on the verdict:**
   - If `PASS`: Proceed with marking the phase complete
   - If `FAIL`: Stop. Do not mark the phase complete. Complete all remediation actions listed in the audit report first.

**Hard Gate Enforcement:**

- **The audit must be RUN** — not just passed. Skipping the audit is a violation.
- **Claude must refuse to proceed** if the audit returns FAIL.
- **Claude must refuse to mark complete** if the audit was not run.
- **If a phase audit passes**, execution is mandatory unless explicitly blocked.

This is not a suggestion. This is a hard gate.

This protocol exists because:
- Documentation correctness is a first-class invariant
- The glossary defines what must be updated
- Human memory is not reliable; enforcement must be automatic
- A phase is not complete until its documentation is complete
- Skipping audits causes compounding documentation drift

The source of truth for required documentation updates is:
`docs/glossary/markdown-glossary.md` → Update Triggers

---

## How to Use Existing Documentation

- `docs/vision.md` defines long-term intent.
- `docs/architecture.md` defines structural reality.
- `docs/invariants.md` defines non-negotiable constraints.
- `docs/decisions/` contains rationale for past decisions.
- `ai/design-time/` contains rules for LLM collaborators.
- `ai/runtime/` contains agent contracts and role definitions.
