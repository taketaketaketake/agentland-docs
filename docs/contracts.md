# Interface Contracts

> ⚠️ **This document is NOT an implementation plan.**
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

## LLM Layer (Phase 9)

### LLMProvider Protocol

| Status | **COMPLETE** |
|--------|--------------|
| Location | `src/infra/llm/provider.py` |

**Methods:**
| Method | Input | Output | Errors |
|--------|-------|--------|--------|
| `name` (property) | — | `str` | — |
| `complete(request)` | `LLMRequest` | `LLMResponse` | `LLMProviderError` |

**Error Taxonomy (Bounded):**
```
error_type ∈ {"disabled", "misconfigured", "provider_error", "timeout", "invalid_request"}
```

**Completeness Checklist:**
- [x] All methods defined
- [x] Input types bounded (`LLMRequest` with validated fields)
- [x] Output types frozen (`LLMResponse` is frozen dataclass)
- [x] Error types enumerated (5 types, enforced in `__post_init__`)
- [x] No open-ended parameters

### Adding a New LLM Provider

New LLM providers MUST conform to the `LLMProvider` Protocol and the rules below.

**Required Files:**

For a provider named `<provider>`:
- `src/infra/llm/<provider>.py` — Provider implementation
- Provider MUST be registered in `src/infra/llm/config.py`
- Provider MUST be exported from `src/infra/llm/__init__.py`

**Required Interface:**

```python
class <ProviderName>LLMProvider:
    @property
    def name(self) -> str:
        return "<provider>"

    def complete(self, request: LLMRequest) -> LLMResponse:
        # Call provider API
        # Return LLMResponse with normalized usage
        # Raise LLMProviderError on failure
        ...
```

**Required Behaviors:**

| Requirement | Implementation |
|-------------|----------------|
| Error taxonomy | All errors MUST raise `LLMProviderError` with `error_type` ∈ {disabled, misconfigured, provider_error, timeout, invalid_request} |
| Usage normalization | MUST use `normalize_usage(input_tokens, output_tokens, estimated_cost_usd)` |
| No provider-specific objects | MUST NOT expose SDK objects in return types |
| Synchronous interface | MUST be synchronous (Temporal activity compatible) |
| Lazy initialization | SHOULD defer API client creation to first use |
| Graceful degradation | MUST raise `misconfigured` error if credentials missing |

**SDK Versioning:**

External SDKs (e.g., `anthropic`) are pinned with upper bounds (e.g., `>=0.18.0,<1.0.0`).
Major version updates may require:
- Updates to error classification (mapping SDK exceptions to bounded error_type)
- Updates to response mapping (extracting content, usage from SDK response)
- Updates to pricing tables for cost estimation

**Enforcement:**

Any provider that:
- Violates the error taxonomy
- Bypasses instrumentation
- Returns provider-specific objects
- Exposes unbounded parameters

**Fails phase audit.**

---

## Embedding Layer (Phase 14)

### EmbeddingProvider Protocol

| Status | **COMPLETE** |
|--------|--------------|
| Location | `src/infra/embeddings/provider.py` |

**Methods:**
| Method | Input | Output | Errors |
|--------|-------|--------|--------|
| `name` (property) | — | `str` | — |
| `embed(request)` | `EmbeddingRequest` | `EmbeddingResponse` | `EmbeddingProviderError` |
| `embed_single(text, model)` | `str`, `str` | `list[float]` | `EmbeddingProviderError` |

**Error Taxonomy (Bounded):**
```
error_type ∈ {"disabled", "misconfigured", "provider_error", "timeout", "invalid_request", "rate_limited"}
```

**Bounds:**
```
EMBEDDING_DIMENSIONS = 1536  # Must match memory_embeddings table
MAX_BATCH_SIZE = 100         # Maximum texts per request
MAX_TEXT_LENGTH = 8192       # Maximum characters per text
```

**Completeness Checklist:**
- [x] All methods defined
- [x] Input types bounded (`EmbeddingRequest` with validated fields)
- [x] Output types frozen (`EmbeddingResponse` is frozen dataclass)
- [x] Error types enumerated (6 types, enforced in `__post_init__`)
- [x] Dimensions match database schema (1536)

### Adding a New Embedding Provider

