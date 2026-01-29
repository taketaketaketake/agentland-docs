# Stub Registry

> This document is NOT an implementation plan.
> It does not authorize code changes or execution.
> All implementation requires an approved entry in `implementation-plan.md`.

This document is the **authoritative registry** of all stubbed components in the system.

Every stub must have:
- A documented reason for existing
- A replacement path
- An ADR reference

**No stub may exist without an entry here.**

Phase audits FAIL if a NoOp/stub exists without a corresponding entry in this registry.

---

## [Category Name]

### [Stub Name]

| Field | Value |
|-------|-------|
| **Location** | `path/to/stub.py` |
| **Type** | NoOp / Stub / Mock |
| **Why Stubbed** | [Reason] |
| **Replaced By** | [Real implementation] |
| **Target Phase** | Phase N |
| **ADR** | `docs/decisions/adr-NNN.md` |

---

## Enforcement

The phase audit skill must verify:

1. Every file matching `**/noop*.py` or `**/*_stub*.py` has a registry entry
2. Every registry entry has all required fields
3. Every registry entry references a valid ADR

Violation of any of these causes phase audit to FAIL.

---

## Maintenance

When adding a new stub:
1. Create the stub implementation
2. Add entry to this registry immediately
3. Reference the ADR that justifies the stub
4. Specify replacement path

When replacing a stub:
1. Implement the replacement
2. Update this registry (mark as "Replaced in Phase X")
3. Keep the entry for historical reference

---

## Summary

| Category | Stub Count | Permanent | Replaced | To Replace |
|----------|------------|-----------|----------|------------|
| [Category] | 0 | 0 | 0 | 0 |
