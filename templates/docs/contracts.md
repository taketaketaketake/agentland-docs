# Interface Contracts

> This document is NOT an implementation plan.
> It does not authorize code changes or execution.
> All implementation requires an approved entry in `implementation-plan.md`.

This document defines the **completeness status** of every interface in the system.

An interface is "complete" when:
- All methods are defined
- All input types are bounded
- All output types are frozen
- All error types are enumerated
- Behavior is deterministic (given same input → same output)

---

## [Interface Name]

| Field | Value |
|-------|-------|
| **Location** | `path/to/interface.py` |
| **Status** | COMPLETE / IN_PROGRESS / NOT_STARTED |
| **Phase** | Phase N |

### Methods

| Method | Input | Output | Status |
|--------|-------|--------|--------|
| `method_name()` | `InputType` | `OutputType` | Defined |

### Error Types

| Error | Meaning |
|-------|---------|
| `error_type` | [description] |

---

## Interface Modification Rules

1. **Adding methods to a Protocol**: Requires new ADR
2. **Changing input types**: Requires new ADR
3. **Changing output types**: Requires new ADR
4. **Expanding enums**: Requires new ADR
5. **Changing bounds**: Requires justification in commit message

Interfaces are frozen after stabilization. New capabilities require new interfaces, not modifications to existing ones.
