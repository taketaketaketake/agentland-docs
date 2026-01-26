# Markdown Glossary

This document defines the **purpose, contents, and update cadence** for every markdown file in the repository.

---

## docs/glossary/markdown-glossary.md

**Purpose**
Defines the authoritative contract for all markdown files in the repository.

This file determines:
- What documentation exists
- What each file is responsible for
- When updates are mandatory

**What Goes Inside**
- File- and folder-level documentation contracts
- Update triggers
- Enforcement rules
- Routing logic for documentation changes

**What Does NOT Go Inside**
- System architecture
- Design rationale
- Phase summaries
- ADR content

**Audience**
LLMs first. Humans second.

**Update Cadence**
Rare and deliberate.

**Update Triggers**
- New markdown files are added anywhere in the repo
- New documentation categories are introduced
- Enforcement gaps or ambiguity are discovered
- Repository structure changes in a way that affects documentation responsibility

---

## README.md

**Purpose**
High-level human and LLM entry point to the repository.

**What Goes Inside**
- What this repo is
- What problem it solves
- How to get started (very high level)
- Pointers to deeper docs (vision.md, architecture.md)

**What Does NOT Go Inside**
- Detailed architecture
- Design rationale
- Prompt text

**Audience**
Humans first, LLMs second.

**Update Cadence**
Infrequent. Updated when the repo's purpose materially changes.

**Update Triggers**
- A phase is marked complete in `implementation-plan.md`
- The repo's stated purpose changes
- New top-level directories are added
- Getting started instructions become invalid

---

## CLAUDE.md

**Purpose**
Persistent, high-signal context for Claude (and Claude-like LLMs).

**What Goes Inside**
- How Claude should reason about this repo
- Assumptions Claude should make
- Assumptions Claude should NOT make
- High-level system constraints
- Pointers to authoritative files

**What Does NOT Go Inside**
- Prompts
- Code
- Temporary instructions

**Audience**
LLMs only.

**Update Cadence**
Rare, deliberate updates. This is a "constitution," not a scratchpad.

**Update Triggers**
- A new system invariant is introduced
- Architectural boundaries are redefined
- A new authoritative file is added to the repo

---

## implementation-plan.md

**Purpose**
Step-by-step execution plan for building the system.

**What Goes Inside**
- Phased infrastructure setup
- Dependencies between phases
- Explicit "stop points" for review
- What success looks like per phase

**What Does NOT Go Inside**
- Design debates
- Architecture diagrams
- Prompts

**Audience**
Humans and LLMs executing work.

**Update Cadence**
Updated as phases are completed or re-planned.

**Update Triggers**
- A phase is completed (mark as done, update status)
- A phase's scope is revised
- A new phase is added
- Phase dependencies change

---

## .cursor/ and .claude/

### .cursor/rules.md

**Purpose**
Rules and constraints for Cursor's code generation and edits.

**What Goes Inside**
- Code style rules
- Forbidden patterns
- Preferred abstractions
- Safety rails

**Audience**
LLMs via Cursor.

**Update Cadence**
As tooling behavior needs correction.

**Update Triggers**
- Cursor generates code violating established patterns
- New forbidden patterns are identified
- Preferred abstractions change

### .claude/settings.local.json

**Purpose**
Local, non-versioned Claude configuration.

**What Goes Inside**
- Model preferences
- Local overrides

**Audience**
Claude tooling only.

**Update Cadence**
Ad hoc, local only.

**Update Triggers**
- Local environment requirements change
- User-specific model preferences change

---

## docs/ (Authoritative Documentation)

### docs/vision.md

**Purpose**
Defines why the system exists and what it is ultimately trying to achieve.

**What Goes Inside**
- System intent
- Non-goals
- Core principles
- Design bias

**What Does NOT Go Inside**
- Implementation details
- File structure
- Prompts

**Audience**
Humans and LLMs equally.

**Update Cadence**
Very rare. Vision should be stable.

**Update Triggers**
- System intent is redefined by explicit decision
- Core principles are added or removed

### docs/architecture.md

**Purpose**
Explains how the system is structured at a conceptual level.

**What Goes Inside**
- Layered architecture
- Data flow
- Responsibility boundaries
- High-level diagrams (textual)

**What Does NOT Go Inside**
- Code
- Prompts
- Implementation minutiae

**Audience**
Humans and LLMs.

**Update Cadence**
Occasional, when architecture changes.

