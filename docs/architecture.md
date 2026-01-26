# Architecture

## Current State (as of Phase 14)

### Implemented

- **Postgres** (pgvector/pgvector:pg16)
  - Source of truth for all persistent state
  - pgvector extension enabled for semantic memory
  - Separate `agentland` database (not shared with Temporal)

- **SQLAlchemy Core**
  - Table definitions in `src/infra/db/tables.py`
  - No ORM — explicit queries only

- **Alembic**
  - Migration system configured
  - Migrations:
    - `001_initial_schema.py` — initial tables
    - `002_expand_directive_schema.py` — Phase 4 directive fields
    - `003_execution_run_table.py` — Phase 6 execution runs

- **Pydantic**
  - Create/Read models in `src/infra/models/`
  - I/O contracts only — no business logic

- **Memory Infrastructure** (Phase 3)
  - Vector memory: `src/memory/vector.py`
    - `store_memory_embedding()` — stores embedding vectors
    - `semantic_search()` — pgvector cosine distance search
  - Artifact store: `src/memory/artifacts.py`
    - `put_artifact()` — stores metadata, returns URI
    - `get_artifact_ref()` — retrieves URI by ID
  - Working memory: declared as Temporal workflow state (no separate implementation)

- **Directive Contract** (Phase 4)
  - Hard boundary between thinking and doing
  - Expanded schema: `issued_by`, `objective`, `scope`, `constraints`, `success_metrics`, `budget`, `timebox`
  - Lifecycle enforcement: `src/infra/directives/lifecycle.py`
    - Pure functions: `validate_transition()`, `get_valid_next_statuses()`, `is_terminal_status()`
    - Single mutator: `transition_directive_status()` — only code that writes to `directives.status`
  - Status lifecycle: `draft` → `proposed` → `approved` → `executing` → `complete` (+ `blocked`, `aborted`)
  - JSON schema export: `get_directive_json_schema()` — read-only documentation

- **Policy & Approval Gate** (Phase 5)
  - Policy engine: `src/infra/policy/`
    - `PolicyVerdict` — ALLOW or BLOCK
    - `PolicyResult` — verdict + reason + policy name
    - `PolicyConfig` — versioned configuration
    - `evaluate_directive()` — deterministic policy evaluation
    - Budget parsing: `$50.00`, `100 USD`, etc.
  - Approval workflow: `src/workflows/approval.py`
    - `ApprovalWorkflow` — Temporal workflow for execution gating
    - `ApprovalResult` — outcome with `human_override` flag
    - Human approval via Temporal signals
  - Activities: `src/workflows/activities/`
    - `evaluate_policies` — runs policy engine
    - `update_directive_status` — uses single mutator
    - `store_policy_artifact` — persists evaluation results

- **Execution Orchestrator** (Phase 6)
  - Execution runs: `src/infra/execution/`
    - `execution_runs` table — tracks execution attempts
    - Lifecycle: `pending` → `running` → `completed` (+ `failed`, `canceled`)
    - Single mutator: `transition_execution_status()` — only code that writes to `execution_runs.status`
  - Dispatcher workflow: `src/workflows/dispatcher.py`
    - `DispatcherWorkflow` — polls for approved directives
    - Uses `continue_as_new` to bound workflow history
    - Spawns `ExecutionWorkflow` as child workflows
  - Execution workflow: `src/workflows/execution.py`
    - `ExecutionWorkflow` — dispatches to modules, sets status based on result
    - Emits artifacts (input, output, module-specific)
    - Transitions directive to `complete` (execution finished, not success evaluation)
  - Activities: `src/workflows/activities/execution_activities.py`
    - `create_execution_run` — creates run record
    - `update_execution_status` — single mutator
    - `fetch_approved_directives` — polls for work
    - `emit_execution_artifact` — stores execution artifacts
  - Worker: serves both `approval-queue` and `execution-queue` concurrently

