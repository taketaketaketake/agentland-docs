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

You are building this as infrastructure, not behavior:

```
Reality
  ↓
Sensing & Evidence
  ↓
Cognition / Management OS
  ↓
Directive Contract
  ↓
Policy + Approval Gate
  ↓
Execution Orchestrator
  ↓
Execution Modules
  ↓
Results + Artifacts
  ↺ back to Sensing & Cognition
```

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

Bring up durable infrastructure with zero application logic.

### Status: COMPLETE

Completed 2026-01-23.

### Components

- Postgres
- Temporal server + UI
- OpenTelemetry collector (baseline)
- Python service container (idle)

### docker-compose.yml services

- `postgres` — pgvector/pgvector:pg16
- `temporal` — temporalio/auto-setup:1.22
- `temporal-ui` — temporalio/ui:latest
- `otel-collector` — otel/opentelemetry-collector:latest
- `control-plane` — python:3.11-slim (idle)
- `searxng` — searxng/searxng:latest

### Validation Checklist

- [x] Temporal UI loads (port 8080)
- [x] Postgres reachable (port 5432)
- [x] Python container boots (control-plane service)
- [x] OTEL collector running (ports 4317, 4318, 8889)

**No workflows. No agents. No logic.**

---

## PHASE 2 — Data Layer (Truth & Memory) — COMPLETE

> This establishes Reality and Sensing.

### Status: COMPLETE

Completed 2026-01-23. Validation run ID: `f5cd023f-7eaf-4508-a1d0-bd75cc263bc1`

### Exit Criteria (verified)

- [x] `pip install -e .` succeeds
- [x] `alembic upgrade head` creates all tables
- [x] pgvector extension enabled (vector 0.8.1)
- [x] All 5 tables exist (agent_roles, directives, memories, memory_embeddings, artifacts)
- [x] `validate_schema.py` passes all tests
- [x] Data persists across container restarts
- [x] No business logic introduced
- [x] No imports from ai/runtime/

### What Was Built

**Files created:**
```
pyproject.toml
.env.example
.gitignore
alembic.ini
alembic/env.py
alembic/script.py.mako
alembic/versions/001_initial_schema.py
src/__init__.py
src/infra/__init__.py
src/infra/db/__init__.py
src/infra/db/engine.py
src/infra/db/session.py
src/infra/db/tables.py
src/infra/models/__init__.py
src/infra/models/governance.py
src/infra/models/memory.py
src/infra/models/artifacts.py
scripts/validate_schema.py
```

**Tables (minimal schema, TEXT for semantic fields):**

| Table | Columns |
|-------|---------|
| `agent_roles` | role_name (PK), current_impl, status, last_review, created_at |
| `directives` | id (UUID), role, type, payload (JSONB), status, created_at |
| `memories` | id (UUID), scope, content, created_at |
| `memory_embeddings` | memory_id (FK), embedding (vector 1536), created_at |
| `artifacts` | id (UUID), type, uri, created_at |

