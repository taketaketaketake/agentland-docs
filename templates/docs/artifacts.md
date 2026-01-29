# Artifact Taxonomy

> This document is NOT an implementation plan.
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

## [Category] Artifacts

### [artifact_type_name]

| Field | Value |
|-------|-------|
| **Producer** | [what creates this artifact] |
| **Lifecycle Phase** | Phase N |
| **Created When** | [trigger condition] |
| **Schema** | `field1`, `field2`, `field3` |
| **Retention** | Permanent / Temporary / [duration] |

---

## Adding New Artifact Types

When introducing a new artifact type:

1. Add an entry to this document with all required fields
2. Implement the producer to emit the artifact
3. Ensure the artifact is emitted within a traced span
4. Update validation scripts to check for the new type (if validation exists)
5. Reference the artifact type in the relevant ADR

---

## Summary

| Category | Artifact Types | Count |
|----------|---------------|-------|
| [Category] | [types] | 0 |
| **Total** | | **0** |
