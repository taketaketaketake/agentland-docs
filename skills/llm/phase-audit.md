# Skill: phase_audit

## Purpose

Verify that all phase completion artifacts exist and are valid before allowing the phase to be marked COMPLETE.

Phase completion artifacts include:
- Documentation updates (as defined by glossary triggers)
- Architecture Decision Record (ADR) for the phase

This is an enforcement mechanism, not a suggestion.
There is exactly one place where phase completion can be blocked: this audit.

---

## Inputs

| Input | Required | Description |
|-------|----------|-------------|
| `phase_number` | Yes | The phase number being marked complete (e.g., "1", "2a") |
| `phase_description` | Yes | Brief description of what the phase accomplished |
| `changes_made` | Yes | List of infrastructure, schema, or component changes made |

---

## Preconditions

Before invoking this skill:
- The phase implementation work must be complete
- All code changes must be committed or staged
- The invoker must be able to describe what changed
- The glossary (`docs/glossary/markdown-glossary.md`) is treated as authoritative and must not be bypassed or partially applied

---

## Procedure

### Step 1: Load the Documentation Contract

Read `docs/glossary/markdown-glossary.md` in full.

Extract all entries that have an **Update Triggers** section.

Build a mapping:
```
{file_path} -> [list of triggers]
```

### Step 2: Identify Triggered Files

For each file in the mapping, evaluate whether any of its triggers match the `changes_made` input.

A trigger matches if:
- The change type explicitly matches the trigger description
- OR the change implies the trigger (e.g., "added new table" implies "Database schema changed")

Phase completion ALWAYS triggers:
- `implementation-plan.md` (must be updated to mark phase done)
- `README.md` (if capabilities or getting-started changed)

Build a list: `files_requiring_update`

### Step 3: Inspect Repository State

For each file in `files_requiring_update`:

1. Check if the file exists
2. Check if the file was modified in the current working session (via git status, git diff, or file inspection)
3. Check if the file content reflects the changes made

Record for each file:
- `status`: UPDATED | MISSING_UPDATE | FILE_NOT_FOUND
- `evidence`: What was found or not found

### Step 4: Evaluate implementation-plan.md

This file requires special verification:
- The specified phase must be marked with a completion indicator (e.g., `[x]`, `COMPLETE`, `Done`)
- The phase status must not be `in progress` or unmarked

If `implementation-plan.md` does not reflect phase completion: `status = MISSING_UPDATE`

### Step 5: Verify ADR Creation

For the completed phase, verify that an Architecture Decision Record exists.

**Grandfather clause:** ADRs numbered 001-009 are exempt from template enforcement.
Template validation applies only to ADR-010 and later.

1. **Check for ADR existence**
   - Inspect `docs/decisions/` for at least one ADR that references this phase
   - ADR filename should follow pattern: `adr-NNN-<short-slug>.md`
   - At least one ADR MUST reference the completed phase number in its Phase section
   - Note: Not all ADRs must map to phases (cross-cutting decisions use `Phase: N/A`)

2. **Validate ADR structure** (ADR-010+ only)
   - The ADR MUST follow `docs/decisions/adr-template.md`
   - Required sections: Status, Date, Phase, Context, Decisions, Constraints Enforced, Alternatives Considered, Consequences, Outcome, Validation
   - The ADR MUST be marked `Status: Accepted`

3. **Validate ADR content**
   - Decisions documented must be observable in the codebase (see examples below)
   - Constraints listed must match actual enforcement in code
   - Validation section must cite concrete evidence (scripts, tests, schema)

4. **Record ADR status**
   - `CREATED_AND_VALID`: ADR exists, follows template, content is accurate
   - `MISSING`: No ADR exists for this phase
   - `INVALID_FORMAT`: ADR exists but does not follow template (ADR-010+ only)
   - `INCOMPLETE_CONTENT`: ADR exists but decisions/constraints are not grounded in code

#### What qualifies as "observable in the codebase"

**Examples that PASS:**
- New files, modules, or directories exist
- A database migration introduces new tables/columns
- A workflow/activity is implemented
- A lifecycle/state machine exists in code
- A previously forbidden import is still absent

**Examples that FAIL:**
- Decisions about future behavior not yet implemented
- Aspirational patterns without code presence
- "Planned" integrations without stubs or interfaces

---

