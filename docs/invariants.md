# System Invariants

This document defines **non-negotiable invariants** of the system.

These invariants are architectural constraints that must hold regardless
of implementation details, agent behavior, model choice, or future
feature additions.

If a change violates one of these invariants, the change is incorrect
and must be revised or rejected.

---

## 1. Separation of Cognition and Execution

- Cognition (decision-making) must never directly execute actions.
- Execution modules must never make strategic or evaluative decisions.
- All execution occurs only in response to approved Directives.

This separation exists to ensure:
- auditability
- safety
- replaceability of reasoning components

---

## 2. Directives Are the Only Execution Interface

- All intent to act is expressed as a Directive.
- Directives are immutable once approved.
- Execution workflows operate only on approved Directives.

No execution module may:
- infer intent
- reinterpret goals
- bypass Directive constraints

---

## 3. Policy and Approval Are Mandatory Gates

- Every Directive must pass through policy evaluation.
- Policy enforcement is deterministic and external to LLM reasoning.
- Approval status is explicit and persisted.

There are no implicit approvals.

---

## 4. Temporal Orchestrates, It Does Not Decide

- Temporal is responsible for coordination, durability, retries, and
  scheduling.
- Temporal workflows do not perform reasoning.
- LLMs do not control Temporal directly.

Temporal workflow state may be used as **durable short-term memory**, but
never as a source of business truth.

---

## 5. Postgres Is the System of Record

- All authoritative state lives in Postgres.
- If something is not persisted, it did not happen.
- LLM outputs are not considered truth until persisted.

Postgres is the source of truth for:
- Directives
- Execution state
- Agent role bindings
- Metrics and evaluations
- Memory indexes and artifact references

---

## 6. Memory Is External and Inspectable

- Agents do not own memory.
- Memory is stored externally and referenced.
- Memory survives agent replacement.

This enables:
- auditability
- evaluation
- replacement without loss of context

---

## 7. Artifacts Are Immutable Evidence

- Artifacts are immutable outputs of execution.
- Artifacts are stored externally (e.g., object storage).
- Artifacts are referenced, not embedded.

Artifacts serve as evidence for:
- evaluation
- auditing
- historical analysis

---

## 8. Roles Persist, Implementations Are Replaceable

- Agents are implementations of roles.
- Roles persist even when implementations change.
- Replacement operates at the role-binding level.

No workflow or policy may depend on a specific agent implementation.

---

## 9. Model Choice Is an Implementation Detail

- No invariant assumes a specific LLM.
- Prompts, roles, and contracts are model-agnostic.
- Evaluation is outcome-based, not stylistic.

---

## 10. Explicit Over Implicit

- Intent must be explicit.
- Boundaries must be explicit.
- Rationale must be explicit.

Implicit assumptions are architectural debt.

---

## 11. Infrastructure Readiness Coordination

Infrastructure services must coordinate on readiness, not container startup.

---

## 12. Policy Evaluation Is Deterministic

Policy evaluation must be deterministic given the same directive state and
policy version.

- No heuristics
- No LLM calls
- No external state beyond the directive itself

Given:
- The same directive data (type, scope, budget, etc.)
- The same PolicyConfig version

The policy engine MUST produce identical results every time.

This enables:
- Reproducible auditing
- Testable policy behavior
- Predictable system behavior

---

## 13. LLM Usage Is Explicit, Observable, and Opt-In

- LLM calls must be explicit (no implicit or hidden calls).
- LLM calls must be observable (traces, logs, artifacts emitted).
- LLM usage is opt-in via configuration (NoOp default blocks usage).

This ensures:
- No accidental LLM calls during infrastructure phases
- All LLM interactions are auditable
- Intelligence can be enabled with a single configuration change
- Cost and usage are trackable from day one

---

## 14. Memory Is Readable Only Through Named, Read-Only Interfaces

- Memory is readable only through explicit, named, read-only interfaces.
- No component may query storage directly.
- All memory access is bounded (hard limits on result counts).
- Embeddings are never exposed; only similarity scores.

This ensures:
- Clean separation between storage and consumption
- Auditable memory access patterns
- No coupling between agents and storage implementation
- Memory backends can be replaced without affecting consumers

---

## 15. Phase Completion Requires Passing Audit

**No phase may transition to COMPLETE without a passing phase audit.**

The mandatory sequence is:

| Step | Required |
|------|----------|
| Implementation | ✅ |
| Validation scripts pass | ✅ |
| Phase audit invoked | ✅ |
| ADR created and valid | ✅ |
| Glossary triggers satisfied | ✅ |
| Stubs registry updated | ✅ |
| Audit verdict: PASS | ✅ |
| Only then mark COMPLETE | ✅ |

This invariant is enforced by:
- `skills/claude/phase-audit.md` (procedure)
- `CLAUDE.md` Phase Completion Protocol (behavioral rule)

Violations of this invariant cause:
- Documentation drift (files not updated)
- Missing ADRs (decisions not recorded)
- Stale stubs registry (replaced stubs not marked)
- Audit debt that compounds over phases

**The audit must be RUN, not just PASSED.**

Claude must refuse to:
- Mark a phase complete without running the audit
- Proceed after a FAIL verdict without remediation
- Skip the audit even if "confident" the phase is correct

This ensures near-zero documentation drift and maintains the system's self-describing property.

---

## 16. Phase Completion Requires Validation

**A phase MUST NOT be marked COMPLETE unless its corresponding validation script has been executed successfully.**

Rules:
- Every phase that introduces or modifies executable behavior MUST have a validation script.
- Validation scripts MUST be run before:
  - `implementation-plan.md` is updated
  - `README.md` is updated
  - Phase status is marked COMPLETE
- A passing test suite is insufficient without phase-scoped validation.

Violation of this invariant invalidates phase completion.
