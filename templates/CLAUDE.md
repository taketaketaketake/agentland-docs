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

This repository implements a **[describe your system here]**.

It is:
- [characteristic 1]
- [characteristic 2]
- [characteristic 3]

It is **not**:
- [non-goal 1]
- [non-goal 2]
- [non-goal 3]

---

## How to Think About the System

Use this mental model:

- [Component] = [role]
- [Component] = [role]
- [Component] = [role]

Never collapse these layers.

---

## Rules You Must Follow

1. **Do not introduce business logic**
   - This repo provides infrastructure only unless explicitly instructed.

2. **Do not invent agents, prompts, or workflows**
   - Only implement what is specified in the current phase or PRD.

3. **Respect architectural boundaries**
   - [boundary rule 1]
   - [boundary rule 2]
   - [boundary rule 3]

4. **Prefer explicit structure over clever abstractions**
   - Boring, readable code is preferred.
   - Avoid meta-programming and hidden control flow.

5. **If unsure, stop and ask**
   - Do not guess intent.
   - List assumptions and wait for confirmation.

6. **Always use best practices**
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
(See `docs/invariants.md`)

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

The source of truth for required documentation updates is:
`docs/glossary/markdown-glossary.md` → Update Triggers

---

## How to Use Existing Documentation

- `docs/vision.md` defines long-term intent.
- `docs/architecture.md` defines structural reality.
- `docs/invariants.md` defines non-negotiable constraints.
- `docs/decisions/` contains rationale for past decisions.