### Step 6: Validation Check (MANDATORY)

For the phase under audit:

1. **Identify the expected validation script(s)**
   - Check `scripts/validate_*.py` for a script corresponding to the phase
   - Phase-to-script mapping should be evident from script docstrings or names

2. **Verify the script(s) exist**
   - If no validation script exists for a behavioral phase: audit MUST FAIL
   - Non-behavioral phases (e.g., documentation-only) may be exempt

3. **Verify the script(s) have been executed successfully**
   - Check for evidence of recent execution (terminal output, logs, or explicit confirmation)
   - If validation has not been run: audit MUST FAIL

Record validation status:
- `VALIDATED`: Script exists and was executed successfully
- `NOT_EXECUTED`: Script exists but was not run
- `SCRIPT_MISSING`: No validation script found for behavioral phase
- `EXEMPT`: Phase is non-behavioral (documentation-only)

**A phase audit MUST return FAIL if validation scripts were not executed.**

---

### Step 7: Generate Audit Report

Produce a structured report in the following format:

```
## Phase Audit Report

**Phase:** {phase_number}
**Description:** {phase_description}
**Audit Time:** {timestamp}

### Changes Declared
{bulleted list of changes_made}

### Files Requiring Update
{bulleted list of files_requiring_update with trigger reason}

### Documentation Audit Results

| File | Status | Evidence |
|------|--------|----------|
| ... | UPDATED / MISSING_UPDATE / FILE_NOT_FOUND | ... |

### ADR Audit Results

| Check | Status | Evidence |
|-------|--------|----------|
| ADR Exists | YES / NO | {filename or "not found"} |
| Follows Template | YES / NO | {missing sections if any} |
| Content Valid | YES / NO | {ungrounded claims if any} |
| **ADR Status** | {CREATED_AND_VALID / MISSING / INVALID_FORMAT / INCOMPLETE_CONTENT} | |

### Validation Audit Results

| Check | Status | Evidence |
|-------|--------|----------|
| Script Exists | YES / NO | {script path or "not found"} |
| Script Executed | YES / NO | {execution evidence} |
| **Validation Status** | {VALIDATED / NOT_EXECUTED / SCRIPT_MISSING / EXEMPT} | |

### Verdict

**{PASS | FAIL}**

{If FAIL: list specific remediation actions required}
```

### Step 8: Return Verdict

- Return `PASS` if and only if:
  - ALL files in `files_requiring_update` have `status = UPDATED`
  - AND ADR status is `CREATED_AND_VALID`
  - AND Validation status is `VALIDATED` or `EXEMPT`
- Return `FAIL` if ANY of the following:
  - Any file has `status = MISSING_UPDATE` or `status = FILE_NOT_FOUND`
  - ADR status is `MISSING`, `INVALID_FORMAT`, or `INCOMPLETE_CONTENT`
  - Validation status is `NOT_EXECUTED` or `SCRIPT_MISSING`

### Step 9: Create Audit File (PASS only)

If verdict is PASS, create an audit file at `docs/audits/phase-NN-audit.md` containing:

```markdown
# Phase NN Audit Report

| Field | Value |
|-------|-------|
| Phase | NN |
| Description | {phase_description} |
| Git SHA | {current_commit_sha} |
| Date | {YYYY-MM-DD} |
| Verdict | **PASS** |

## Validation Scripts

| Script | Result |
|--------|--------|
| `scripts/validate_xxx.py` | N/N passed |

## ADR

| Field | Value |
|-------|-------|
| Path | `docs/decisions/adr-NNN-xxx.md` |
| Status | Accepted |

## Documentation Updates

| File | Trigger | Updated |
|------|---------|---------|
| ... | ... | Yes |

## Auditor

Claude (automated phase audit)
```

**This file is required.** CI will fail if a phase is marked COMPLETE without a corresponding audit file.

---

## PASS Criteria

All of the following must be true:
- `implementation-plan.md` reflects the phase as complete
- Every file whose Update Triggers matched has been modified
- Modified files contain content consistent with the declared changes
- A phase-specific ADR exists in `docs/decisions/`
- The ADR follows `docs/decisions/adr-template.md`
- The ADR content accurately reflects decisions made in the codebase
- Validation script exists and was executed successfully (or phase is exempt)
- Audit file created at `docs/audits/phase-NN-audit.md`

