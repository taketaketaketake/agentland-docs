# Foundational Infrastructure Plan

> Empty but Real, End-to-End

---

## Status

**All 15 infrastructure phases are complete.**

This plan is now frozen. No new phases will be added to this repository.

Agent logic, cognition, and product-specific behavior belong in downstream forks.
See `docs/handoff.md` for integration guidance.

---

## Phase Completion Rules

A phase may be marked COMPLETE only when:
1. All exit criteria are satisfied
2. All required validation scripts have been executed successfully
3. A phase audit has passed

**Validation is mandatory for phase completion.**

See `docs/invariants.md` §16 for the formal constraint.

---

Below is a phased, infrastructure-only implementation plan.
No business logic. No project-specific agents.
Each layer exists, is wired, observable, and empty-but-ready.

---

## Stack (Confirmed)

| Component | Purpose |
|-----------|---------|
| Python | Runtime |
| Temporal | Workflow orchestration |
| Postgres | Persistence |
| SQLAlchemy Core + Pydantic | Models & validation |
| Docker / Docker Compose | Containerization |
| OpenTelemetry | Baseline observability |
| Braintrust | Later, pluggable, not blocking |
| Cloudflare R2 | Artifact target, stubbed initially |

**Redis:** Not required at this stage.

---

## The Control Loop (Canonical)

Each phase below instantiates one or more boxes, empty but wired.

---

## PHASE 0 — Repo + Boundaries (Day 0)

### Goal

Create a repository that enforces separation of concerns from day one.

### Deliverables

- Repo skeleton
- Docker Compose spine
- Nothing "agentic" yet

### Structure (after Phase 2)

```
repo/
├─ .claude/
│  └─ settings.local.json
├─ .cursor/
│  └─ rules.md
├─ ai/
│  ├─ design-time/
│  │  ├─ assumptions.md
│  │  ├─ boundaries.md
│  │  ├─ context.md
│  │  └─ rules.md
│  └─ runtime/
│     ├─ contracts/
│     │  ├─ directive.md
│     │  ├─ evaluation.md
│     │  └─ safety.md
│     ├─ evaluation/
│     │  └─ scoring.md
│     └─ roles/
│        ├─ executive.md
│        ├─ planner.md
│        └─ supervisor.md
├─ alembic/                          # [Phase 2, 4]
│  ├─ versions/
│  │  ├─ 001_initial_schema.py
│  │  └─ 002_expand_directive_schema.py  # [Phase 4]
│  ├─ env.py
│  └─ script.py.mako
├─ docs/
│  ├─ decisions/
│  │  ├─ adr-001-agent-runtime.md
│  │  └─ adr-002-llm-native-repo-structure.md
│  ├─ glossary/
│  │  ├─ glossary.md
│  │  └─ markdown-glossary.md
│  ├─ architecture.md
│  ├─ invariants.md
│  ├─ models.md
│  └─ vision.md
├─ prompts/
│  ├─ agents/
│  ├─ system/
│  └─ workflows/
├─ scripts/
│  ├─ validate_schema.py             # [Phase 2]
│  └─ validate_directives.py         # [Phase 4]
├─ skills/
├─ src/
│  ├─ __init__.py                    # [Phase 2]
│  ├─ agents/
│  ├─ evaluation/
│  ├─ infra/
│  │  ├─ __init__.py                 # [Phase 2]
│  │  ├─ db/                         # [Phase 2]
│  │  │  ├─ __init__.py
│  │  │  ├─ engine.py
│  │  │  ├─ session.py
│  │  │  └─ tables.py
│  │  ├─ directives/                 # [Phase 4]
│  │  │  ├─ __init__.py
│  │  │  ├─ lifecycle.py
│  │  │  └─ schema.py
│  │  └─ models/                     # [Phase 2]
│  │     ├─ __init__.py
│  │     ├─ governance.py
│  │     ├─ memory.py
│  │     └─ artifacts.py
│  ├─ memory/
│  └─ workflows/
├─ tests/
├─ .env.example                      # [Phase 2]
├─ .gitignore                        # [Phase 2]
├─ alembic.ini                       # [Phase 2]
├─ CLAUDE.md
├─ docker-compose.yml
├─ implementation-plan.md
├─ pyproject.toml                    # [Phase 2]
└─ README.md
```

### Rule

> Nothing in `src/` imports from `ai/runtime/` directly.
> Execution code must not reason. Cognition must not execute.
> **This boundary is sacred.**

---

## PHASE 1 — Infrastructure Spine (Day 1) — COMPLETE

### Goal


### Status: COMPLETE


### Components

- Postgres
- Temporal server + UI
- OpenTelemetry collector (baseline)
- Python service container (idle)

### docker-compose.yml services

---

## PHASE 2 — 

...
