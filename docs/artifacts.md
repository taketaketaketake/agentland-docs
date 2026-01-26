# Artifact Taxonomy

> ⚠️ **This document is NOT an implementation plan.**
> It does not authorize code changes or execution.
> All implementation requires an approved entry in `implementation-plan.md`.

This document is the **authoritative registry** of all artifact types in the system.

Every artifact type must have:
- A defined producer (what creates it)
- A lifecycle phase (when it's created)
- A schema (what fields it contains)
- Retention expectations

**No new artifact type may be introduced without an entry here.**

---

## Policy Artifacts

### policy_evaluation

| | |
|---|---|
| **Producer** | `store_policy_artifact` activity |
| **Lifecycle Phase** | Phase 5 (Policy & Approval Gate) |
| **Created When** | A directive is evaluated against policy |
| **Schema** | `directive_id`, `policy_version`, `results[]`, `verdict`, `timestamp` |
| **Retention** | Permanent (audit trail) |

---

## Adding New Artifact Types

When introducing a new artifact type:

1. Add an entry to this document with all required fields
2. Implement the producer to emit the artifact
3. Ensure the artifact is emitted within a traced span
4. Update `scripts/validate_artifacts.py` to check for the new type (if validation exists)
5. Reference the artifact type in the relevant ADR

---

## Summary

| Category | Artifact Types | Count |
|----------|---------------|-------|
| Policy | policy_evaluation | 1 |
| Execution | execution_start, execution_checkpoint, execution_end | 3 |
| Module | module_execution, noop_executed, echo_result, intentional_failure | 4 |
| LLM | llm_call, llm_usage | 2 |
| Memory | memory_read_attempt | 1 |
| **Total** | | **11** |
