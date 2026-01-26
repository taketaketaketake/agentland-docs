# Infrastructure Handoff Document

> **Status:** Infrastructure complete through Phase 15
> **Date:** 2026-01-26
> **Purpose:** Reference for building business logic on top of this infrastructure

This repository is **frozen as infrastructure only**. Business logic, agents, and prompts belong in a separate repository that imports from this one.

---

## What This Repository Contains

### The Control Loop

```
┌──────────────────────────────────────────────────────────────┐
│  COGNITION (your fork)                                       │
│  Agents reason, plan, decide                                 │
├──────────────────────────────────────────────────────────────┤
│  DIRECTIVE                                                   │
│  Intent frozen as structured data                            │
│  Status: draft → proposed → approved → executing → complete  │
├──────────────────────────────────────────────────────────────┤
│  POLICY GATE                                                 │
│  Deterministic allow/block (budget, tools, scope)            │
│  No LLM calls, pure functions                                │
├──────────────────────────────────────────────────────────────┤
│  APPROVAL WORKFLOW (Temporal)                                │
│  Optional human approval via signals                         │
├──────────────────────────────────────────────────────────────┤
│  DISPATCHER                                                  │
│  Polls for approved directives                               │
│  Spawns execution workflows                                  │
├──────────────────────────────────────────────────────────────┤
│  EXECUTION WORKFLOW                                          │
│  Dispatches to modules, tracks status                        │
├──────────────────────────────────────────────────────────────┤
│  MODULES                                                     │
│  Bounded actions (currently stubs: noop, echo, fail)         │
│  Your fork adds real modules                                 │
├──────────────────────────────────────────────────────────────┤
│  ARTIFACTS + MEMORY                                          │
│  Results stored, searchable                                  │
└──────────────────────────────────────────────────────────────┘
```

### Layer Inventory

| Layer | Location | Purpose | Key Exports |
|-------|----------|---------|-------------|
| Database | `src/infra/db/` | Postgres + pgvector | `get_engine()`, `get_connection()`, tables |
| Models | `src/infra/models/` | Pydantic contracts | `DirectiveCreate`, `ExecutionRunRead`, etc. |
| Directives | `src/infra/directives/` | Lifecycle state machine | `transition_directive_status()`, `validate_transition()` |
| Policy | `src/infra/policy/` | Deterministic rules | `evaluate_directive()`, `PolicyConfig` |
| Execution | `src/infra/execution/` | Run lifecycle | `transition_execution_status()` |
| Modules | `src/infra/execution/modules/` | Bounded actions | `ExecutionModule` Protocol, `dispatch_module()` |
| Telemetry | `src/infra/telemetry/` | Observability | `get_tracer()`, `get_logger()`, metrics |
| LLM | `src/infra/llm/` | LLM provider interface | `get_llm_provider()`, `LLMRequest`, `LLMResponse` |
| Memory Reader | `src/infra/memory/` | Read-only queries | `PostgresMemoryReader`, `MemoryReader` Protocol |
| Artifacts | `src/infra/artifacts/` | Object storage | `get_object_store()`, `ObjectStore` Protocol |
| Embeddings | `src/infra/embeddings/` | Vector generation | `get_embedding_provider()`, `EmbeddingProvider` Protocol |
| Evaluation | `src/infra/evaluation/` | Trace scoring | `get_evaluation_provider()`, `EvaluationProvider` Protocol |
| Vector Memory | `src/memory/` | Embedding storage/search | `embed_and_store()`, `semantic_search_text()` |
| Workflows | `src/workflows/` | Temporal orchestration | `ApprovalWorkflow`, `ExecutionWorkflow`, `DispatcherWorkflow` |

---

## How to Use Each Layer

### LLM Calls

```python
from src.infra.llm import get_llm_provider, LLMRequest

provider = get_llm_provider()  # Returns Anthropic or NoOp based on env

request = LLMRequest(
    messages=[
        {"role": "user", "content": "Hello"}
    ],
    model="your-model-id",  # e.g., claude-3-5-sonnet-20241022
    max_tokens=1024,
)

response = provider.complete(request)
print(response.content)
print(response.usage)  # {"input_tokens": ..., "output_tokens": ..., "estimated_cost_usd": ...}
```