---

## FAIL Criteria

Any of the following:
- `implementation-plan.md` does not mark the phase complete
- Validation script was not executed (for behavioral phases)
- Any triggered file was not updated
- Any triggered file does not exist
- The audit cannot be completed due to missing inputs
- No ADR exists for the completed phase
- ADR does not follow the template structure
- ADR contains decisions or constraints not observable in code

---

## Output Format

The skill MUST output:

1. The full audit report (as specified in Step 7)
2. ADR audit status (as specified in Step 5)
3. Validation audit status (as specified in Step 6)
4. A single-line verdict: `VERDICT: PASS` or `VERDICT: FAIL`
5. If PASS: Create audit file at `docs/audits/phase-NN-audit.md`
6. If FAIL: A numbered list of required actions before phase can be marked complete

---

## Invocation Examples

### Example 1: Invoking after completing Phase 1

```
Inputs:
  phase_number: "1"
  phase_description: "Database foundation with Alembic migrations"
  changes_made:
    - Added PostgreSQL schema for directives table
    - Created Alembic migration infrastructure
    - Added SQLAlchemy models in src/infra/models/
```

### Example 2: Audit failure response (documentation)

```
VERDICT: FAIL

Required actions before marking Phase 1 complete:
1. Update docs/models.md to document the directives table schema
2. Update docs/architecture.md to reflect the new database layer
3. Mark Phase 1 as complete in implementation-plan.md
4. Create ADR for Phase 1 following docs/decisions/adr-template.md
```

### Example 3: Audit failure response (ADR)

```
VERDICT: FAIL

ADR Status: INCOMPLETE_CONTENT

Required actions before marking Phase 3 complete:
1. ADR-006 is missing "Alternatives Considered" section
2. ADR-006 "Constraints Enforced" lists "vector store integration" but no vector code exists
3. Add validation evidence to ADR-006 Validation section
```

---

## Constraints

- This skill does not modify files. It only audits.
- This skill must be invoked BEFORE any phase is marked complete.
- A FAIL verdict blocks phase completion until remediation is done.
- The glossary (`docs/glossary/markdown-glossary.md`) is the sole source of truth for documentation update requirements.
- The ADR template (`docs/decisions/adr-template.md`) is the sole source of truth for ADR structure.
- Phase completion artifacts (documentation, ADRs) are enforced by this audit, not by separate skills.

---

## Invalid Substitutes for Implementation Plans

The following documents are **retrospective seals** that document past work.
They MUST NOT be treated as implementation plans or authorization to write code:

| Document | Purpose | Authorizes Code? |
|----------|---------|------------------|
| `docs/stubs.md` | Registry of existing stubs | ❌ No |
| `docs/artifacts.md` | Taxonomy of existing artifact types | ❌ No |
| `docs/contracts.md` | Completeness status of existing interfaces | ❌ No |
| `docs/decisions/*.md` (ADRs) | Decision justification | ❌ No |
| `docs/glossary/*.md` | Routing & enforcement rules | ❌ No |

**Only `implementation-plan.md` authorizes implementation work.**

If Claude attempts to proceed with code changes based on any of the above documents
without an approved entry in `implementation-plan.md`, the audit MUST FAIL.

### Detection During Audit

When auditing a phase, verify:
1. The phase has a corresponding entry in `implementation-plan.md`
2. Claude did not treat stabilization docs as implicit planning authorization
3. Any "planned" work in stabilization docs has a separate implementation plan entry

---

## Integration

This skill is bound to CLAUDE.md as a mandatory pre-completion check.

Claude must refuse to mark a phase complete if this audit returns FAIL.

**Note on enforcement mechanism:**
This enforcement currently relies on Claude's compliance with CLAUDE.md directives.
Future automation (CI hooks, git checks) may formalize this into machinery.
Until then, the audit is convention-based but mandatory.

---

## PASS → Execution Authorization

When a phase audit passes:

- Claude is authorized to execute all remaining implementation steps
- Claude must not ask clarifying questions unless:
  - An invariant would be violated, or
  - Required inputs are genuinely missing
- Default behavior is to proceed, not pause

A PASS verdict is an explicit grant of execution authority. Claude should complete all phase work—including documentation updates, ADR creation, and implementation-plan marking—without waiting for additional confirmation.
