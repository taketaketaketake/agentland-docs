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
- A phase is marked complete in `docs/plan/plan-template.md`
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

## docs/plan/plan-template.md

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

## .claude/

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

## .github/

### .github/copilot-instructions.md

**Purpose**
Instructions for GitHub Copilot coding agent when working in this repository.

**What Goes Inside**
- Repository purpose and what it is/isn't
- Development philosophy and core principles
- Phase-based workflow and completion protocol
- Key documentation files to reference
- Files and directories that should never be modified
- Architectural boundaries and multi-LLM support

**What Does NOT Go Inside**
- Temporary instructions
- Code samples
- Project-specific business logic

**Audience**
GitHub Copilot coding agent (LLM).

**Update Cadence**
Infrequent. Updated when repository development practices or structure materially changes.

**Update Triggers**
- New system invariants are introduced
- Architectural boundaries are redefined
- Phase completion protocol changes
- Repository structure changes in ways that affect agent behavior
- New authoritative files are added

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
- Mental models
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
- User invokes `/codebase-health` or `codebase health check`
- Major milestone completed (optional)
- Before significant architectural changes (optional)

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
- Full audit procedure (that's in `.claude/skills/phase-audit/SKILL.md`)

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
- File-level contracts

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

## .claude/hooks/ (Claude Code Enforcement Hooks)

**Purpose**
Shell scripts that Claude Code executes automatically on specific events.
Unlike skills (which rely on LLM compliance), hooks are enforced by the runtime.

### .claude/hooks/session-context.sh

**Purpose**
Loads the glossary routing table into Claude's context at session start.

**Event:** `SessionStart` (startup)

**Behavior:** Extracts the Documentation Update Protocol section from `docs/glossary/markdown-glossary.md` and injects it as context. Claude sees the routing table before doing any work.

**Update Triggers**
- Routing table structure changes
- New doc trigger categories are added

### .claude/hooks/check-doc-triggers.sh

**Purpose**
Warns Claude after source file edits if glossary-triggered docs weren't updated.

**Event:** `PostToolUse` (Edit, Write)

**Behavior:** Maps the edited file path against a routing table. If the edit triggers docs that haven't been modified in the current git session, emits a warning as additional context.

**Update Triggers**
- New source-to-doc routing rules are added
- Routing table patterns change

### .claude/hooks/pre-commit-docs.sh

**Purpose**
Blocks git commits if documentation is incomplete. This is the hard gate.

**Event:** `PreToolUse` (Bash, filtered to `git commit`)

**Blocks if:**
- A phase is marked COMPLETE without a corresponding `docs/audits/phase-NN-audit.md`
- Source files contain stub markers without entries in `docs/stubs.md`
- Interface files changed without `docs/contracts.md` being updated

**Update Triggers**
- New commit-blocking rules are added
- Stub detection patterns change
- Phase completion detection changes

---

## .claude/settings.json (Hook Wiring)

**Purpose**
Wires Claude Code hooks to their trigger events.

**What Goes Inside**
- Hook event mappings (SessionStart, PostToolUse, PreToolUse)
- Matcher patterns (which tools trigger which hooks)
- Hook configuration (type, command, statusMessage)

**What Does NOT Go Inside**
- Local user preferences (those go in settings.local.json)
- Permission rules

**Audience**
Claude Code runtime.

**Update Cadence**
Updated when hooks are added or event wiring changes.

**Update Triggers**
- New hook script is added
- Hook event mapping changes
- Matcher patterns need updating

---

## .claude/skills/ (LLM-Enforced Procedures)

**Purpose**
Defines deterministic, procedural behaviors that an LLM must follow.

Skills are not prompts, suggestions, or examples.
They are **enforcement mechanisms** expressed as markdown.

Each skill is a directory containing a `SKILL.md` entrypoint with YAML frontmatter,
following the Claude Code skills convention.

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

### .claude/skills/codebase-health/SKILL.md

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

### .claude/skills/phase-audit/SKILL.md

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

## Adding New Entries to This Glossary

When your project introduces new directories or files, add an entry following this template:

```markdown
### path/to/new-file.md

**Purpose**
[What this file is responsible for]

**What Goes Inside**
- [Content type 1]
- [Content type 2]

**What Does NOT Go Inside**
- [Excluded content type 1]
- [Excluded content type 2]

**Audience**
[Primary audience]. [Secondary audience].

**Update Cadence**
[How often this file changes]

**Update Triggers**
- [Event that requires this file to be updated]
- [Another event]
```

Common directory patterns you may add as your project grows:

- **`ai/design-time/`** — Static context files (assumptions, boundaries, rules) for LLM reasoning
- **`ai/runtime/`** — Operational contracts (directives, evaluation, safety, roles)
- **`prompts/`** — Reusable prompt components (configuration, not logic)
- **`src/`** — Executable system code (markdown generally does not belong here except for implementation guides)

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
- `docs/plan/plan-template.md`: Mark the completed phase as done. Update status and any revised scope.

**Step 5: Do Not Edit Unmatched Files**
- Files without matching triggers must remain unchanged.
- Do not "clean up" or "improve" documentation outside of matched triggers.

**Routing Summary**

| Change Type                        | Files to Update                              |
|------------------------------------|----------------------------------------------|
| Phase completed                    | `docs/plan/plan-template.md`, `README.md`        |
| Database schema changed            | `docs/models.md`                             |
| New infrastructure layer added     | `docs/architecture.md`                       |
| New invariant introduced           | `docs/invariants.md`                         |
| New term introduced                | `docs/glossary/glossary.md`                  |
| New markdown file added            | `docs/glossary/markdown-glossary.md`         |
| Architectural decision made        | New ADR in `docs/decisions/`                 |
| New stub/NoOp created              | `docs/stubs.md`                              |
| Stub replaced with real impl       | `docs/stubs.md`                              |
| New artifact type introduced       | `docs/artifacts.md`                          |
| Interface/Protocol changed         | `docs/contracts.md`                          |

---

## Final Note (Important)

This file is not documentation. It is a **contract**.

Every markdown file in this repository has a defined purpose.
If a file drifts from its purpose, it must be corrected or split.
