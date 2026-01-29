# ADR-XXX: <Decision Title> (Phase <N>)

---

## Status
Accepted

## Date
<YYYY-MM-DD>

## Phase
Phase <N> — <Phase Name>

OR

N/A — Cross-cutting / Meta-architecture

## Context

Describe the system state *before* this phase.

Include:
- What existed
- What was missing
- What risk or gap necessitated this phase

Do NOT include implementation steps.

## Decisions

List the concrete architectural decisions made in this phase.

Each decision must be:
- Specific
- Observable in the codebase
- Non-trivial to reverse

Example format:

### 1. <Decision Name>

**Decision:** <What was chosen>

**Rationale:** <Why this choice was made>

## Constraints Enforced

List invariants or constraints this phase explicitly preserved or introduced.

Examples:
- No imports from `ai/runtime/`
- Single mutator pattern enforced
- No LLM calls
- Deterministic behavior only

## Alternatives Considered

List at least one alternative and why it was rejected.

OR provide an explicit statement explaining why no viable alternatives existed.

Example acceptable text:
> "No viable alternatives existed due to constraints X and Y."

Alternatives should reflect *real choices*, not strawmen.

## Consequences

### Positive
- What is now possible
- What risk was reduced

### Negative / Tradeoffs
- What became harder
- What was deferred

### Neutral
- Structural changes with no immediate effect

## Outcome

Describe the *observable end state* of the system after this phase.

This should be verifiable via:
- Code
- Database schema
- Validation scripts

## Validation

List concrete validation evidence:
- Scripts run
- Tests passed
- Workflows observed
- Tables created

## Notes for Future Phases

Explicit warnings to future contributors or LLMs:
- What must NOT be changed casually
- What semantics are intentionally missing
- What requires a new ADR
