# System Invariants

This document defines **non-negotiable invariants** of the system.

These invariants are architectural constraints that must hold regardless
of implementation details, agent behavior, model choice, or future
feature additions.

If a change violates one of these invariants, the change is incorrect
and must be revised or rejected.

---

## 1. [Invariant Name]

[Description of what must always be true]

---

## 2. [Invariant Name]

[Description of what must always be true]

---

## 3. [Invariant Name]

[Description of what must always be true]

---

## Phase Completion Requires Passing Audit

**No phase may transition to COMPLETE without a passing phase audit.**

The mandatory sequence is:

| Step | Required |
|------|----------|
| Implementation | Yes |
| Validation scripts pass | Yes |
| Phase audit invoked | Yes |
| ADR created and valid | Yes |
| Glossary triggers satisfied | Yes |
| Audit verdict: PASS | Yes |
| Only then mark COMPLETE | Yes |

This invariant is enforced by:
- `skills/llm/phase-audit.md` (procedure)
- `CLAUDE.md` Phase Completion Protocol (behavioral rule)

---

## Phase Completion Requires Validation

**A phase MUST NOT be marked COMPLETE unless its corresponding validation script has been executed successfully.**

Rules:
- Every phase that introduces or modifies executable behavior MUST have a validation script.
- Validation scripts MUST be run before phase status is marked COMPLETE.
- A passing test suite is insufficient without phase-scoped validation.

Violation of this invariant invalidates phase completion.