- **Execution Modules** (Phase 7)
  - Module interface: `src/infra/execution/modules/`
    - `ModuleInput` — frozen dataclass with run_id, directive_id, directive_type, payload, idempotency_key, budget, timebox, constraints
    - `ModuleOutput` — frozen dataclass with status (SUCCESS/FAILURE/ERROR), result, message, artifacts, budget_consumed, duration_ms
    - `ModuleStatus` — enum: SUCCESS, FAILURE, ERROR
    - `ExecutionModule` — Protocol defining module interface
    - `BaseExecutionModule` — ABC with `_check_budget()` helper
  - Module registry: `src/infra/execution/modules/registry.py`
    - `register_module()` — registers module in global registry
    - `get_module()` — retrieves module by name
    - `list_modules()` — lists all registered modules
    - `dispatch_module()` — selects module by directive.type, handles errors
  - Stub modules (prove wiring works):
    - `noop` — does nothing, emits artifact, returns SUCCESS
    - `echo` — echoes payload, emits artifact with echoed data
    - `fail_intentionally` — returns FAILURE or raises exception based on payload
  - Module activity: `src/workflows/activities/module_activities.py`
    - `execute_module` — fetches directive, builds ModuleInput, dispatches, logs artifacts
  - Status mapping: SUCCESS → `completed`, FAILURE/ERROR → `failed`
  - Idempotency contract: idempotency_key required, dispatch refuses without it
  - Budget semantics: presence/ceiling validation only (no consumption tracking)

- **Telemetry & Tracing** (Phase 8)
  - OpenTelemetry tracing: `src/infra/telemetry/tracing.py`
    - `init_tracing()` — configures TracerProvider with OTLP exporter
    - `get_tracer()` — returns tracer for custom spans
    - `shutdown_tracing()` — graceful shutdown
    - TracingInterceptor integrated with Temporal workers
  - OpenTelemetry metrics: `src/infra/telemetry/metrics.py`
    - `init_metrics()` — configures MeterProvider with OTLP exporter
    - Pre-defined metrics (Prometheus naming conventions):
      - `directives_total` (Counter) — by status
      - `execution_failures_total` (Counter) — by failure_type
      - `policy_evaluations_total` (Counter) — by verdict
      - `module_executions_total` (Counter) — by module_name, status
      - `execution_duration_seconds` (Histogram) — by directive_type
      - `policy_evaluation_duration_seconds` (Histogram)
  - Structured logging: `src/infra/telemetry/logging.py`
    - `init_logging()` — configures structlog with JSON output
    - Trace context injection (trace_id, span_id in logs)
    - `get_logger()` — returns bound logger
  - Evaluation interface: `src/infra/evaluation/`
    - `EvaluationInput` — frozen dataclass for scoring input
    - `EvaluationResult` — frozen dataclass with score, dimensions, metadata
    - `EvaluationProvider` — Protocol for evaluation providers
    - `NoOpEvaluationProvider` — stub for future Braintrust integration
  - Constraint: Telemetry is write-only (APIs must not be consumed by business logic)
  - Constraint: Evaluation observes, does not decide (no influence on execution or state)

- **LLM Provider Interface** (Phase 9)
  - LLM types: `src/infra/llm/types.py`
    - `LLMRequest` — frozen dataclass with messages, model, max_tokens, temperature, metadata
    - `LLMResponse` — frozen dataclass with content, model, usage, latency_ms
    - `LLMError` — frozen dataclass with error_type (bounded), error_message, retryable
  - Provider protocol: `src/infra/llm/provider.py`
    - `LLMProvider` — Protocol with `name` property and `complete()` method
    - `LLMProviderError` — exception with error_type, error_message, retryable
  - NoOp provider: `src/infra/llm/noop.py`
    - `NoOpLLMProvider` — default provider that blocks LLM usage
    - Raises `LLMProviderError` with `error_type="disabled"`
  - Provider config: `src/infra/llm/config.py`
    - `get_llm_provider()` — selects provider via `LLM_PROVIDER` env var
    - Default: `noop` (blocks all LLM calls)
  - Usage normalization: `src/infra/llm/usage.py`
    - Stable dict shape: input_tokens, output_tokens, total_tokens, estimated_cost_usd
  - Instrumentation: `src/infra/llm/instrumentation.py`
    - `start_llm_span()` — creates child span for LLM calls
    - `emit_llm_artifacts()` — emits llm_call and llm_usage artifacts
    - Artifacts store metadata only (no secrets, no full message bodies)
  - Activity: `src/workflows/activities/llm_activities.py`
    - `call_llm` — validates request, calls provider, emits artifacts (even on error)
  - Constraint: LLM usage must be explicit, observable, and opt-in (NoOp default)
  - Constraint: No imports from `ai/runtime/` — LLM is infra, not agent logic