New embedding providers MUST conform to the `EmbeddingProvider` Protocol and the rules below.

**Required Files:**

For a provider named `<provider>`:
- `src/infra/embeddings/<provider>.py` — Provider implementation
- Provider MUST be registered in `src/infra/embeddings/config.py`
- Provider MUST be exported from `src/infra/embeddings/__init__.py`

**Required Interface:**

```python
class <ProviderName>EmbeddingProvider:
    @property
    def name(self) -> str:
        return "<provider>"

    def embed(self, request: EmbeddingRequest) -> EmbeddingResponse:
        # Call provider API
        # Return EmbeddingResponse with usage
        # Raise EmbeddingProviderError on failure
        ...

    def embed_single(self, text: str, model: str = "text-embedding-3-small") -> list[float]:
        # Convenience method for single text
        ...
```

**Required Behaviors:**

| Requirement | Implementation |
|-------------|----------------|
| Error taxonomy | All errors MUST raise `EmbeddingProviderError` with bounded `error_type` |
| Dimensions | MUST return embeddings with exactly 1536 dimensions |
| No provider-specific objects | MUST NOT expose SDK objects in return types |
| Synchronous interface | MUST be synchronous (Temporal activity compatible) |
| Lazy initialization | SHOULD defer API client creation to first use |
| Graceful degradation | MUST raise `misconfigured` error if credentials missing |

**SDK Versioning:**

External SDKs (e.g., `openai`) are pinned with upper bounds (e.g., `>=1.0.0,<2.0.0`).
Major version updates may require:
- Updates to error classification (mapping SDK exceptions to bounded error_type)
- Updates to response mapping (extracting embeddings, usage from SDK response)
- Validation that embedding dimensions remain 1536

**Enforcement:**

Any provider that:
- Violates the error taxonomy
- Returns wrong dimensions
- Returns provider-specific objects
- Exposes unbounded parameters

**Fails phase audit.**

---

## Memory Consumption Layer (Phase 10)

### MemoryReader Protocol

| Status | **COMPLETE** |
|--------|--------------|
| Location | `src/infra/memory/reader.py` |

**Methods:**
| Method | Input | Output | Errors |
|--------|-------|--------|--------|
| `name` (property) | — | `str` | — |
| `latest_directive_for_role(role)` | `str` | `DirectiveSummary \| None` | — |
| `execution_summaries(limit, status_filter)` | `int`, `str \| None` | `list[ExecutionSummary]` | — |
| `artifacts_by_type(artifact_type, limit)` | `str`, `int` | `list[ArtifactSummary]` | — |
| `semantic_search(query, top_k)` | `str`, `int` | `list[SemanticResult]` | — |

**Bounds:**
```
MAX_EXECUTION_LIMIT = 100
MAX_ARTIFACT_LIMIT = 100
MAX_SEMANTIC_TOP_K = 50
```

**Completeness Checklist:**
- [x] All methods defined
- [x] Input types bounded (limits capped)
- [x] Output types frozen (all result dataclasses are frozen)
- [x] No raw storage access exposed
- [x] Embeddings never returned (similarity scores only)

---

## Evaluation Layer (Phase 8)

### EvaluationProvider Protocol

| Status | **COMPLETE** |
|--------|--------------|
| Location | `src/infra/evaluation/interface.py` |

**Methods:**
| Method | Input | Output | Errors |
|--------|-------|--------|--------|
| `log_trace(...)` | trace data | `None` | — |
| `score(input)` | `EvaluationInput` | `EvaluationResult` | — |
| `experiment(name, traces)` | `str`, traces | `dict` | — |

**Completeness Checklist:**
- [x] All methods defined
- [x] Input types defined (`EvaluationInput`)
- [x] Output types frozen (`EvaluationResult`)
- [x] NoOp implementation exists

---

## Policy Layer (Phase 5)

### Policy Engine

| Status | **COMPLETE** |
|--------|--------------|
| Location | `src/infra/policy/engine.py` |

**Functions:**
| Function | Input | Output |
|----------|-------|--------|
| `evaluate_directive(engine, directive_id, config)` | Engine, UUID, PolicyConfig | `list[PolicyResult]` |
| `has_blocking_verdict(results)` | `list[PolicyResult]` | `bool` |
| `get_block_reasons(results)` | `list[PolicyResult]` | `list[str]` |