**Environment:**
```bash
LLM_PROVIDER=anthropic  # or "noop" (default, blocks usage)
ANTHROPIC_API_KEY=sk-...
```

### Memory Reading

```python
from sqlalchemy import create_engine
from src.infra.memory import PostgresMemoryReader

engine = create_engine(DATABASE_URL)
reader = PostgresMemoryReader(engine)

# Get latest directive for a role
directive = reader.latest_directive_for_role("planner")

# Get recent executions
executions = reader.execution_summaries(limit=10, status_filter="completed")

# Get artifacts by type
artifacts = reader.artifacts_by_type("policy_evaluation", limit=5)

# Semantic search (requires EMBEDDING_PROVIDER=openai)
results = reader.semantic_search("budget constraints", top_k=10)
for r in results:
    print(f"{r.similarity_score:.2f}: {r.content[:100]}")
```

### Embedding & Vector Search

```python
from sqlalchemy import create_engine
from src.memory.vector import embed_and_store, semantic_search_text, semantic_search_with_content

engine = create_engine(DATABASE_URL)

# Store a memory with embedding
memory_id = ...  # UUID of existing memory
embedding = embed_and_store(engine, memory_id, "This is the text to embed")

# Search by text (auto-generates query embedding)
results = semantic_search_text(engine, "find similar content", limit=10)
# Returns: [(memory_id, similarity_score), ...]

# Search with full content
results = semantic_search_with_content(engine, "find similar content", limit=10)
# Returns: [{"memory_id": ..., "content": ..., "scope": ..., "similarity_score": ...}, ...]
```

**Environment:**
```bash
EMBEDDING_PROVIDER=openai  # or "noop" (default, blocks usage)
OPENAI_API_KEY=sk-...
```

### Evaluation & Scoring

```python
from src.infra.evaluation import get_evaluation_provider, EvaluationInput

provider = get_evaluation_provider()  # Returns Braintrust or NoOp based on env

# Log a trace for evaluation
provider.log_trace(
    trace_id="otel-trace-id",
    input_data={"prompt": "..."},
    output_data={"response": "..."},
    metadata={"directive_id": "...", "run_id": "..."},
)

# Score an execution
result = provider.score(EvaluationInput(
    trace_id="otel-trace-id",
    directive_id="directive-uuid",
    execution_run_id="run-uuid",
))

# Run an experiment
experiment = provider.experiment("my-experiment", ["trace-1", "trace-2"])
```

**Environment:**
```bash
EVALUATION_PROVIDER=braintrust  # or "noop" (default)
BRAINTRUST_API_KEY=...
BRAINTRUST_PROJECT=agentland  # optional, defaults to "agentland"
```

### Artifact Storage

```python
from sqlalchemy import create_engine
from src.memory.artifacts import put_artifact, get_artifact_content

engine = create_engine(DATABASE_URL)

# Store artifact (auto-routes by size: <64KB local, >=64KB object store)
uri = put_artifact(engine, "my_artifact_type", {"key": "value", "data": [1,2,3]})
# Returns: "artifact://local/..." or "artifact://r2/..." or "artifact://noop/..."

# Retrieve content
content = get_artifact_content(engine, uri)
```

**Environment:**
```bash
OBJECT_STORE_PROVIDER=r2  # or "noop" (default, in-memory)
CLOUDFLARE_ACCOUNT_ID=...
R2_ACCESS_KEY_ID=...
R2_SECRET_ACCESS_KEY=...
R2_BUCKET_NAME=...
R2_ENDPOINT_URL=https://<account_id>.r2.cloudflarestorage.com
```

### Creating Directives

```python
from uuid import uuid4
from sqlalchemy import create_engine, insert
from src.infra.db.tables import directives
from src.infra.db.session import get_connection
from src.infra.directives import transition_directive_status

engine = create_engine(DATABASE_URL)

# Create directive
directive_id = uuid4()
with get_connection(engine) as conn:
    conn.execute(insert(directives).values(
        id=directive_id,
        role="executor",
        type="noop",  # Module type to execute
        status="draft",
        issued_by="planner",
        objective="Test the system",
        scope="test",
        payload={"test": True},
    ))

# Transition through lifecycle
transition_directive_status(engine, directive_id, "proposed")
transition_directive_status(engine, directive_id, "approved")
# Now DispatcherWorkflow will pick it up
```

