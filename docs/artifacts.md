# Artifact Taxonomy

> ⚠️ **This document is NOT an implementation plan.**
> It does not authorize code changes or execution.
> All implementation requires an approved entry in `implementation-plan.md`.

This document is the **authoritative registry** of all artifact types in the system.

Every artifact type must have:
- A defined producer (what creates it)
- A lifecycle phase (when it's created)
- A schema (what fields it contains)
- Retention expectations

**No new artifact type may be introduced without an entry here.**

---

## Policy Artifacts

### policy_evaluation

| | |
|---|---|
| **Producer** | `store_policy_artifact` activity |
| **Lifecycle Phase** | Phase 5 (Policy & Approval Gate) |
| **Created When** | A directive is evaluated against policy |
| **Schema** | `directive_id`, `policy_version`, `results[]`, `verdict`, `timestamp` |
| **Retention** | Permanent (audit trail) |

---

## Execution Artifacts

### execution_start

| | |
|---|---|
| **Producer** | `ExecutionWorkflow` |
| **Lifecycle Phase** | Phase 6 (Execution Orchestrator) |
| **Created When** | Execution run begins |
| **Schema** | `run_id`, `directive_id`, `started_at` |
| **Retention** | Permanent (audit trail) |

### execution_checkpoint

| | |
|---|---|
| **Producer** | `ExecutionWorkflow` |
| **Lifecycle Phase** | Phase 6 (Execution Orchestrator) |
| **Created When** | Mid-execution checkpoint (placeholder for future work) |
| **Schema** | `run_id`, `checkpoint_name`, `timestamp` |
| **Retention** | Permanent (audit trail) |

### execution_end

| | |
|---|---|
| **Producer** | `ExecutionWorkflow` |
| **Lifecycle Phase** | Phase 6 (Execution Orchestrator) |
| **Created When** | Execution run completes |
| **Schema** | `run_id`, `directive_id`, `status`, `completed_at` |
| **Retention** | Permanent (audit trail) |

---

## Module Artifacts

### module_execution

| | |
|---|---|
| **Producer** | `execute_module` activity |
| **Lifecycle Phase** | Phase 7 (Execution Modules) |
| **Created When** | A module executes |
| **Schema** | `run_id`, `module_name`, `status`, `duration_ms`, `result` |
| **Retention** | Permanent (audit trail) |

### noop_executed

| | |
|---|---|
| **Producer** | `NoOpModule` |
| **Lifecycle Phase** | Phase 7 (Execution Modules) |
| **Created When** | NoOp module runs |
| **Schema** | `run_id`, `message` |
| **Retention** | Permanent (test evidence) |

### echo_result

| | |
|---|---|
| **Producer** | `EchoModule` |
| **Lifecycle Phase** | Phase 7 (Execution Modules) |
| **Created When** | Echo module runs |
| **Schema** | `run_id`, `echoed_payload` |
| **Retention** | Permanent (test evidence) |

### intentional_failure

| | |
|---|---|
| **Producer** | `FailIntentionallyModule` |
| **Lifecycle Phase** | Phase 7 (Execution Modules) |
| **Created When** | Fail module runs |
| **Schema** | `run_id`, `failure_mode`, `message` |
| **Retention** | Permanent (test evidence) |

---

## LLM Artifacts

### llm_call

| | |
|---|---|
| **Producer** | `call_llm` activity via `emit_llm_artifacts()` |
| **Lifecycle Phase** | Phase 9 (LLM Provider Interface) |
| **Created When** | Any LLM call attempt (including NoOp errors) |
| **Schema** | `provider`, `model`, `max_tokens`, `temperature`, `messages` (summary only), `status`, `error_type` (if error), `latency_ms` |
| **Retention** | Permanent (cost tracking, audit) |
| **Privacy** | No full message content; only message count, roles, char count |

### llm_usage

| | |
|---|---|
| **Producer** | `call_llm` activity via `emit_llm_artifacts()` |
| **Lifecycle Phase** | Phase 9 (LLM Provider Interface) |
| **Created When** | Successful LLM call |
| **Schema** | `provider`, `model`, `input_tokens`, `output_tokens`, `total_tokens`, `estimated_cost_usd`, `latency_ms` |
| **Retention** | Permanent (cost tracking) |

---

## Memory Artifacts

### memory_read_attempt

| | |
|---|---|
| **Producer** | `MemoryReader` implementations (via `readonly_method` decorator) |
| **Lifecycle Phase** | Phase 10 (Memory Consumption Interfaces) |
| **Created When** | Any memory read is attempted |
| **Schema** | `reader_name`, `query_name`, `query_params`, `result_count`, `success`, `error_message` |
| **Retention** | Configurable (debugging, may be ephemeral) |
| **Note** | Currently logged, not persisted as artifact. Consider promoting to artifact for full audit trail. |

---

## Artifact URI Schemes

| Scheme | Meaning | Example | Status |
|--------|---------|---------|--------|
| `artifact://local/<uuid>` | Stored in Postgres only (metadata reference) | `artifact://local/123e4567-e89b-12d3-a456-426614174000` | Active (< 64KB) |
| `artifact://noop/<key>` | Stored in-memory (test/dev) | `artifact://noop/policy/2024/01/abc.json` | Active (OBJECT_STORE_PROVIDER=noop) |
| `artifact://r2/<bucket>/<key>` | Stored in Cloudflare R2 | `artifact://r2/agentland-artifacts/policy/2024/01/abc.json` | Active (OBJECT_STORE_PROVIDER=r2) |
| `artifact://s3/<bucket>/<key>` | Stored in AWS S3 (future) | `artifact://s3/agentland-artifacts/2024/01/abc123` | Not implemented |

**Routing Logic (Phase 13):**
- Artifacts < 64KB: Use `artifact://local/` (metadata-only in Postgres)
- Artifacts >= 64KB: Upload to configured object store (noop or r2)

Set `OBJECT_STORE_PROVIDER` environment variable to control routing:
- `noop` (default): In-memory storage for development/testing
- `r2`: Cloudflare R2 for production

---

## Artifact Integrity Rules

1. **Immutability**: Artifacts are append-only. Once created, they are never modified.

2. **Referential Integrity**: Artifact URIs in other tables (e.g., `ApprovalResult.artifact_uri`) must point to existing artifacts.

3. **Complete Context**: Every artifact must contain enough information to understand it without external context:
   - What created it (producer)
   - When (timestamp)
   - Why (triggering event)
   - What (payload)

4. **No Secrets**: Artifacts must never contain:
   - API keys
   - Passwords
   - Full LLM message content (summaries only)
   - PII without explicit consent

5. **Bounded Size**: Individual artifact metadata should not exceed 64KB. Large content goes to object storage; artifact stores the URI.

---

## Telemetry Correlation

Every artifact emission should occur within a traced span. The artifact metadata should include:
- `trace_id` (from current span)
- `span_id` (from current span)

This enables correlation between:
- Artifacts (what was produced)
- Traces (how it was produced)
- Logs (what happened during production)

---

## Adding New Artifact Types

When introducing a new artifact type:

1. Add an entry to this document with all required fields
2. Implement the producer to emit the artifact
3. Ensure the artifact is emitted within a traced span
4. Update `scripts/validate_artifacts.py` to check for the new type (if validation exists)
5. Reference the artifact type in the relevant ADR

---

## Summary

| Category | Artifact Types | Count |
|----------|---------------|-------|
| Policy | policy_evaluation | 1 |
| Execution | execution_start, execution_checkpoint, execution_end | 3 |
| Module | module_execution, noop_executed, echo_result, intentional_failure | 4 |
| LLM | llm_call, llm_usage | 2 |
| Memory | memory_read_attempt | 1 |
| **Total** | | **11** |
