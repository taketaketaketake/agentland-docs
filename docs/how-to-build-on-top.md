# How to Build on Top of This Repository

## Purpose

This repository provides a complete, governed infrastructure spine for agentic systems.

It is not a product.
It is not an application.
It intentionally contains no business logic or cognition.

This document explains how to correctly build a production system on top of this repository without violating its architectural guarantees.

---

## What This Repository Guarantees

This codebase guarantees:

**Deterministic interfaces for:**
- LLM access
- Memory consumption
- Execution
- Evaluation
- Telemetry

**Strong governance:**
- Phase audits
- Validation scripts
- CI enforcement
- Append-only invariants

**Clear separation between:**
- Infrastructure
- Cognition
- Execution

**Replaceable implementations** (providers, stores, services)

If you respect these boundaries, your system will remain auditable, testable, and maintainable.

---

## What This Repository Does Not Contain

This repository intentionally does not include:

- Agents or reasoning logic
- Prompts or prompt templates
- Business logic
- Product workflows
- User-facing APIs
- Authentication or authorization
- Deployment or operations tooling

These must live outside this repo.

---

## Supported Integration Model

You should not add product code directly to this repository.

### Correct approaches

Choose one:

**Option A — Fork (recommended)**
1. Fork this repo
2. Treat the fork as your product repo
3. Add agents and business logic there
4. Periodically rebase from upstream infra

**Option B — Dependency**
1. Import this repo as a library/module
2. Build agents and workflows in a separate repo
3. Pin versions explicitly

---

## Architectural Rule (Non-Negotiable)

> Infrastructure provides capabilities.
> Products provide intent.

This repository must never:
- Decide what to do
- Decide why to do it
- Contain domain-specific rules

---

## How to Add Cognition (Agents)

Agents live outside this repo.

Agents consume infrastructure via interfaces:

```python
from agentland.infra.llm import get_llm_provider, LLMRequest
from agentland.infra.memory import PostgresMemoryReader
from agentland.infra.directives import transition_directive_status
```

Agents:
- Read memory (via `MemoryReader`)
- Call LLMs (via `LLMProvider`)
- Create directives (via database writes)
- Never execute directly

---

## How to Add Business Logic

Business logic belongs in execution modules in the product layer.

### Correct pattern

1. Define new `ExecutionModule` implementations
2. Register them in the execution registry
3. Allow policy to approve or block their use
4. Execute them through the execution workflow

### Incorrect pattern

- Calling APIs directly from agents
- Writing to memory directly
- Bypassing execution orchestration

---

## How to Use LLMs Safely

LLMs are accessed only through:

```
call_llm → LLMProvider → instrumentation → artifacts
```

**Never:**
- Call SDKs directly
- Bypass telemetry
- Embed prompts inside infra

**You may:**
- Define prompts inside agents
- Version prompts externally
- Treat prompts as business logic

---

## How Memory Should Be Used

Memory is read-only to agents.

**Agents may:**
- Query summaries
- Perform semantic search
- Inspect artifacts

**Agents may not:**
- Write memory
- Access tables directly
- Access embeddings directly

All memory writes happen through:
- Execution
- Artifacts
- Workflow state

---

## Validation and Governance Expectations

When building on top of this repo:

1. **Respect invariants** — Read `docs/invariants.md` before making changes
2. **Use interfaces** — Never bypass Protocols with direct implementations
3. **Emit artifacts** — All significant actions should produce artifacts
4. **Instrument everything** — Use the telemetry layer for observability
5. **Keep infra stable** — Changes to infra require ADRs

---

## Recommended Repository Structure (Product)

Example structure for a product repo:

```
product-repo/
├── infra/                 # Imported or forked infra
├── agents/
│   ├── planner.py
│   ├── evaluator.py
│   └── router.py
├── prompts/
│   ├── planner_v1.md
│   └── planner_v2.md
├── modules/
│   ├── send_email.py
│   └── http_request.py
├── workflows/
│   └── product_workflows.py
├── deployment/
│   ├── terraform/
│   └── kubernetes/
└── README.md
```

---

## Stability Contract

This repository should be treated as:

- Slow-moving
- Heavily governed
- Backward-compatible

Product repos should move fast.
Infrastructure should move carefully.

---

## Final Guidance

If you feel the urge to:

- "Just add a little logic here"
- "Quickly bypass this interface"
- "Make infra smarter"

**Stop.**

That logic belongs in the product layer.

This repo exists so that when agents fail, hallucinate, or behave badly — the infrastructure remains correct, auditable, and recoverable.