### Policy Evaluation

```python
from src.infra.policy import evaluate_directive, has_blocking_verdict, PolicyConfig

config = PolicyConfig(
    version="v1",
    budget_ceiling=Decimal("100.00"),
    tool_allowlist=frozenset({"noop", "echo", "http_request"}),
    scope_allowlist=frozenset({"test", "development", "production"}),
)

results = evaluate_directive(engine, directive_id, config)

if has_blocking_verdict(results):
    reasons = get_block_reasons(results)
    print(f"Blocked: {reasons}")
else:
    print("Approved by policy")
```

### Running Workflows

```python
# Start the worker (serves both approval and execution queues)
python -m src.workflows.worker

# Or programmatically:
from src.workflows.worker import run_worker
import asyncio
asyncio.run(run_worker())
```

The worker:
1. Processes `ApprovalWorkflow` on `approval-queue`
2. Runs `DispatcherWorkflow` on `execution-queue` (polls for approved directives)
3. Spawns `ExecutionWorkflow` for each approved directive

---

## Database Schema

### Core Tables

| Table | Purpose |
|-------|---------|
| `agent_roles` | Role registry (planner, executor, etc.) |
| `directives` | Frozen intent with lifecycle status |
| `execution_runs` | Execution attempt records |
| `memories` | Stored memories (content, scope) |
| `memory_embeddings` | Vector embeddings (1536 dims) |
| `artifacts` | Artifact metadata and URIs |

### Key Relationships

```
directives (1) ←→ (N) execution_runs
memories (1) ←→ (1) memory_embeddings
```

---

## Environment Variables

### Required

```bash
DATABASE_URL=postgresql+psycopg://user:pass@localhost:5432/agentland
```

### Optional (with defaults)

```bash
# LLM (default: noop - blocks usage)
LLM_PROVIDER=noop
ANTHROPIC_API_KEY=

# Embeddings (default: noop - blocks usage)
EMBEDDING_PROVIDER=noop
OPENAI_API_KEY=

# Object Storage (default: noop - in-memory)
OBJECT_STORE_PROVIDER=noop
CLOUDFLARE_ACCOUNT_ID=
R2_ACCESS_KEY_ID=
R2_SECRET_ACCESS_KEY=
R2_BUCKET_NAME=
R2_ENDPOINT_URL=

# Evaluation (default: noop)
EVALUATION_PROVIDER=noop
BRAINTRUST_API_KEY=
BRAINTRUST_PROJECT=agentland
```

---

## Adding Business Logic (In Your Fork)

### Directory Structure

```
your-fork/
├── agents/
│   ├── planner.py      # Planning agent
│   ├── executor.py     # Execution agent
│   └── supervisor.py   # Supervision agent
├── prompts/
│   ├── system/         # System prompts
│   └── templates/      # Reusable templates
├── modules/
│   ├── http_request.py # Real HTTP module
│   ├── send_email.py   # Email module
│   └── ...
├── workflows/
│   └── business/       # Business-specific workflows
└── pyproject.toml      # Depends on agentland
```

### Importing Infrastructure

```python
# In your fork
from agentland.infra.llm import get_llm_provider, LLMRequest
from agentland.infra.memory import PostgresMemoryReader
from agentland.infra.directives import transition_directive_status
from agentland.infra.execution.modules import register_module, ExecutionModule
```

### Adding a Real Module

```python
# your-fork/modules/http_request.py
from agentland.infra.execution.modules import (
    ExecutionModule,
    ModuleInput,
    ModuleOutput,
    ModuleStatus,
    register_module,
)

class HttpRequestModule:
    """Make HTTP requests."""

    @property
    def name(self) -> str:
        return "http_request"

    def execute(self, input: ModuleInput, engine, emit_artifact) -> ModuleOutput:
        url = input.payload.get("url")
        method = input.payload.get("method", "GET")

        # Do the work
        response = requests.request(method, url)

        # Emit artifact
        emit_artifact("http_response", {
            "status_code": response.status_code,
            "url": url,
        })

        return ModuleOutput(
            status=ModuleStatus.SUCCESS,
            result={"status_code": response.status_code},
            message=f"HTTP {method} {url} -> {response.status_code}",
        )

# Register
register_module(HttpRequestModule())
```