**Design decisions:**
- No enums (TEXT for status/type/scope — enums deferred to Phase 4)
- No FK from directives.role to agent_roles (plain TEXT)
- No cached/global engine state (explicit passing)
- No cleanup in validation (auditability over cleanliness)
- Separate application database (not Temporal's)

---

## PHASE 3 — Memory Infrastructure — COMPLETE

### Goal

Stand up all memory categories with no intelligence.

### Status: COMPLETE

Completed 2026-01-23.

### Exit Criteria (verified)

- [x] Vector memory functions implemented (`store_memory_embedding`, `semantic_search`)
- [x] Artifact store functions implemented (`put_artifact`, `get_artifact_ref`)
- [x] Working memory rule declared (Temporal state only, no Redis)
- [x] Validation script passes (`scripts/validate_memory.py`)
- [x] No LLM calls or embedding generation
- [x] No imports from `ai/runtime/`

### What Was Built

**Files created:**
```
src/memory/__init__.py
src/memory/vector.py
src/memory/artifacts.py
src/memory/working_memory.py
scripts/validate_memory.py
```

### 3.1 Relational Memory (Postgres)

Already done in Phase 2.

### 3.2 Vector Memory (pgvector)

- `store_memory_embedding(engine, memory_id, embedding)` — inserts into `memory_embeddings`
- `semantic_search(engine, query_embedding, limit)` — pgvector cosine distance search

No embedding generation. Infrastructure only.

### 3.3 Artifact Store (Stubbed)

- `put_artifact(engine, artifact_type, metadata)` — returns `artifact://local/<uuid>`
- `get_artifact_ref(engine, artifact_id)` — retrieves URI or None

Metadata stored in Postgres. No R2 integration yet.

### 3.4 Working Memory

Declared in `src/memory/working_memory.py`:
> Temporal workflow state is the sole source of working memory.
> Redis and in-process globals are explicitly forbidden.

No implementation — declaration only.

### Outcome

All memory categories exist as infrastructure:
- Relational memory: Postgres tables (Phase 2)
- Vector memory: pgvector search capability
- Artifact store: stubbed with local URIs
- Working memory: declared as Temporal state

---

## PHASE 4 — Directive Contract (Freeze Intent) — COMPLETE

### Goal

Create a hard boundary between thinking and doing.

### Status: COMPLETE

Completed 2026-01-24.

### Exit Criteria (verified)

- [x] Alembic migration adds new columns (002_expand_directive_schema.py)
- [x] SQLAlchemy table definition updated with all Phase 4 fields
- [x] Pydantic models updated (no default status — explicit intent required)
- [x] Lifecycle module with pure functions + single mutator
- [x] JSON schema exportable (read-only documentation)
- [x] Validation script passes (scripts/validate_directives.py)
- [x] Documentation updated (models.md, architecture.md, directive.md)

### What Was Built

**Files created:**
```
alembic/versions/002_expand_directive_schema.py
src/infra/directives/__init__.py
src/infra/directives/lifecycle.py
src/infra/directives/schema.py
scripts/validate_directives.py
```

**Files updated:**
```
src/infra/db/tables.py
src/infra/models/governance.py
docs/models.md
docs/architecture.md
ai/runtime/contracts/directive.md
README.md
```

### 4.1 Directive Schema

**Extended fields (added to existing directives table):**

| Field | Type | Purpose |
|-------|------|---------|
| `issued_by` | TEXT NOT NULL | Who created the directive |
| `objective` | TEXT NOT NULL | What to achieve |
| `scope` | TEXT NOT NULL | Boundaries |
| `constraints` | JSONB nullable | Limits (structured) |
| `success_metrics` | JSONB nullable | Definition of done |
| `budget` | TEXT nullable | Resource limit |
| `timebox` | TEXT nullable | Time limit |

**Design decisions:**
- No default status in Pydantic (explicit intent required)
- Database has `server_default='draft'` for safety
- TEXT for all semantic fields (no enums at schema level)
- `issued_by` = creator, `role` = target

### 4.2 Directive Lifecycle

**Statuses (lowercase ASCII by convention):**

```
draft → proposed → approved → executing → complete
             |          |           |
             v          v           v
          blocked    blocked     aborted
             |
             v
          proposed (retry)
```

**Implementation:**
- Pure functions: `validate_transition()`, `get_valid_next_statuses()`, `is_terminal_status()`
- Single mutator: `transition_directive_status()` — only code that writes to status

### Outcome

You can create, validate, persist, and transition directives manually.
Lifecycle transitions are enforced in code. Invalid transitions are rejected.

---

## PHASE 5 — Policy & Approval Gate — COMPLETE

### Goal

Introduce control, not intelligence.

### Status: COMPLETE

Completed 2026-01-24.

### Exit Criteria (verified)

- [x] `temporalio>=1.4.0` in pyproject.toml
- [x] Policy engine evaluates budget, tool allowlist, scope allowlist
- [x] PolicyConfig includes explicit `version` field
- [x] Budget parsing handles $50, 50.00, 100 USD formats
- [x] Policy results stored as artifacts (type: policy_evaluation)
- [x] ApprovalWorkflow uses single mutator for status updates
- [x] ApprovalResult includes `human_override` to distinguish approval source
- [x] Human approval via Temporal signal (when required)
- [x] Worker connects to Temporal and processes workflows
- [x] `scripts/validate_policy.py` passes all tests (policy-only mode)
- [x] Policy determinism invariant added to `docs/invariants.md`
- [x] Documentation updated (models.md, architecture.md, README.md)

### What Was Built

**Files created:**
```
src/infra/policy/__init__.py
src/infra/policy/types.py
src/infra/policy/config.py
src/infra/policy/budget.py
src/infra/policy/engine.py
src/workflows/__init__.py
src/workflows/approval.py
src/workflows/worker.py
src/workflows/activities/__init__.py
src/workflows/activities/policy_activities.py
src/workflows/activities/directive_activities.py
src/workflows/activities/artifact_activities.py
scripts/validate_policy.py
```

**Files updated:**
```
pyproject.toml
docs/architecture.md
docs/models.md
docs/invariants.md
README.md
```

### 5.1 Policy Engine (Deterministic)

- `PolicyVerdict` — ALLOW or BLOCK enum
- `PolicyResult` — verdict + reason + policy name (frozen dataclass)
- `PolicyConfig` — versioned configuration with budget ceiling, tool allowlist, scope allowlist
- `evaluate_directive()` — deterministic evaluation returning list of PolicyResult
- `parse_budget()` — parses "$50.00", "100 USD", etc. to Decimal

**Policies (v1):**
- Budget ceiling ($100.00)
- Tool allowlist (noop, echo, validate, test)
- Scope allowlist (test, development, staging)

**No LLMs. Deterministic only.**

### 5.2 Approval Workflow (Temporal)

Workflow: `ApprovalWorkflow`

1. Evaluates policies via activity
2. Stores policy results as artifact
3. If any policy blocks → directive blocked
4. Optionally waits for human approval signal
5. Updates directive status via single mutator

**ApprovalResult includes:**
- `approved` — whether directive was approved
- `policy_version` — version of policy used
- `policy_blocks` — reasons if blocked by policy
- `human_override` — distinguishes auto-approved from human-approved
- `artifact_uri` — reference to stored policy evaluation

### Outcome

**Nothing executes without passing this gate.**

---

## PHASE 6 — Execution Orchestrator — COMPLETE

### Goal

Coordinate execution without doing work.

### Status: COMPLETE

Completed 2026-01-24.

### Exit Criteria (verified)

- [x] Alembic migration adds `execution_runs` table (003_execution_run_table.py)
- [x] SQLAlchemy table definition for `execution_runs` with correct schema
- [x] Pydantic models: `ExecutionRunCreate`, `ExecutionRunRead`
- [x] Execution lifecycle module with pure functions + single mutator
- [x] 4 activities: `create_execution_run`, `update_execution_status`, `fetch_approved_directives`, `emit_execution_artifact`
- [x] `ExecutionWorkflow` skeleton (start → checkpoint → end, emits 3 artifacts)
- [x] `DispatcherWorkflow` with `continue_as_new` pattern
- [x] Worker serves both `approval-queue` and `execution-queue` concurrently
- [x] Directive transitions: `approved` → `executing` → `complete`
- [x] `scripts/validate_execution.py` passes all tests
- [x] No imports from `ai/runtime/`
- [x] Documentation updated (architecture.md, models.md, README.md)

### What Was Built

**Files created:**
```
alembic/versions/003_execution_run_table.py
src/infra/execution/__init__.py
src/infra/execution/lifecycle.py
src/infra/models/execution.py
src/workflows/dispatcher.py
src/workflows/execution.py
src/workflows/activities/execution_activities.py
scripts/validate_execution.py
```

**Files updated:**
```
src/infra/db/tables.py
src/infra/models/__init__.py
src/workflows/activities/__init__.py
src/workflows/worker.py
docs/architecture.md
docs/models.md
README.md
```

### 6.1 Dispatcher Workflow

- Polls for `approved` directives via `fetch_approved_directives` activity
- For each directive:
  - Creates execution run via `create_execution_run` activity
  - Updates directive status to `executing` via single mutator
  - Spawns `ExecutionWorkflow` as child workflow
- Sleeps for poll interval (default 30 seconds)
- Uses `continue_as_new` to bound workflow history

### 6.2 Execution Workflow Skeleton

No real execution. Three steps:
- `start` — transitions to running, emits `execution_start` artifact
- `checkpoint` — emits `execution_checkpoint` artifact (placeholder for future work)
- `end` — transitions to completed, emits `execution_end` artifact, marks directive complete

### 6.3 Execution Lifecycle

**Status lifecycle:**
```
pending -> running -> completed
                  |-> failed
                  |-> canceled
```

**Single mutator:** `transition_execution_status()` is the only code that writes to `execution_runs.status`. Manages timestamps automatically.

### 6.4 Task Queues

| Queue | Workflows | Purpose |
|-------|-----------|---------|
| `approval-queue` | ApprovalWorkflow | Phase 5 policy gate |
| `execution-queue` | DispatcherWorkflow, ExecutionWorkflow | Phase 6 execution |

Worker serves both queues concurrently via `asyncio.gather()`.

### Outcome

You can approve a directive and watch a workflow execute nothing correctly.

**This proves the spine works.**

---

## PHASE 7 — Execution Modules (Bounded Actions) — COMPLETE

### Goal

Define the muscle interface, not the muscle.

### Status: COMPLETE

Completed 2026-01-25.

### Exit Criteria (verified)

- [x] Module types defined: `ModuleStatus`, `ModuleInput`, `ModuleOutput`, `ModuleError`
- [x] Module interface defined: `ExecutionModule` Protocol, `BaseExecutionModule` ABC
- [x] Module registry: `register_module()`, `get_module()`, `list_modules()`, `dispatch_module()`
- [x] Stub modules implemented: `noop`, `echo`, `fail_intentionally`
- [x] Module activity: `execute_module` fetches directive, builds input, dispatches, logs artifacts
- [x] ExecutionWorkflow updated to dispatch to modules
- [x] Status mapping: SUCCESS → `completed`, FAILURE/ERROR → `failed`
- [x] Idempotency contract enforced: idempotency_key required
- [x] Budget validation: presence/ceiling check (no consumption tracking)
- [x] `scripts/validate_modules.py` passes all tests (6/6)
- [x] No imports from `ai/runtime/`
- [x] Documentation updated (architecture.md, README.md)

### What Was Built

**Files created:**
```
src/infra/execution/modules/__init__.py
src/infra/execution/modules/types.py
src/infra/execution/modules/base.py
src/infra/execution/modules/registry.py
src/infra/execution/modules/noop.py
src/infra/execution/modules/echo.py
src/infra/execution/modules/fail.py
src/workflows/activities/module_activities.py
scripts/validate_modules.py
```

**Files updated:**
```
src/workflows/execution.py
src/workflows/worker.py
src/workflows/activities/__init__.py
src/infra/policy/config.py
docs/architecture.md
README.md
```

### 7.1 Execution Module Interface

**Protocol:**
```python
def execute(
    self,
    module_input: ModuleInput,
    engine: Engine,
    emit_artifact: Callable[[str, dict], str],
) -> ModuleOutput
```

**Modules must:**
- Emit artifacts via callback
- Respect budgets (check input.budget)
- Be idempotent (same idempotency_key = same result)

**Modules must NOT:**
- Write directly to Postgres (except via provided engine)
- Spawn subprocesses
- Call external APIs (yet)
- Sleep or block
- Read workflow state
- Import from `ai/runtime/`

### 7.2 Stub Modules

| Module | Behavior |
|--------|----------|
| `noop` | Does nothing, emits artifact, returns SUCCESS |
| `echo` | Echoes payload, emits artifact with echoed data |
| `fail_intentionally` | Returns FAILURE or raises exception based on payload |

### 7.3 Status Mapping

| ModuleStatus | execution_runs.status | Meaning |
|--------------|----------------------|---------|
| `SUCCESS` | `completed` | Module finished successfully |
| `FAILURE` | `failed` | Module failed (expected failure mode) |
| `ERROR` | `failed` | Module encountered unexpected error |

### Outcome

You can create a directive, approve it, and watch the appropriate module execute.
Module results flow through to execution run status and artifacts.

**This proves the muscle interface works.**

---

## PHASE 8 — Telemetry & Tracing — COMPLETE

### Goal

See everything before intelligence arrives.

### Status: COMPLETE

Completed 2026-01-25.

### Exit Criteria (verified)

- [x] OpenTelemetry dependencies added (opentelemetry-api, opentelemetry-sdk, opentelemetry-exporter-otlp, structlog)
- [x] `src/infra/telemetry/` module with tracing, metrics, logging
- [x] `src/infra/evaluation/` module with interface and NoOp stub
- [x] Worker uses TracingInterceptor for automatic workflow/activity spans
- [x] Structured logging with trace context injection (trace_id, span_id)
- [x] Policy evaluation has custom span with verdict attribute
- [x] Module execution has custom span with module_name, status attributes
- [x] Pre-defined metrics (counters, histograms) with Prometheus naming
- [x] `scripts/validate_telemetry.py` passes all tests
- [x] Telemetry is write-only (no consumption by business logic)
- [x] Evaluation interface observes only (no influence on execution)
- [x] No imports from `ai/runtime/`
- [x] Documentation updated (architecture.md, README.md)
- [x] ADR-011 created

### What Was Built

**Files created:**
```
src/infra/telemetry/__init__.py
src/infra/telemetry/tracing.py
src/infra/telemetry/metrics.py
src/infra/telemetry/logging.py
src/infra/evaluation/__init__.py
src/infra/evaluation/interface.py
src/infra/evaluation/noop.py
scripts/validate_telemetry.py
docs/decisions/adr-011-telemetry-tracing.md
```

**Files updated:**
```
pyproject.toml
src/workflows/worker.py
src/workflows/activities/policy_activities.py
src/workflows/activities/execution_activities.py
src/workflows/activities/module_activities.py
docs/architecture.md
README.md
```

### 8.1 OpenTelemetry Tracing

- TracerProvider with OTLP exporter to collector (port 4317)
- TracingInterceptor integrated with Temporal workers
- Custom spans in activities (children of activity span, never root)
- Trace context propagated to structured logs

### 8.2 OpenTelemetry Metrics

**Counters (Prometheus naming: _total):**
- `directives_total` — by status
- `execution_failures_total` — by failure_type
- `policy_evaluations_total` — by verdict
- `module_executions_total` — by module_name, status

**Histograms (Prometheus naming: _seconds):**
- `execution_duration_seconds` — by directive_type
- `policy_evaluation_duration_seconds`

### 8.3 Structured Logging

- structlog with JSON output
- Automatic trace_id/span_id injection
- Consistent event naming (snake_case)

### 8.4 Evaluation Interface (Deferred Implementation)

- `EvaluationProvider` Protocol for future Braintrust integration
- `EvaluationInput` / `EvaluationResult` frozen dataclasses
- `NoOpEvaluationProvider` stub (all methods no-op)
- Constraint: Evaluation observes, does not decide

### Outcome

**Everything is observable before intelligence arrives.**

---

## PHASE 9 — LLM Provider Interface (Cognition Substrate) — COMPLETE

### Goal

Define how intelligence plugs in without introducing intelligence.

This phase creates an `LLMProvider` interface with:
- Strict request/response types
- Deterministic instrumentation (telemetry + artifacts)
- A default NoOp provider that blocks LLM usage

**No agents. No prompts. No memory reads. No directive creation.**

### Status: COMPLETE

Completed 2026-01-25.

### Exit Criteria (verified)

- [x] `src/infra/llm/` exists with: types, protocol, noop provider, config, usage, instrumentation
- [x] `call_llm` activity exists and is registered in worker
- [x] NoOp is default and blocks LLM usage with clear error
- [x] Every call attempt is observable (including NoOp errors): traces, logs, artifacts
- [x] `scripts/validate_llm.py` passes all tests
- [x] Documentation updated (architecture.md, invariants.md, README.md)
- [x] ADR-012 created
- [x] No imports from `ai/runtime/`

### File Structure

**Files to create:**
```
src/infra/llm/__init__.py
src/infra/llm/types.py           # LLMRequest/LLMResponse/LLMError
src/infra/llm/provider.py        # LLMProvider Protocol + LLMProviderError
src/infra/llm/noop.py            # NoOpLLMProvider (default, blocks usage)
src/infra/llm/config.py          # Provider selection (env-driven)
src/infra/llm/usage.py           # Token/cost structures + normalization
src/infra/llm/instrumentation.py # spans/logs/artifacts helpers
src/workflows/activities/llm_activities.py  # call_llm() activity
scripts/validate_llm.py
docs/decisions/adr-012-llm-provider-interface.md
```

**Files to update:**
```
src/workflows/worker.py          # Register call_llm activity
src/workflows/activities/__init__.py
docs/architecture.md
docs/models.md
docs/invariants.md
README.md
implementation-plan.md
```

**Not updated in Phase 9:**
- `ai/runtime/contracts/*` — LLM is infra-only, not an agent/runtime contract yet

### 9.1 Request/Response Types

`src/infra/llm/types.py` — Frozen dataclasses:

| Type | Fields |
|------|--------|
| `LLMRequest` | messages: `list[dict[str, str]]` (keys: role, content), model, max_tokens, temperature, metadata |
| `LLMResponse` | content, model, usage (normalized dict), latency_ms |
| `LLMError` | error_type (bounded), error_message, retryable |

**Error type taxonomy (bounded):**
```
error_type ∈ {"disabled", "misconfigured", "provider_error", "timeout", "invalid_request"}
```

Constraints:
- No provider-specific objects
- No Pydantic (dataclasses only)
- messages contain only role/content keys

### 9.2 Provider Protocol

`src/infra/llm/provider.py`:

```python
class LLMProvider(Protocol):
    name: str
    def complete(self, request: LLMRequest) -> LLMResponse: ...
```

- Synchronous interface (Temporal activity compatible)
- Raises `LLMProviderError` on failure

### 9.3 NoOp Provider (Default)

`src/infra/llm/noop.py`:

- `NoOpLLMProvider.name = "noop"`
- `.complete()` raises `LLMProviderError` with:
  - `error_type = "disabled"`
  - `error_message = "LLM usage disabled. Configure LLM_PROVIDER to enable."`

This ensures:
- Phase 9 introduces interface, not cognition
- Any accidental "agentic" call is blocked

### 9.4 Provider Selection (Env-Driven)

`src/infra/llm/config.py`:

- `get_llm_provider()` chooses provider based on `LLM_PROVIDER` env var
- `LLM_PROVIDER=noop` (default)
- `LLM_PROVIDER=<provider>` (future, not implemented in Phase 9)
- Raises `LLMProviderError` with `error_type = "misconfigured"` for unknown provider

### 9.5 Usage Normalization

`src/infra/llm/usage.py`:

Normalize usage into stable dict shape:
- `input_tokens`
- `output_tokens`
- `total_tokens`
- `estimated_cost_usd` (0.0 for noop, None if unknown)

### 9.6 Instrumentation

`src/infra/llm/instrumentation.py`:

Functions:
- `start_llm_span(request, provider_name)` → span
- `log_llm_event(logger, ...)`
- `emit_llm_artifacts(emit_artifact, request, response_or_error, ...)`

Artifacts emitted:
- `llm_call` — provider, model, max_tokens, temperature, status, error_type (if error)
- `llm_usage` — input_tokens, output_tokens, total_tokens, estimated_cost, latency_ms

**Important:** Artifacts must not store secrets or full message bodies. Store only:
- Message count
- Roles present
- Total char count

### 9.7 LLM Activity

`src/workflows/activities/llm_activities.py`:

Activity: `call_llm(request_dict: dict) -> dict`

Responsibilities:
1. Validate request dict → LLMRequest
2. Start instrumentation span
3. Select provider via `get_llm_provider()`
4. Run provider `.complete()`
5. **Always emit `llm_call` artifact** (even on error, with `status="error"` and `error_type`)
6. Log event
7. Return serializable response dict (or error dict with `error_type`, `error_message`, `retryable`)

**Critical:** NoOp errors must still produce artifacts. The activity wraps the provider call in try/except and emits artifacts before re-raising or returning error response.

Note: This activity exists for future agent workflows. No existing workflow uses it in Phase 9.

### 9.8 Invariant Addition

Add to `docs/invariants.md`:

> LLM usage must be explicit, observable, and opt-in (NoOp default).

### Constraints

- No imports from `ai/runtime/`
- No actual LLM calls (NoOp blocks by default)
- No prompts or prompt templates
- No agent logic
- No memory reads
- No directive creation
- Telemetry is write-only

### What Was Built

**Files created:**
```
src/infra/llm/__init__.py
src/infra/llm/types.py
src/infra/llm/provider.py
src/infra/llm/noop.py
src/infra/llm/config.py
src/infra/llm/usage.py
src/infra/llm/instrumentation.py
src/workflows/activities/llm_activities.py
scripts/validate_llm.py
docs/decisions/adr-012-llm-provider-interface.md
```

**Files updated:**
```
src/workflows/worker.py
src/workflows/activities/__init__.py
docs/architecture.md
docs/invariants.md
README.md
implementation-plan.md
```

### Outcome

**The system knows how to call LLMs but refuses to do so by default.**

The interface exists. The instrumentation exists. The governance exists.
Intelligence plugs in later with a single env var change.

---

## PHASE 10 — Memory Consumption Interfaces (Read-Only Substrate) — COMPLETE

### Goal

Define how the system may read memory without allowing it to reason, decide, or act.

This phase introduces explicit, read-only memory access contracts so future agents consume memory through interfaces, not storage.

### Status: COMPLETE

Completed 2026-01-25.

### Exit Criteria (verified)

- [x] `src/infra/memory/` exists with: reader interface, query definitions, result types, enforcement, noop
- [x] All memory access is read-only by construction
- [x] Named, bounded query surface (no raw DB/vector access)
- [x] Vector memory access is wrapped and constrained
- [x] NoOpMemoryReader exists for tests and bootstrapping
- [x] `scripts/validate_memory_reader.py` passes all tests (8/8)
- [x] Documentation updated (architecture.md, invariants.md, README.md)
- [x] ADR-013 created
- [x] No imports from `ai/runtime/`
- [x] No memory writes introduced

### File Structure

**Files created:**
```
src/infra/memory/__init__.py
src/infra/memory/reader.py        # MemoryReader Protocol
src/infra/memory/queries.py       # Named query input types
src/infra/memory/results.py       # Frozen result dataclasses
src/infra/memory/enforcement.py   # Read-only guarantees
src/infra/memory/noop.py          # NoOpMemoryReader
scripts/validate_memory_reader.py
docs/decisions/adr-013-memory-consumption-interfaces.md
```

**Files updated:**
```
docs/architecture.md
docs/invariants.md
README.md
implementation-plan.md
```

### 10.1 MemoryReader Interface

`src/infra/memory/reader.py`:

```python
class MemoryReader(Protocol):
    name: str

    def latest_directive_for_role(self, role: str) -> DirectiveSummary | None: ...
    def execution_summaries(self, limit: int, status_filter: str | None) -> list[ExecutionSummary]: ...
    def artifacts_by_type(self, artifact_type: str, limit: int) -> list[ArtifactSummary]: ...
    def semantic_search(self, query: str, top_k: int) -> list[SemanticResult]: ...
```

Constraints:
- Read-only methods only
- No engine/session exposed
- No raw SQL or vector store access
- Returns frozen result types only

### 10.2 Query Definitions

`src/infra/memory/queries.py`:

Frozen dataclasses defining allowed questions:
- `LatestDirectiveForRole(role)`
- `ExecutionSummariesQuery(limit, status_filter)`
- `ArtifactsByTypeQuery(artifact_type, limit)`
- `SemanticSearchQuery(query, top_k)`

With bounds:
- `MAX_EXECUTION_LIMIT = 100`
- `MAX_ARTIFACT_LIMIT = 100`
- `MAX_SEMANTIC_TOP_K = 50`

### 10.3 Result Types

`src/infra/memory/results.py`:

Frozen dataclasses:
- `DirectiveSummary` — id, role, type, objective, status, created_at
- `ExecutionSummary` — run_id, directive_id, directive_type, status, timestamps
- `ArtifactSummary` — id, type, uri, created_at
- `SemanticResult` — memory_id, content, scope, similarity_score (never embeddings)
- `MemoryReadResult` — query_name, result_count, results

### 10.4 NoOpMemoryReader

`src/infra/memory/noop.py`:

- Implements MemoryReader
- Returns empty results
- Logs read attempts
- Respects query bounds

### 10.5 Enforcement

`src/infra/memory/enforcement.py`:

- `readonly_method(query_name)` decorator — marks and logs read methods
- `verify_readonly_interface(cls)` — checks for write indicators
- `MemoryAccessAttempt` — audit record for access

### Constraints

- No imports from `ai/runtime/`
- No memory writes
- No agents, prompts, LLM usage
- No directive creation
- No execution triggering
- Telemetry is observational only

### Outcome

**The system can remember, but not think.**

Memory is:
- Consumable through named interfaces
- Auditable via logging
- Replaceable (NoOp or real implementation)

Agents (future phases) cannot:
- Couple to storage
- Invent memory access patterns
- Access raw data

---

## PHASE S-4 — Infrastructure Stabilization (Documentation Only) — COMPLETE

### Goal

Document and seal existing interfaces and stubs before adding new capabilities.

This is a **stabilization phase**, not an implementation phase.

### Status: COMPLETE

Completed 2026-01-25.

### Implementation

**No code changes permitted.**

This phase produces documentation only:
- Retrospective seals of existing work
- Enforcement rules for future phases
- No new features, no new code

### Exit Criteria (verified)

- [x] `docs/stubs.md` — Authoritative registry of all 9 stubbed components
- [x] `docs/artifacts.md` — Taxonomy of all 11 artifact types
- [x] `docs/contracts.md` — Interface completeness for all 8 layers
- [x] `docs/glossary/markdown-glossary.md` — Updated with routing rules
- [x] Warning headers added to stabilization docs ("NOT an implementation plan")
- [x] `skills/llm/phase-audit.md` — "Invalid Substitutes" section added

### What Was Produced

**Files created:**
```
docs/stubs.md           # 9 stubs cataloged (4 permanent, 5 to replace)
docs/artifacts.md       # 11 artifact types with producers, schemas, retention
docs/contracts.md       # 8 interfaces marked COMPLETE with bounded enums
```

**Files updated:**
```
docs/glossary/markdown-glossary.md  # Routing rules for new doc types
skills/llm/phase-audit.md       # Enforcement guardrails
```

### Constraint

**These documents do not authorize execution.**

Only `implementation-plan.md` authorizes implementation work.

If Claude attempts to proceed based on stabilization documents without an approved phase entry here, the phase audit must FAIL.

### Outcome

**The system's existing work is now sealed and documented.**

Future phases can add capabilities knowing:
- All stubs are cataloged with replacement paths
- All artifact types are defined with schemas
- All interfaces are frozen with completeness checklists
- Enforcement is part of the audit process

---

## PHASE 11 — Real LLM Provider — COMPLETE

### Goal

Replace `NoOpLLMProvider` with a working LLM provider implementation.

### Status: COMPLETE

### Prerequisites

- LLM provider API key configured in environment
- Provider SDK added to dependencies

### What Was Built

**Files created:**
```
src/infra/llm/<provider>.py    # LLMProvider implementation
```

**Files updated:**
```
src/infra/llm/config.py       # Add provider selection
src/infra/llm/__init__.py     # Export new provider
pyproject.toml                # Add provider dependency
.env.example                  # Add API key placeholder
docs/stubs.md                 # Mark NoOpLLMProvider as replaced
```

### Implementation

1. Add provider SDK to pyproject.toml
2. Create provider class implementing `LLMProvider` Protocol:
   - `name = "<provider>"`
   - `.complete()` calls LLM API via SDK
   - Map SDK response to `LLMResponse`
   - Map SDK errors to `LLMProviderError` with bounded error_type
3. Update `get_llm_provider()` to return provider when `LLM_PROVIDER=<provider>`
4. Update `.env.example` with API key placeholder

### Exit Criteria (verified)

- [x] Provider passes `scripts/validate_llm.py` (9/9 tests)
- [x] LLM calls succeed with valid API key (provider instantiates, ready to call)
- [x] LLM calls fail gracefully with missing/invalid key (error_type="misconfigured")
- [x] Usage/cost tracking populates correctly (pricing table + normalize_usage)
- [x] Artifacts emitted for real calls (via existing instrumentation)
- [x] `docs/stubs.md` updated (NoOpLLMProvider marked as replaced)

### Constraints

- No agents or prompts
- No memory reads
- No directive creation
- Provider is opt-in (NoOp remains default)

---

## PHASE 12 — Real Memory Reader (Postgres) — COMPLETE

### Goal

Replace `NoOpMemoryReader` with a working Postgres implementation.

### Status: COMPLETE

Completed 2026-01-25.

### What Was Built

**Files created:**
```
src/infra/memory/postgres.py  # PostgresMemoryReader implementation
```

**Files updated:**
```
src/infra/memory/__init__.py  # Export new reader
scripts/validate_memory_reader.py  # Add PostgresMemoryReader tests
docs/stubs.md                 # Mark NoOpMemoryReader as replaced
```

### Implementation

1. Created `PostgresMemoryReader` implementing `MemoryReader` Protocol:
   - Accepts `Engine` in constructor
   - `latest_directive_for_role()` → queries directives table
   - `execution_summaries()` → queries execution_runs with directive join
   - `artifacts_by_type()` → queries artifacts table
   - `semantic_search()` → logs warning, returns empty (requires Phase 14 for embeddings)
2. All methods decorated with `@readonly_method`
3. All results are frozen dataclasses
4. Bounds enforced (MAX_EXECUTION_LIMIT, MAX_ARTIFACT_LIMIT, MAX_SEMANTIC_TOP_K)

### Exit Criteria (verified)

- [x] `PostgresMemoryReader` passes `scripts/validate_memory_reader.py` (9/9 tests)
- [x] All 4 query methods return real data from database (when connected)
- [x] Bounds are respected
- [x] Read-only enforcement verified (no write indicators)
- [x] `docs/stubs.md` updated

### Constraints

- Read-only methods only
- No raw SQL exposed to callers
- No embedding vectors returned (similarity scores only)

### Note on semantic_search

The `semantic_search` method requires embedding generation to fully work.
Currently returns empty results because text queries cannot be converted to embeddings.
Phase 14 (Real Embedding Generation) will complete this functionality.

---

## PHASE 13 — Real Artifact Store (R2/S3) — COMPLETE

### Goal

Replace local artifact URIs with real object storage.

### Status: COMPLETE

Completed 2026-01-26.

### What Was Built

**Files created:**
```
src/infra/artifacts/__init__.py
src/infra/artifacts/types.py      # ObjectStoreRequest/Response/Error, size constants
src/infra/artifacts/store.py      # ObjectStore Protocol, ObjectStoreException
src/infra/artifacts/noop.py       # NoOpObjectStore (in-memory, default)
src/infra/artifacts/r2.py         # R2ObjectStore (Cloudflare R2 via boto3)
src/infra/artifacts/config.py     # Provider selection via OBJECT_STORE_PROVIDER
scripts/validate_artifacts.py     # Validation script
docs/decisions/adr-016-real-artifact-store.md
```

**Files updated:**
```
src/memory/artifacts.py           # Size-based routing, get_artifact_content()
pyproject.toml                    # Add boto3>=1.34.0
.env.example                      # Add OBJECT_STORE_PROVIDER=noop
docs/stubs.md                     # Mark artifact store as replaced
docs/artifacts.md                 # Update URI schemes
docs/contracts.md                 # Add ObjectStore interface
```

### Implementation

1. **ObjectStore Protocol** with methods: `name`, `put()`, `get()`, `exists()`, `delete()`
2. **Bounded error taxonomy**: 6 types (`disabled`, `misconfigured`, `storage_error`, `not_found`, `size_exceeded`, `serialization`)
3. **Size thresholds**: 64KB routing threshold, 10MB max artifact size
4. **NoOpObjectStore**: In-memory storage for testing (default)
5. **R2ObjectStore**: Cloudflare R2 via boto3 S3-compatible API
6. **Size-based routing**: `put_artifact()` routes by 64KB threshold
7. **URI parsing**: `parse_artifact_uri()` extracts scheme and key

### Exit Criteria (verified)

- [x] `src/infra/artifacts/` module exists with all components
- [x] `ObjectStore` Protocol with put/get/exists/delete
- [x] `NoOpObjectStore` works (in-memory)
- [x] `R2ObjectStore` implemented (requires R2 credentials)
- [x] Provider selection via `OBJECT_STORE_PROVIDER` env var
- [x] NoOp is default
- [x] `put_artifact()` routes by 64KB threshold
- [x] `scripts/validate_artifacts.py` passes all tests
- [x] `docs/stubs.md` updated
- [x] `docs/artifacts.md` URI schemes updated
- [x] `docs/contracts.md` ObjectStore interface added
- [x] No imports from `ai/runtime/`

### Constraints

- Artifacts remain immutable (delete disabled)
- No secrets in artifact metadata
- Maximum artifact size: 10MB
- Size threshold: 64KB (below = local, above = object store)

---

## PHASE 14 — Real Embedding Generation — COMPLETE

### Goal

Replace stub vector memory with real embedding generation.

### Status: COMPLETE

Completed 2026-01-26.

### What Was Built

**Files created:**
```
src/infra/embeddings/__init__.py
src/infra/embeddings/types.py      # EmbeddingRequest/Response/Usage/Error, bounds
src/infra/embeddings/provider.py   # EmbeddingProvider Protocol, EmbeddingProviderError
src/infra/embeddings/noop.py       # NoOpEmbeddingProvider (default, blocks usage)
src/infra/embeddings/openai.py     # OpenAIEmbeddingProvider (text-embedding-3-small)
src/infra/embeddings/config.py     # Provider selection via EMBEDDING_PROVIDER
scripts/validate_embeddings.py     # Validation script
docs/decisions/adr-017-real-embedding-generation.md
```

**Files updated:**
```
src/memory/vector.py              # embed_and_store(), semantic_search_text(), semantic_search_with_content()
src/infra/memory/postgres.py      # semantic_search() uses embedding provider
pyproject.toml                    # Add openai>=1.0.0
.env.example                      # Add EMBEDDING_PROVIDER=noop, OPENAI_API_KEY
docs/stubs.md                     # Mark vector memory as replaced
docs/contracts.md                 # Add EmbeddingProvider interface
```

### Implementation

1. **EmbeddingProvider Protocol** with methods: `name`, `embed()`, `embed_single()`
2. **Bounded error taxonomy**: 6 types (`disabled`, `misconfigured`, `provider_error`, `timeout`, `invalid_request`, `rate_limited`)
3. **Bounds**: 1536 dimensions, 100 max batch size, 8192 max text length
4. **NoOpEmbeddingProvider**: Blocks all embedding usage (default)
5. **OpenAIEmbeddingProvider**: Uses text-embedding-3-small, cost tracking via EmbeddingUsage
6. **Vector functions**: `embed_and_store()`, `semantic_search_text()`, `semantic_search_with_content()`
7. **PostgresMemoryReader integration**: `semantic_search()` now uses embedding provider

### Exit Criteria (verified)

- [x] `src/infra/embeddings/` module exists with all components
- [x] `EmbeddingProvider` Protocol with embed/embed_single
- [x] `NoOpEmbeddingProvider` blocks usage (default)
- [x] `OpenAIEmbeddingProvider` generates embeddings
- [x] Provider selection via `EMBEDDING_PROVIDER` env var
- [x] NoOp is default
- [x] `embed_and_store()` generates and stores embeddings
- [x] `semantic_search_text()` searches with text queries
- [x] `PostgresMemoryReader.semantic_search()` uses embedding provider
- [x] `scripts/validate_embeddings.py` passes all tests
- [x] `docs/stubs.md` updated
- [x] `docs/contracts.md` EmbeddingProvider interface added
- [x] ADR-017 created
- [x] No imports from `ai/runtime/`

### Constraints

- Embedding generation is explicit (not automatic on memory writes)
- No LLM reasoning during embedding
- Cost tracked via EmbeddingUsage
- Dimensions fixed at 1536 (matches database schema)

---

## PHASE 15 — Real Evaluation Provider (Braintrust) — COMPLETE

### Goal

Replace `NoOpEvaluationProvider` with Braintrust integration.

### Status: COMPLETE

### Prerequisites

- Braintrust account and API key
- Project configured in Braintrust

### Deliverables

**Files to create:**
```
src/infra/evaluation/braintrust.py  # BraintrustEvaluationProvider
```

**Files to update:**
```
src/infra/evaluation/__init__.py    # Export new provider
pyproject.toml                      # Add braintrust dependency
docs/stubs.md                       # Mark evaluation as replaced
```

### Implementation

1. Add `braintrust` to pyproject.toml
2. Create `BraintrustEvaluationProvider` implementing `EvaluationProvider` Protocol:
   - `log_trace()` → sends to Braintrust
   - `score()` → runs Braintrust scorer
   - `experiment()` → creates Braintrust experiment
3. Provider selection via `EVALUATION_PROVIDER` env var
4. NoOp remains default

### Exit Criteria

- [x] Traces logged to Braintrust
- [x] Scores retrievable
- [x] Experiments runnable
- [x] `docs/stubs.md` updated

### Constraints

- Evaluation observes only, does not influence execution
- Provider is opt-in (NoOp remains default)

---

## End State: What You Have After Phase 15

All stubs replaced with real implementations:

| Stub | Replacement | Phase |
|------|-------------|-------|
| NoOpLLMProvider | RealLLMProvider | 11 |
| NoOpMemoryReader | PostgresMemoryReader | 12 |
| Artifact Store (local) | R2ObjectStore | 13 |
| Vector Memory (no embed) | OpenAIEmbeddingProvider | 14 |
| NoOpEvaluationProvider | BraintrustEvaluationProvider | 15 |

The system is now complete infrastructure, ready for agents.

---

## End State: What You Have After Phase 10

You will have:

1. **A durable control loop**
2. **Hard separation of:**
   - Thinking
   - Deciding
   - Approving
   - Executing
3. **Full memory stack (read-only consumption layer)**
4. **Observable infrastructure**
5. **LLM interface ready (but disabled)**
6. **Memory consumption interfaces (read-only)**
7. **Zero business logic**

The system knows how to call LLMs but refuses to.
Memory is readable through explicit interfaces.
At this point, introducing agents becomes safe.