- **Memory Consumption Interfaces** (Phase 10)
  - Reader protocol: `src/infra/memory/reader.py`
    - `MemoryReader` — Protocol with read-only methods
    - `latest_directive_for_role()`, `execution_summaries()`, `artifacts_by_type()`, `semantic_search()`
  - Query definitions: `src/infra/memory/queries.py`
    - Named, bounded query types: `LatestDirectiveForRole`, `SemanticSearchQuery`, etc.
    - Hard caps: `MAX_EXECUTION_LIMIT=100`, `MAX_ARTIFACT_LIMIT=100`, `MAX_SEMANTIC_TOP_K=50`
  - Result types: `src/infra/memory/results.py`
    - Frozen dataclasses: `DirectiveSummary`, `ExecutionSummary`, `ArtifactSummary`, `SemanticResult`
    - Similarity scores returned, embeddings never exposed
  - Enforcement: `src/infra/memory/enforcement.py`
    - `readonly_method()` decorator — logs and marks read methods
    - `verify_readonly_interface()` — checks for write indicators
  - NoOp reader: `src/infra/memory/noop.py`
    - `NoOpMemoryReader` — returns empty results, logs access
  - Constraint: Read-only by construction (no write methods in interface)
  - Constraint: Named queries only (no raw SQL, no free-form access)
  - Constraint: No imports from `ai/runtime/`

- **Real LLM Provider** (Phase 11)
  - Anthropic provider: `src/infra/llm/anthropic.py`
    - `AnthropicLLMProvider` — implements LLMProvider Protocol
    - Lazy client initialization
    - Error classification mapping to bounded error_type
  - Usage tracking: Pricing table for Claude models
    - `normalize_usage()` with cost estimation
  - Provider selection: `LLM_PROVIDER=anthropic` to enable
  - Constraint: NoOp remains default for safety

- **Real Memory Reader** (Phase 12)
  - Postgres reader: `src/infra/memory/postgres.py`
    - `PostgresMemoryReader` — implements MemoryReader Protocol
    - Queries directives, execution_runs, artifacts tables
    - All methods decorated with `@readonly_method`
  - Semantic search: Returns empty results (requires embedding provider)
  - Constraint: Read-only enforcement via decorator

- **Real Artifact Store** (Phase 13)
  - ObjectStore protocol: `src/infra/artifacts/store.py`
    - `ObjectStore` — Protocol with put/get/exists/delete methods
    - `ObjectStoreException` — bounded error taxonomy (6 types)
  - Types: `src/infra/artifacts/types.py`
    - `ObjectStoreRequest`, `ObjectStoreResponse`, `RetrievedObject`
    - Size constants: 64KB threshold, 10MB max
  - NoOp store: `src/infra/artifacts/noop.py`
    - `NoOpObjectStore` — in-memory storage for testing (default)
    - Returns `artifact://noop/{key}` URIs
  - R2 store: `src/infra/artifacts/r2.py`
    - `R2ObjectStore` — Cloudflare R2 via boto3
    - Returns `artifact://r2/{bucket}/{key}` URIs
  - Provider config: `src/infra/artifacts/config.py`
    - `OBJECT_STORE_PROVIDER` env var (noop, r2)
  - Size routing: `src/memory/artifacts.py`
    - < 64KB → local storage
    - >= 64KB → object store
  - Constraint: Artifacts are immutable (delete raises disabled error)