**PolicyVerdict Enum (Bounded):**
```
PolicyVerdict ∈ {ALLOW, BLOCK}
```

**PolicyConfig (Versioned):**
```python
PolicyConfig(
    version: str,           # e.g., "v1"
    budget_ceiling: Decimal,
    tool_allowlist: frozenset[str],
    scope_allowlist: frozenset[str],
)
```

**Completeness Checklist:**
- [x] Verdicts are enumerated (ALLOW, BLOCK)
- [x] Config is versioned
- [x] Results are frozen dataclasses
- [x] Evaluation is deterministic (same input → same output)
- [x] No LLM calls

---

## Execution Layer (Phase 6)

### Execution Lifecycle

| Status | **COMPLETE** |
|--------|--------------|
| Location | `src/infra/execution/lifecycle.py` |

**Status Taxonomy (Bounded):**
```
execution_status ∈ {"pending", "running", "completed", "failed", "canceled"}
```

**Valid Transitions:**
```
pending → running
running → completed | failed | canceled
```

**Completeness Checklist:**
- [x] All statuses enumerated
- [x] All transitions defined
- [x] Single mutator enforced (`transition_execution_status`)
- [x] Terminal states defined

---

## Directive Layer (Phase 4)

### Directive Lifecycle

| Status | **COMPLETE** |
|--------|--------------|
| Location | `src/infra/directives/lifecycle.py` |

**Status Taxonomy (Bounded):**
```
directive_status ∈ {"draft", "proposed", "approved", "executing", "complete", "blocked", "aborted"}
```

**Valid Transitions:**
```
draft → proposed
proposed → approved | blocked
approved → executing | blocked
executing → complete | aborted
blocked → proposed (retry)
```

**Completeness Checklist:**
- [x] All statuses enumerated
- [x] All transitions defined
- [x] Single mutator enforced (`transition_directive_status`)
- [x] Terminal states defined

---

## Execution Modules (Phase 7)

### ExecutionModule Protocol

| Status | **COMPLETE** |
|--------|--------------|
| Location | `src/infra/execution/modules/base.py` |

**Methods:**
| Method | Input | Output |
|--------|-------|--------|
| `name` (property) | — | `str` |
| `execute(input, engine, emit_artifact)` | `ModuleInput`, Engine, Callable | `ModuleOutput` |

**ModuleStatus Enum (Bounded):**
```
ModuleStatus ∈ {SUCCESS, FAILURE, ERROR}
```

**Status Mapping:**
```
SUCCESS → execution_runs.status = "completed"
FAILURE → execution_runs.status = "failed"
ERROR   → execution_runs.status = "failed"
```

**Completeness Checklist:**
- [x] Protocol defined
- [x] Input type frozen (`ModuleInput`)
- [x] Output type frozen (`ModuleOutput`)
- [x] Status enum bounded
- [x] Idempotency key required

---

## Telemetry Layer (Phase 8)

### Metrics (Bounded Cardinality)

| Metric | Labels | Cardinality |
|--------|--------|-------------|
| `directives_total` | `status` | 7 (directive statuses) |
| `execution_failures_total` | `failure_type` | Bounded by failure types |
| `policy_evaluations_total` | `verdict` | 2 (ALLOW, BLOCK) |
| `module_executions_total` | `module_name`, `status` | Bounded by registered modules × 3 |
| `execution_duration_seconds` | `directive_type` | Bounded by directive types |
| `policy_evaluation_duration_seconds` | — | 1 |

**Cardinality Rule:** No high-cardinality labels (never `directive_id`, `run_id`, etc.)

**Completeness Checklist:**
- [x] All metrics defined
- [x] Labels bounded
- [x] Prometheus naming conventions
- [x] No high-cardinality labels

---

## Object Storage Layer (Phase 13)

### ObjectStore Protocol

| Status | **COMPLETE** |
|--------|--------------|
| Location | `src/infra/artifacts/store.py` |

