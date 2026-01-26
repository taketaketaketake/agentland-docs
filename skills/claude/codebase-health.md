# Skill: codebase_health

## Purpose

Perform a structured assessment of the codebase and append results to `docs/health-log.md`.

This creates a longitudinal record of codebase quality over time.

---

## Invocation

User says any of:
- `/health`
- `run codebase health check`
- `assess codebase health`

---

## Inputs

None required. All context is derived from the repository.

---

## Procedure

### Step 1: Capture Metadata

```bash
git rev-parse --short HEAD   # Current commit SHA
git log -1 --format=%ci      # Commit date
date +%Y-%m-%d               # Assessment date
```

Record:
- `assessment_date`: Today's date
- `git_sha`: Current commit (short)
- `git_date`: Date of that commit

### Step 2: Gather Codebase State

Inspect the following areas:

| Area | What to Check |
|------|---------------|
| **Phase Status** | Read `implementation-plan.md`, identify completed/in-progress phases |
| **Source Code** | Scan `src/` for modules, patterns, code quality |
| **Database** | Check `alembic/versions/` for migration count and recency |
| **Documentation** | Verify `docs/` files exist and are current |
| **Validation** | Check `scripts/` for validation coverage |
| **Tests** | Check `tests/` for test coverage |
| **ADRs** | Count ADRs in `docs/decisions/` |
| **Open Issues** | Note any obvious gaps, TODOs, or debt |

### Step 3: Assess Each Dimension

Rate each dimension:

| Dimension | Rating | Criteria |
|-----------|--------|----------|
| **Architecture** | Strong / Adequate / Weak | Boundaries enforced? Layers clean? |
| **Code Quality** | Strong / Adequate / Weak | Patterns consistent? Readable? |
| **Documentation** | Strong / Adequate / Weak | Current? Complete? Accurate? |
| **Test Coverage** | Strong / Adequate / Weak | Validation scripts? Unit tests? |
| **Technical Debt** | None / Low / Medium / High | Shortcuts? Hacks? TODOs? |
| **Phase Progress** | On Track / Behind / Blocked | Per implementation plan |

### Step 4: Identify Risks and Actions

List:
- **Risks**: What could cause problems if unaddressed
- **Recommended Actions**: Concrete next steps (max 5)

### Step 5: Generate Summary

Produce a single-paragraph executive summary answering:
> Is this codebase healthy, and is it on track?

---

## Output Format

The assessment MUST be appended to `docs/health-log.md` in this format:

```markdown
---

## YYYY-MM-DD | `<git-sha>`

**Phase Status:** Phase N complete, Phase M in progress

### Dimensions

| Dimension | Rating |
|-----------|--------|
| Architecture | ... |
| Code Quality | ... |
| Documentation | ... |
| Test Coverage | ... |
| Technical Debt | ... |
| Phase Progress | ... |

### Risks
- ...

### Recommended Actions
1. ...

### Summary

<Executive summary paragraph>
```

---

## Constraints

- Do NOT delete or modify previous entries in the log
- Do NOT fabricate observations—only report what is observable
- Do NOT include time estimates
- Keep each entry concise (aim for < 100 lines)

---

## Post-Completion

After appending to the log:
1. Show the user the new entry
2. Offer to commit the updated log

---

## Integration

This skill is optional and user-invoked.
It does not block any other operations.
