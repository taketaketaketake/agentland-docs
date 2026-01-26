# System Invariants

This document defines **non-negotiable invariants** of the system.

These invariants are architectural constraints that must hold regardless
of implementation details, agent behavior, model choice, or future
feature additions.

If a change violates one of these invariants, the change is incorrect
and must be revised or rejected.

---

## 1. 

---

## 2. 
---

## 3.
---

## 4. 
---

## 5. 
---

## 6. 
---

## 7. 

---

## 8. 
---

## 9. 

---

## 10. 

---

## 11. 

---

## 12.

---

## 13. 
---

## 14. 
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
- `skills/llm/phase-audit.md` (procedure)
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