**Update Triggers**
- New infrastructure layer is added
- Responsibility boundaries change
- Data flow paths are modified
- New services or components are introduced

### docs/invariants.md

**Purpose**
Defines truths that must remain true for the system to be correct.

**What Goes Inside**
- Hard constraints
- Non-negotiable rules
- Safety guarantees

**What Does NOT Go Inside**
- Aspirational goals
- Temporary decisions

**Audience**
LLMs first, humans second.

**Update Cadence**
Extremely rare. Changes imply deep refactors.

**Update Triggers**
- A system invariant is violated by design
- New non-negotiable constraints are identified
- Safety guarantees are added or modified

### docs/models.md

**Purpose**
Canonical definitions of conceptual and data models.

**What Goes Inside**
- Mental models (Agent, Role, Directive, Artifact)
- Data model descriptions
- Relationships between concepts

**What Does NOT Go Inside**
- SQL schemas
- Code

**Audience**
LLMs and developers.

**Update Cadence**
Moderate, as models evolve.

**Update Triggers**
- Database schema changes
- New conceptual entities are introduced
- Relationships between models change
- Mental model definitions are refined

### docs/health-log.md

**Purpose**
Longitudinal record of codebase health assessments.

**What Goes Inside**
- Dated assessment entries with git SHA
- Dimensional ratings (architecture, code quality, etc.)
- Risks and recommended actions
- Executive summaries

**What Does NOT Go Inside**
- Detailed code analysis
- Implementation plans
- Phase completion records

**Audience**
Humans and LLMs reviewing project trajectory.

**Update Cadence**
Append-only. New entry per assessment.

**Update Triggers**
- User invokes `/health` or `codebase health check`
- Major milestone completed (optional)
- Before significant architectural changes (optional)

### docs/handoff.md

**Purpose**
Reference document for building business logic on top of this infrastructure.

**What Goes Inside**
- Layer inventory and purpose
- Code examples for using each layer
- Environment variable reference
- Quick start for forking
- Integration patterns

**What Does NOT Go Inside**
- Business logic
- Agent implementations
- Prompts

**Audience**
Developers (human or LLM) building on top of this infrastructure.

**Update Cadence**
Updated when infrastructure APIs change significantly.

**Update Triggers**
- New infrastructure layer is added
- Existing layer API changes
- New integration patterns are established

---

### docs/how-to-build-on-top.md

**Purpose**
Authoritative guide for building production systems on top of this infrastructure.

**What Goes Inside**
- Integration model (fork vs dependency)
- Architectural rules (non-negotiable)
- How to add cognition (agents)
- How to add business logic (modules)
- Memory usage rules
- Recommended product repo structure

**What Does NOT Go Inside**
- Implementation details
- Code examples (those go in handoff.md)
- Phase-specific content

**Audience**
Architects and developers planning to build on this infrastructure.

**Update Cadence**
Rare. This is a constitutional document.

**Update Triggers**
- Architectural rules change
- Integration model changes
- New forbidden patterns identified

---

### docs/stubs.md

**Purpose**
Authoritative registry of all stubbed components in the system.

**What Goes Inside**
- Every NoOp/stub implementation
- Why each stub exists
- What replaces it
- Which phase will replace it
- ADR references

**What Does NOT Go Inside**
- Implementation details
- Code snippets
- Phase planning

**Audience**
LLMs and developers.

**Update Cadence**
Updated whenever stubs are added or replaced.

**Update Triggers**
- New stub/NoOp component is created
- Existing stub is replaced with real implementation
- Stub scope or replacement plan changes

---

### docs/artifacts.md

**Purpose**
Authoritative registry of all artifact types in the system.

**What Goes Inside**
- Every artifact type
- Producer (what creates it)
- Schema (fields)
- Lifecycle phase
- Retention expectations

**What Does NOT Go Inside**
- Actual artifact content
- Implementation code
- Storage details

**Audience**
LLMs and developers.

**Update Cadence**
Updated whenever artifact types are added.

**Update Triggers**
- New artifact type is introduced
- Artifact schema changes
- Retention policy changes

---

### docs/audits/phase-NN-audit.md

**Purpose**
Machine-verifiable record that a phase passed its audit before being marked COMPLETE.

**What Goes Inside**
- Phase number
- Git SHA at completion
- Validation scripts executed with results
- ADR path
- Verdict (PASS required)
- Documentation updates verified