- **Real Embedding Generation** (Phase 14)
  - EmbeddingProvider protocol: `src/infra/embeddings/provider.py`
    - `EmbeddingProvider` — Protocol with embed/embed_single methods
    - `EmbeddingProviderError` — bounded error taxonomy (6 types)
  - Types: `src/infra/embeddings/types.py`
    - `EmbeddingRequest`, `EmbeddingResponse`, `EmbeddingUsage`
    - Bounds: 1536 dimensions, 100 batch size, 8192 text length
  - NoOp provider: `src/infra/embeddings/noop.py`
    - `NoOpEmbeddingProvider` — blocks embedding usage (default)
  - OpenAI provider: `src/infra/embeddings/openai.py`
    - `OpenAIEmbeddingProvider` — text-embedding-3-small
    - Cost tracking via EmbeddingUsage
  - Provider config: `src/infra/embeddings/config.py`
    - `EMBEDDING_PROVIDER` env var (noop, openai)
  - Vector functions: `src/memory/vector.py`
    - `embed_and_store()` — generate and store embedding
    - `semantic_search_text()` — search with text query
    - `semantic_search_with_content()` — search with full content
  - Integration: `src/infra/memory/postgres.py`
    - `PostgresMemoryReader.semantic_search()` uses embedding provider
  - Constraint: Embedding generation is explicit (not automatic on writes)

### Not Yet Implemented
- Agents
- Intelligence (LLM interface exists but is disabled by default)

## Layers

```
┌─────────────────────────────────────────┐
│           Cognition (future)            │  ← Agents reason here
├─────────────────────────────────────────┤
│      Directive Contract (Phase 4) ✓     │
│  ┌─────────────────────────────────┐    │
│  │ Intent frozen as directives     │    │
│  │ Lifecycle: draft→...→complete   │    │
│  │ Single mutator for status       │    │
│  └─────────────────────────────────┘    │
├─────────────────────────────────────────┤
│      Policy + Approval (Phase 5) ✓      │
│  ┌─────────────────────────────────┐    │
│  │ Deterministic policy engine     │    │
│  │ ApprovalWorkflow (Temporal)     │    │
│  │ Human approval via signals      │    │
│  └─────────────────────────────────┘    │
├─────────────────────────────────────────┤
│    Execution Orchestrator (Phase 6) ✓   │
│  ┌─────────────────────────────────┐    │
│  │ DispatcherWorkflow (polling)    │    │
│  │ ExecutionWorkflow (dispatch)    │    │
│  │ Execution runs lifecycle        │    │
│  └─────────────────────────────────┘    │
├─────────────────────────────────────────┤
│      Execution Modules (Phase 7) ✓      │
│  ┌─────────────────────────────────┐    │
│  │ Module interface (Protocol)     │    │
│  │ Registry + dispatch             │    │
│  │ Stub modules (noop, echo, fail) │    │
│  └─────────────────────────────────┘    │
├─────────────────────────────────────────┤
│    Telemetry & Tracing (Phase 8) ✓      │
│  ┌─────────────────────────────────┐    │
│  │ OpenTelemetry tracing + metrics │    │
│  │ Structured logging (structlog)  │    │
│  │ Evaluation interface (NoOp)     │    │
│  └─────────────────────────────────┘    │
├─────────────────────────────────────────┤
│  LLM Provider (Phase 9, 11) ✓           │
│  ┌─────────────────────────────────┐    │
│  │ LLMProvider Protocol            │    │
│  │ AnthropicLLMProvider (opt-in)   │    │
│  │ NoOp default (blocks usage)     │    │
│  │ call_llm activity (observable)  │    │
│  └─────────────────────────────────┘    │
├─────────────────────────────────────────┤
│  Memory Reader (Phase 10, 12) ✓         │
│  ┌─────────────────────────────────┐    │
│  │ MemoryReader Protocol           │    │
│  │ PostgresMemoryReader (real)     │    │
│  │ Named, bounded queries          │    │
│  │ Frozen result types             │    │
│  └─────────────────────────────────┘    │
├─────────────────────────────────────────┤
│  Artifact Store (Phase 3, 13) ✓         │
│  ┌─────────────────────────────────┐    │
│  │ ObjectStore Protocol            │    │
│  │ R2ObjectStore (opt-in)          │    │
│  │ NoOp default (in-memory)        │    │
│  │ Size-based routing (64KB)       │    │
│  └─────────────────────────────────┘    │
├─────────────────────────────────────────┤
│  Embedding Generation (Phase 14) ✓      │
│  ┌─────────────────────────────────┐    │
│  │ EmbeddingProvider Protocol      │    │
│  │ OpenAIEmbeddingProvider (opt-in)│    │
│  │ NoOp default (blocks usage)     │    │
│  │ 1536-dim text-embedding-3-small │    │
│  └─────────────────────────────────┘    │
├─────────────────────────────────────────┤
│      Memory Infrastructure (Phase 3) ✓  │
│  ┌─────────────────────────────────┐    │
│  │ Vector memory (pgvector search) │    │
│  │ Working memory (Temporal state) │    │
│  └─────────────────────────────────┘    │
├─────────────────────────────────────────┤
│         Data Layer (Phase 2) ✓          │
│  ┌─────────────────────────────────┐    │
│  │ Postgres (truth + memory)       │    │
│  │ pgvector (embeddings)           │    │
│  │ SQLAlchemy Core (schema)        │    │
│  │ Pydantic (contracts)            │    │
│  └─────────────────────────────────┘    │
└─────────────────────────────────────────┘
```