**Methods:**
| Method | Input | Output | Errors |
|--------|-------|--------|--------|
| `name` (property) | — | `str` | — |
| `put(request)` | `ObjectStoreRequest` | `ObjectStoreResponse` | `ObjectStoreException` |
| `get(key)` | `str` | `RetrievedObject` | `ObjectStoreException` |
| `exists(key)` | `str` | `bool` | `ObjectStoreException` |
| `delete(key)` | `str` | `None` | `ObjectStoreException` (always `disabled` in Phase 13) |

**Error Taxonomy (Bounded):**
```
error_type ∈ {"disabled", "misconfigured", "storage_error", "not_found", "size_exceeded", "serialization"}
```

**Size Bounds:**
```
SIZE_THRESHOLD_BYTES = 64 * 1024      # 64KB - route to object store above this
MAX_ARTIFACT_SIZE_BYTES = 10 * 1024 * 1024  # 10MB - hard limit
```

**Completeness Checklist:**
- [x] All methods defined
- [x] Input types bounded (`ObjectStoreRequest` with validated fields)
- [x] Output types frozen (`ObjectStoreResponse`, `RetrievedObject` are frozen dataclasses)
- [x] Error types enumerated (6 types, enforced in `__post_init__`)
- [x] Size limits enforced
- [x] Delete disabled (artifacts are immutable)

### Adding a New Object Store Provider

New object store providers MUST conform to the `ObjectStore` Protocol and the rules below.

**Required Files:**

For a provider named `<provider>`:
- `src/infra/artifacts/<provider>.py` — Provider implementation
- Provider MUST be registered in `src/infra/artifacts/config.py`
- Provider MUST be exported from `src/infra/artifacts/__init__.py`

**Required Interface:**

```python
class <ProviderName>ObjectStore:
    @property
    def name(self) -> str:
        return "<provider>"

    def put(self, request: ObjectStoreRequest) -> ObjectStoreResponse:
        # Store object
        # Return ObjectStoreResponse with URI
        # Raise ObjectStoreException on failure
        ...

    def get(self, key: str) -> RetrievedObject:
        # Retrieve object
        # Raise ObjectStoreException on failure or not_found
        ...

    def exists(self, key: str) -> bool:
        # Check if object exists
        # Return False for not_found, raise for other errors
        ...

    def delete(self, key: str) -> None:
        # MUST raise ObjectStoreException with error_type="disabled"
        # Artifacts are immutable in Phase 13
        ...
```

**Required Behaviors:**

| Requirement | Implementation |
|-------------|----------------|
| Error taxonomy | All errors MUST raise `ObjectStoreException` with `error_type` ∈ {disabled, misconfigured, storage_error, not_found, size_exceeded, serialization} |
| Size validation | MUST reject objects > 10MB with `size_exceeded` |
| Delete disabled | MUST raise `disabled` error (artifacts are immutable) |
| Synchronous interface | MUST be synchronous (Temporal activity compatible) |
| Lazy initialization | SHOULD defer API client creation to first use |
| Graceful degradation | MUST raise `misconfigured` error if credentials missing |

**Enforcement:**

Any provider that:
- Violates the error taxonomy
- Allows delete operations
- Returns provider-specific objects
- Exposes unbounded parameters

**Fails phase audit.**

---

## Summary

| Layer | Interface | Status |
|-------|-----------|--------|
| LLM | LLMProvider | ✓ Complete |
| Embedding | EmbeddingProvider | ✓ Complete |
| Memory | MemoryReader | ✓ Complete |
| Evaluation | EvaluationProvider | ✓ Complete |
| Policy | PolicyEngine | ✓ Complete |
| Execution | ExecutionLifecycle | ✓ Complete |
| Directive | DirectiveLifecycle | ✓ Complete |
| Modules | ExecutionModule | ✓ Complete |
| Telemetry | Metrics | ✓ Complete |
| Object Storage | ObjectStore | ✓ Complete |

**All interfaces are complete.** Implementations may be NoOp (see `docs/stubs.md`), but contracts are sealed.

---

## Interface Modification Rules

1. **Adding methods to a Protocol**: Requires new ADR
2. **Changing input types**: Requires new ADR
3. **Changing output types**: Requires new ADR
4. **Expanding enums**: Requires new ADR
5. **Changing bounds**: Requires justification in commit message

Interfaces are frozen after stabilization. New capabilities require new interfaces, not modifications to existing ones.