### First Integration Test

```python
"""Prove the spine works end-to-end."""
from uuid import uuid4
from sqlalchemy import create_engine

# 1. Create directive
directive_id = create_test_directive(engine, type="noop")

# 2. Transition to proposed
transition_directive_status(engine, directive_id, "proposed")

# 3. Run approval (or transition directly for testing)
transition_directive_status(engine, directive_id, "approved")

# 4. Start worker, watch it:
#    - Pick up the directive
#    - Create execution run
#    - Dispatch to noop module
#    - Mark complete

# 5. Verify
reader = PostgresMemoryReader(engine)
executions = reader.execution_summaries(limit=1)
assert executions[0].status == "completed"
```

---

## The Sacred Boundary

```
┌─────────────────────────────────────────┐
│  ai/runtime/                            │  ← Agent contracts, roles
│  (NOT imported by src/)                 │
├─────────────────────────────────────────┤
│  src/                                   │  ← Infrastructure
│  (NEVER imports from ai/runtime/)       │
└─────────────────────────────────────────┘
```

**This boundary is enforced by convention and phase audits.**

Infrastructure provides capabilities. Agents (in your fork) use those capabilities to reason and decide.

---

## Key Documents

| Document | Purpose |
|----------|---------|
| `docs/vision.md` | Why this system exists |
| `docs/architecture.md` | How layers fit together |
| `docs/invariants.md` | Rules that must never be broken |
| `docs/contracts.md` | Interface completeness status |
| `docs/stubs.md` | What's stubbed vs real |
| `docs/artifacts.md` | Artifact type registry |
| `implementation-plan.md` | Phase-by-phase build plan |
| `docs/decisions/adr-*.md` | Architectural decisions |

---

## Validation Scripts

```bash
# Phase 1: Infrastructure Spine
python scripts/validate_infrastructure.py

# Phase 2: Database schema
python scripts/validate_schema.py

# Phase 3: Memory infrastructure
python scripts/validate_memory.py

# Phase 4: Directives
python scripts/validate_directives.py

# Phase 5: Policy engine
python scripts/validate_policy.py

# Phase 6: Execution orchestrator
python scripts/validate_execution.py

# Phase 7: Modules
python scripts/validate_modules.py

# Phase 8: Telemetry
python scripts/validate_telemetry.py

# Phase 9: LLM provider interface
python scripts/validate_llm.py

# Phase 10 & 12: Memory reader
python scripts/validate_memory_reader.py

# Phase 11: Anthropic LLM provider
python scripts/validate_anthropic.py

# Phase 13: Artifact store
python scripts/validate_artifacts.py

# Phase 14: Embedding provider
python scripts/validate_embeddings.py

# Phase 15: Evaluation provider
python scripts/validate_evaluation.py
```

---

## Quick Start for Your Fork

```bash
# 1. Fork this repo (or add as dependency)

# 2. Start infrastructure
docker compose up -d

# 3. Create database
docker exec -it agentland-postgres-1 psql -U temporal -c "CREATE DATABASE agentland;"

# 4. Run migrations
python -m alembic upgrade head

# 5. Configure environment
cp .env.example .env
# Edit .env with your API keys

# 6. Start worker
python -m src.workflows.worker

# 7. In another terminal, create and approve a directive
# (See "Creating Directives" section above)
```

---

## What's Next (For Your Fork)

1. **Create your first agent** - A simple agent that reads memory and creates directives
2. **Add a real module** - HTTP requests, email, Slack, etc.
3. **Build a business workflow** - Agent → Directive → Approval → Execution → Results
4. **Add evaluation** - Enable Braintrust by setting `EVALUATION_PROVIDER=braintrust`

The infrastructure is ready. Add intelligence on top.

---

## Fork Guidance

This repository is intended to be forked.

### What You Should Change in a Fork

- Add agents (`src/agents/`)
- Add prompts, roles, and cognition
- Enable LLM providers by default
- Add product-specific execution modules
- Add memory write logic if required

### What You Should NOT Change

- Existing interfaces in `docs/contracts.md`
- Bounded enums and taxonomies
- Policy, execution, and lifecycle invariants
- Telemetry and artifact semantics

If an interface needs to change, introduce a *new* interface rather than modifying an existing one.