**What Does NOT Go Inside**
- Implementation details
- Code
- Full audit procedure (that's in skills/claude/phase-audit.md)

**Audience**
CI automation and humans verifying compliance.

**Update Cadence**
One file created per phase, at phase completion.

**Update Triggers**
- Phase is marked COMPLETE (audit file MUST be created)
- Never modified after creation (append-only record)

**Enforcement**
CI workflow `.github/workflows/audit-check.yml` fails if:
- A phase is marked COMPLETE without corresponding audit file
- Audit file exists but lacks PASS verdict

---

### docs/contracts.md

**Purpose**
Completeness status of every interface in the system.

**What Goes Inside**
- Every Protocol/interface
- Method signatures
- Bounded enums and taxonomies
- Completeness checklists

**What Does NOT Go Inside**
- Implementation details
- Usage examples
- Phase-specific context

**Audience**
LLMs and developers.

**Update Cadence**
Updated when interfaces change (rare after stabilization).

**Update Triggers**
- New interface is defined
- Interface method is added
- Enum/taxonomy is expanded
- Bounds are changed

---

### docs/glossary/glossary.md

**Purpose**
Canonical definitions for terms and files.

**What Goes Inside**
- Term definitions
- File-level contracts (this document)

**Audience**
LLMs first.

**Update Cadence**
Append-only where possible.

**Update Triggers**
- New terms are introduced to the system
- Existing term definitions are clarified or corrected

---

## docs/decisions/ (Architecture Decision Records — ADRs)

**Note on ADR Coverage**

All files under `docs/decisions/` follow the same contract:
- Immutable after acceptance
- Never edited retroactively
- Superseded only by new ADRs

This glossary does not list individual ADR files exhaustively.
The presence of additional ADRs (e.g., ADR-003, ADR-004, ADR-005) is expected and does not require glossary updates beyond this section.

### adr-template.md

**Purpose**
Schema that Claude must instantiate when generating ADRs at phase completion.

This is NOT an ADR itself. It defines the required structure for all ADRs.

**What Goes Inside**
- Section headings with placeholder guidance
- Required fields (Status, Date, Phase, Context, Decisions, etc.)
- Formatting examples
- Constraints on what each section must contain

**What Does NOT Go Inside**
- Actual decisions
- Phase-specific content
- Implementation details

**Audience**
LLMs (mandatory enforcement during phase completion).

**Update Cadence**
Extremely rare.

**Update Triggers**
- ADR structure requirements change
- New mandatory sections are identified
- Phase completion protocol changes

---

### adr-001-agent-runtime.md

**Purpose**
Records the decision to use a specific agent runtime approach.

**What Goes Inside**
- Context
- Decision
- Alternatives considered
- Consequences

**Audience**
Future humans and LLMs.

**Update Cadence**
Never edited after acceptance (append new ADRs instead).

**Update Triggers**
- None. ADRs are immutable after acceptance.
- New ADR files are created when significant architectural decisions are made.

### adr-002-llm-native-repo-structure.md

**Purpose**
Explains why the repo is structured to be LLM-native.

**What Goes Inside**
- Problem statement
- Chosen structure
- Why alternatives were rejected

**Audience**
LLMs and maintainers.

**Update Cadence**
Immutable after acceptance.

**Update Triggers**
- None. ADRs are immutable after acceptance.

---

## ai/design-time/ (Static AI Context)

### assumptions.md

**Purpose**
Explicit assumptions the system is built on.

**What Goes Inside**
- Environmental assumptions
- Organizational assumptions
- Technical assumptions

**Audience**
LLMs.

**Update Cadence**
Only when assumptions change.

**Update Triggers**
- Environmental assumptions are invalidated
- New technical constraints are discovered
- Organizational context changes

### boundaries.md

**Purpose**
Defines what the system will never do.

**What Goes Inside**
- Out-of-scope behaviors
- Forbidden actions

**Audience**
LLMs.

**Update Cadence**
Rare.

**Update Triggers**
- New out-of-scope behaviors are identified
- Forbidden actions are added based on incidents or reviews

### context.md

**Purpose**
Persistent background context for reasoning.

**What Goes Inside**
- Business context
- Historical context
- Long-lived facts

**Audience**
LLMs.

**Update Cadence**
Occasional.

**Update Triggers**
- Business context changes materially
- Historical context relevant to reasoning is discovered
- Long-lived facts are established or invalidated

### rules.md

**Purpose**
Design-time reasoning rules for agents.

**What Goes Inside**
- Reasoning constraints
- Prohibited inference patterns

**Audience**
LLMs.

**Update Cadence**
Rare.

**Update Triggers**
- Agent reasoning produces incorrect outputs due to missing constraints
- New prohibited inference patterns are identified

---

## ai/runtime/ (Operational AI Contracts)

### contracts/directive.md

**Purpose**
Defines the directive schema and semantics.

**What Goes Inside**
- Fields
- Meaning
- Constraints

**Audience**
LLMs and execution systems.

**Update Cadence**
Careful, versioned changes only.

**Update Triggers**
- Directive schema is modified in code
- New directive fields are added
- Directive semantics are clarified

### contracts/evaluation.md

**Purpose**
Defines how outcomes are evaluated.

**What Goes Inside**
- Evaluation dimensions
- Inputs/outputs
- Scoring philosophy

**Audience**
Evaluator agents.

**Update Cadence**
Moderate.

**Update Triggers**
- Evaluation dimensions are added or modified
- Scoring philosophy changes
- New evaluation inputs or outputs are defined

### contracts/safety.md

**Purpose**
Defines runtime safety constraints.

**What Goes Inside**
- Hard stops
- Escalation conditions

**Audience**
LLMs and orchestration logic.

**Update Cadence**
Rare and conservative.

**Update Triggers**
- New hard stops are identified
- Escalation conditions are modified
- Safety incidents require new constraints

### evaluation/scoring.md

**Purpose**
Concrete scoring mechanics.

**What Goes Inside**
- Scoring formulas
- Weights
- Normalization

**Audience**
Evaluator agents.

**Update Cadence**
Iterative.

**Update Triggers**
- Scoring formulas are adjusted
- Weights are rebalanced
- Normalization methods change

### roles/executive.md, planner.md, supervisor.md

**Purpose**
Defines responsibilities and scope for each role.

**What Goes Inside**
- Role mandate
- Inputs/outputs
- What the role is accountable for

**Audience**
LLMs.

**Update Cadence**
Infrequent.

**Update Triggers**
- Role responsibilities are redefined
- Role inputs or outputs change
- Accountability boundaries shift

---

## prompts/

**Purpose**
Reusable prompt components.

**Expectation**
Prompts are not logic. They are configuration.

**Update Triggers**
- Prompt components are added, modified, or removed
- Prompt structure changes

---

## src/

**Purpose**
Executable system code.

Markdown generally does not belong here, except for implementation guides in extensible infrastructure directories.

**Update Triggers**
- None for most of src/.
- See exceptions below.

### src/infra/llm/README.md

**Purpose**
Implementation guide for adding new LLM providers.

**What Goes Inside**
- Provider implementation patterns
- Required interface and behaviors
- Error taxonomy reference
- Testing requirements
- What does NOT belong in this directory

**What Does NOT Go Inside**
- Authoritative contract rules (those go in `docs/contracts.md`)
- Agent logic or prompts
- Business requirements

**Audience**
Developers (human or LLM) implementing new providers.

**Update Cadence**
When provider patterns change.

**Update Triggers**
- New LLM provider added
- Provider interface changes
- Error taxonomy changes
- Testing requirements change

---

## skills/ (LLM-Enforced Procedures)

**Purpose**
Defines deterministic, procedural behaviors that an LLM must follow.

Skills are not prompts, suggestions, or examples.
They are **enforcement mechanisms** expressed as markdown.

**What Goes Inside**
- Step-by-step procedures
- Preconditions and postconditions
- Required inputs and outputs
- Deterministic pass/fail criteria
- Explicit refusal conditions

**What Does NOT Go Inside**
- Reasoning or analysis
- Flexible guidance
- Business logic
- Code

**Audience**
LLMs only.

**Update Cadence**
Rare. Skills define system behavior and must be stable.

**Update Triggers**
- A new enforced procedure is introduced
- An existing enforcement mechanism changes
- A skill is promoted from advisory to mandatory

### skills/claude/codebase-health.md

**Purpose**
Defines the procedure for performing structured codebase health assessments.

**What Goes Inside**
- Assessment dimensions and criteria
- Output format specification
- Procedure steps
- Constraints on reporting

**What Does NOT Go Inside**
- Actual assessment results (those go in `docs/health-log.md`)
- Phase-specific logic
- Business metrics

**Audience**
Claude (optional invocation).

**Update Cadence**
Rare.

**Update Triggers**
- Assessment dimensions change
- Output format changes
- New health metrics are introduced

---

### skills/claude/phase-audit.md

**Purpose**
Defines the mandatory audit procedure that must be passed before any phase may be marked COMPLETE.

This is the single enforcement surface for all phase completion artifacts:
- Documentation updates (per glossary triggers)
- Architecture Decision Records (per ADR template)

**What Goes Inside**
- Audit inputs
- Trigger-matching logic
- Documentation verification steps
- ADR verification steps
- Deterministic PASS / FAIL criteria
- Required remediation on failure

**What Does NOT Go Inside**
- Phase-specific logic
- Implementation details
- Suggestions or optional steps
- Separate artifact enforcement (all artifacts enforced here)

**Audience**
Claude (mandatory enforcement).

**Update Cadence**
Extremely rare.

**Update Triggers**
- Documentation governance rules change
- Phase completion semantics change
- The glossary authority model changes
- ADR template structure changes
- New phase completion artifacts are introduced

---

## scripts/, tests/

**Purpose**
Operational tooling and validation.

Markdown here should be instructional only if present.

**Update Triggers**
- Instructional markdown is added when tooling requires documentation
- Existing instructions become invalid

---

## Operational / Personal Reference Documentation

### HOW-TO-USE-DOCKER.md

**Purpose**
Personal, operator-facing reference for using Docker in this repository.

This file exists to support a novice Docker user (the primary maintainer) and
documents practical commands, workflows, and reminders needed to operate the
development environment.

**What Goes Inside**
- Docker and Docker Compose commands used in this repo
- Explanations written for future self
- Common mistakes and fixes
- Local environment notes

**What Does NOT Go Inside**
- System architecture
- Design rationale
- Phase decisions
- Enforcement rules
- Anything intended as canonical system documentation

**Audience**
Primary maintainer (human) only.

LLMs may reference this file for operational assistance, but must not treat it
as authoritative architecture or system intent.

**Update Cadence**
Ad hoc.

Updated whenever the maintainer learns something new or encounters friction.

**Update Triggers**
- Docker commands change
- Docker Compose services change
- A previously confusing workflow becomes clear
- The maintainer needs reminders or clarification

---

## Documentation Update Protocol (Authoritative)

This section defines the procedure an LLM must follow after completing an implementation phase.

**Step 1: Identify Completed Work**
- Determine what infrastructure, schemas, or components were added or modified.
- Note any new files, directories, or capabilities introduced.

**Step 2: Consult This Glossary**
- For each markdown file entry in this glossary, check its **Update Triggers**.
- If any trigger matches the completed work, that file requires an update.
- If no triggers match, that file must NOT be edited.

**Step 3: Update Matched Files**
- Edit only the files whose triggers matched.
- Ensure edits reflect the new system reality, not speculation.
- Do not add content that anticipates future phases.

**Step 4: Update Phase-Tracking Files**
- `README.md`: Update if the repo's capabilities or getting-started instructions changed.
- `implementation-plan.md`: Mark the completed phase as done. Update status and any revised scope.

**Step 5: Do Not Edit Unmatched Files**
- Files without matching triggers must remain unchanged.
- Do not "clean up" or "improve" documentation outside of matched triggers.

**Routing Summary**

| Change Type                        | Files to Update                              |
|------------------------------------|----------------------------------------------|
| Phase completed                    | `implementation-plan.md`, `README.md`        |
| Database schema changed            | `docs/models.md`                             |
| New infrastructure layer added     | `docs/architecture.md`                       |
| New invariant introduced           | `docs/invariants.md`                         |
| New term introduced                | `docs/glossary/glossary.md`                  |
| New markdown file added            | `docs/glossary/markdown-glossary.md`         |
| Architectural decision made        | New ADR in `docs/decisions/`                 |
| Role responsibilities changed      | `ai/runtime/roles/*.md`                      |
| Directive schema changed           | `ai/runtime/contracts/directive.md`          |
| Operational / personal reference added | `docs/glossary/markdown-glossary.md`     |
| New stub/NoOp created              | `docs/stubs.md`                              |
| Stub replaced with real impl       | `docs/stubs.md`                              |
| New artifact type introduced       | `docs/artifacts.md`                          |
| Interface/Protocol changed         | `docs/contracts.md`                          |

---

## Final Note (Important)

This file is not documentation. It is a **contract**.

Every markdown file in this repository has a defined purpose.
If a file drifts from its purpose, it must be corrected or split.