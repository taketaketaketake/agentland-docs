# Stub Registry

> ⚠️ **This document is NOT an implementation plan.**
> It does not authorize code changes or execution.
> All implementation requires an approved entry in `implementation-plan.md`.

This document is the **authoritative registry** of all stubbed components in the system.

Every stub must have:
- A documented reason for existing
- A replacement path
- An ADR reference

**No stub may exist without an entry here.**

Phase audits FAIL if a NoOp/stub exists without a corresponding entry in this registry.

---

## LLM Layer (Phase 9)

### NoOpLLMProvider

| | |
|---|---|
| **Location** | `src/infra/llm/noop.py` |
| **Reason** | Phase 9 explicitly forbids cognition. LLM interface exists but must be disabled by default. |
| **Behavior** | Raises `LLMProviderError` with `error_type="disabled"` on any call |
| **Replacement** | `AnthropicLLMProvider` |
| **Status** | **Replaced in Phase 11** |
| **ADR Reference** | ADR-012: LLM Provider Interface |

> **Note:** NoOpLLMProvider remains the default (`LLM_PROVIDER=noop`). Set `LLM_PROVIDER=anthropic` and `ANTHROPIC_API_KEY` to use the real provider.

---

## Memory Consumption Layer (Phase 10)

### NoOpMemoryReader

| | |
|---|---|
| **Location** | `src/infra/memory/noop.py` |
| **Reason** | Phase 10 defines interface before implementation. Real reader requires database queries. |
| **Behavior** | Returns empty results for all queries, logs access attempts |
| **Replacement** | `PostgresMemoryReader` |
| **Status** | **Replaced in Phase 12** |
| **ADR Reference** | ADR-013: Memory Consumption Interfaces |

> **Note:** NoOpMemoryReader remains available for tests and bootstrapping. Use `PostgresMemoryReader(engine)` for production access.

---

## Evaluation Layer (Phase 8)

### NoOpEvaluationProvider

| | |
|---|---|
| **Location** | `src/infra/evaluation/noop.py` |
| **Reason** | Phase 8 defines interface for future Braintrust integration without taking dependency. |
| **Behavior** | All methods return stub results, no external calls |
| **Replacement** | `BraintrustEvaluationProvider` |
| **Status** | **Replaced in Phase 15** |
| **ADR Reference** | ADR-011: Telemetry & Tracing Infrastructure |

> **Note:** NoOpEvaluationProvider is the default (`EVALUATION_PROVIDER=noop`). Set `EVALUATION_PROVIDER=braintrust` with `BRAINTRUST_API_KEY` to enable Braintrust evaluation.

---

## Execution Modules (Phase 7)

### NoOpModule

| | |
|---|---|
| **Location** | `src/infra/execution/modules/noop.py` |
| **Reason** | Proves module interface works without side effects |
| **Behavior** | Does nothing, emits artifact, returns SUCCESS |
| **Replacement** | None required - this is a valid production module for testing |
| **Planned Phase** | Permanent (test utility) |
| **ADR Reference** | ADR-010: Execution Modules |

### EchoModule

| | |
|---|---|
| **Location** | `src/infra/execution/modules/echo.py` |
| **Reason** | Proves payload handling works |
| **Behavior** | Echoes input payload, emits artifact |
| **Replacement** | None required - this is a valid production module for testing |
| **Planned Phase** | Permanent (test utility) |
| **ADR Reference** | ADR-010: Execution Modules |

### FailIntentionallyModule

| | |
|---|---|
| **Location** | `src/infra/execution/modules/fail.py` |
| **Reason** | Proves failure handling works |
| **Behavior** | Returns FAILURE or raises exception based on payload |
| **Replacement** | None required - this is a valid production module for testing |
| **Planned Phase** | Permanent (test utility) |
| **ADR Reference** | ADR-010: Execution Modules |

---

## Object Storage Layer (Phase 13)

### NoOpObjectStore

| | |
|---|---|
| **Location** | `src/infra/artifacts/noop.py` |
| **Reason** | Phase 13 provides real object storage but needs safe default for development/testing |
| **Behavior** | Stores objects in-memory (non-persistent), returns `artifact://noop/{key}` URIs |
| **Replacement** | `R2ObjectStore` |
| **Status** | Permanent (test/dev utility) |
| **ADR Reference** | ADR-014: Real Artifact Store |

> **Note:** NoOpObjectStore is the default (`OBJECT_STORE_PROVIDER=noop`). Set `OBJECT_STORE_PROVIDER=r2` with R2 credentials to use production storage.

---

## Embedding Layer (Phase 14)

### NoOpEmbeddingProvider