## Boundaries

### Sacred Rule

> Nothing in `src/` imports from `ai/runtime/` directly.
> Execution code must not reason. Cognition must not execute.

### Current Boundary Integrity

- `src/infra/db/` — database utilities (no logic)
- `src/infra/models/` — Pydantic contracts (no logic)
- `src/infra/directives/` — directive lifecycle (pure functions + single mutator)
- `src/infra/policy/` — deterministic policy evaluation (no LLM calls)
- `src/memory/` — memory infrastructure (no intelligence)
- `src/workflows/` — Temporal workflows and activities (orchestration only)
- `src/infra/execution/modules/` — execution module interface and stubs (no intelligence)
- `src/infra/telemetry/` — OpenTelemetry tracing, metrics, and logging (write-only)
- `src/infra/memory/` — read-only memory consumption interfaces (no writes, no storage access)
- `src/infra/evaluation/` — evaluation interface and NoOp provider (observation only)
- `src/infra/llm/` — LLM provider interface (opt-in, NoOp default)
- `src/infra/artifacts/` — object storage interface (opt-in, NoOp default)
- `src/infra/embeddings/` — embedding provider interface (opt-in, NoOp default)
- No imports from `ai/runtime/`
- No agent code
- LLM/embedding calls are opt-in and require explicit env var configuration

## Infrastructure
Temporal must not start until Postgres is fully ready; a healthcheck-gated dependency is required.

### Docker Compose Services

| Service | Image | Port | Purpose |
|---------|-------|------|---------|
| postgres | pgvector/pgvector:pg16 | 5432 | Data persistence + pgvector |
| temporal | temporalio/auto-setup:1.22 | 7233 | Workflow orchestration (future) |
| temporal-ui | temporalio/ui:latest | 8080 | Temporal dashboard |
| otel-collector | otel/opentelemetry-collector:latest | 4317, 4318, 8889 | Telemetry collection |
| control-plane | python:3.11-slim | — | Python service (idle) |
| searxng | searxng/searxng:latest | 8888 | Search service |


### Databases

| Database | Owner | Purpose |
|----------|-------|---------|
| temporal | temporal | Temporal server persistence |
| agentland | temporal | Application data (truth, memory, governance) |