| | |
|---|---|
| **Location** | `src/infra/embeddings/noop.py` |
| **Reason** | Phase 14 provides real embeddings but needs safe default to block accidental usage |
| **Behavior** | Raises `EmbeddingProviderError` with `error_type="disabled"` on any call |
| **Replacement** | `OpenAIEmbeddingProvider` |
| **Status** | Permanent (test/dev utility) |
| **ADR Reference** | ADR-017: Real Embedding Generation |

> **Note:** NoOpEmbeddingProvider is the default (`EMBEDDING_PROVIDER=noop`). Set `EMBEDDING_PROVIDER=openai` with `OPENAI_API_KEY` to enable embeddings.

---

## Memory Infrastructure (Phase 3)

### Artifact Store (Local URIs)

| | |
|---|---|
| **Location** | `src/memory/artifacts.py` |
| **Reason** | Phase 3 stubs object storage without R2 dependency |
| **Behavior** | Stores metadata in Postgres, returns `artifact://local/<uuid>` URIs |
| **Replacement** | `R2ObjectStore` via `src/infra/artifacts/` |
| **Status** | **Replaced in Phase 13** |
| **ADR Reference** | ADR-006: Phase 3 Memory Infrastructure |

> **Note:** Local URIs (`artifact://local/`) are still used for small artifacts (< 64KB). Set `OBJECT_STORE_PROVIDER=r2` and configure R2 credentials to enable R2 storage for large artifacts.

### Vector Memory (No Embedding Generation)

| | |
|---|---|
| **Location** | `src/memory/vector.py` |
| **Reason** | Phase 3 provides vector storage/search without embedding generation |
| **Behavior** | Requires pre-computed embeddings; no embedding API calls |
| **Replacement** | `OpenAIEmbeddingProvider` via `src/infra/embeddings/` |
| **Status** | **Replaced in Phase 14** |
| **ADR Reference** | ADR-006: Phase 3 Memory Infrastructure |

> **Note:** Set `EMBEDDING_PROVIDER=openai` and `OPENAI_API_KEY` to enable embedding generation.

### Working Memory (Declaration Only)

| | |
|---|---|
| **Location** | `src/memory/working_memory.py` |
| **Reason** | Phase 3 declares working memory is Temporal state; no separate implementation needed |
| **Behavior** | Documentation only - states that Temporal workflow state is working memory |
| **Replacement** | None required - this is by design |
| **Planned Phase** | Permanent (architectural decision) |
| **ADR Reference** | ADR-006: Phase 3 Memory Infrastructure |

---

## Real Execution Modules (Not Yet Created)

The following modules do not exist yet. They are not stubs—they are **absent capabilities**.

| Module | Purpose | Planned Phase |
|--------|---------|---------------|
| `http_request` | Make external API calls | Future |
| `send_email` | Send emails via SMTP/provider | Future |
| `slack_message` | Post to Slack | Future |
| `file_write` | Write to object storage | Future |

These are listed here to distinguish between:
- **Stubs**: Exist, do nothing useful, will be replaced
- **Absent**: Don't exist yet, will be created

---

## Enforcement

The phase audit skill (`skills/claude/phase-audit.md`) must verify:

1. Every file matching `**/noop*.py` or `**/*_stub*.py` has a registry entry
2. Every registry entry has all required fields
3. Every registry entry references a valid ADR

Violation of any of these causes phase audit to FAIL.

---

## Maintenance

When adding a new stub:
1. Create the stub implementation
2. Add entry to this registry immediately
3. Reference the ADR that justifies the stub
4. Specify replacement path

When replacing a stub:
1. Implement the replacement
2. Update this registry (mark as "Replaced in Phase X")
3. Keep the entry for historical reference

---

## Summary

| Category | Stub Count | Permanent | Replaced | To Replace |
|----------|------------|-----------|----------|------------|
| LLM | 1 | 0 | 1 | 0 |
| Memory Reader | 1 | 0 | 1 | 0 |
| Evaluation | 1 | 0 | 1 | 0 |
| Execution Modules | 3 | 3 | 0 | 0 |
| Object Storage | 1 | 1 | 0 | 0 |
| Embedding | 1 | 1 | 0 | 0 |
| Artifact Store | 1 | 0 | 1 | 0 |
| Vector Memory | 1 | 0 | 1 | 0 |
| Working Memory | 1 | 1 | 0 | 0 |
| **Total** | **11** | **6** | **5** | **0** |

All replaceable stubs have been replaced.
6 stubs are permanent by design (test utilities or architectural decisions).
5 stubs have been replaced:
- NoOpLLMProvider → AnthropicLLMProvider (Phase 11)
- NoOpMemoryReader → PostgresMemoryReader (Phase 12)
- Artifact Store (Local URIs) → R2ObjectStore (Phase 13)
- Vector Memory (No Embedding) → OpenAIEmbeddingProvider (Phase 14)
- NoOpEvaluationProvider → BraintrustEvaluationProvider (Phase 15)
