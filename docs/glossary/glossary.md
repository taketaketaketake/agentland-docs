# Glossary

This glossary defines **canonical meanings** for terms used throughout the repository.
These definitions are authoritative and intended to prevent semantic drift across time,
contributors, and LLM sessions.

---

## Agent

An **agent** is a stateless or semi-stateless reasoning component that:

- Consumes context, goals, and evidence
- Produces structured outputs (plans, directives, evaluations)
- Does not directly execute side effects

Agents are replaceable implementations bound to persistent roles.

---

## Role

A **role** is a long-lived responsibility within the system, such as:

- Executive
- Planner
- Supervisor
- Evaluator

Roles define:
- Scope of authority
- Inputs and outputs
- Evaluation criteria
- Access boundaries

Roles persist even when agent implementations change.

---

## Cognition Layer

The **cognition layer** is the part of the system responsible for:

- Interpreting reality
- Setting goals and priorities
- Making decisions
- Generating plans
- Evaluating outcomes

It does not perform execution.
It produces intent.

---

## Execution Layer

The **execution layer** performs real-world actions in a bounded, deterministic way.

It:
- Receives directives
- Executes approved actions
- Produces results and artifacts
- Does not make strategic decisions

Execution modules may be code, services, or humans.

---

## Directive

A **directive** is a frozen, structured expression of intent produced by cognition.

A directive:
- Describes *what should be done*
- Does not describe *how it is done*
- Is immutable once issued
- Can be approved, rejected, or modified via policy

Directives are the bridge between cognition and execution.

---

## Directive Contract

A **directive contract** defines the schema and constraints for directives, including:

- Required fields
- Allowed actions
- Metadata
- Traceability requirements

This ensures directives are machine-validated and auditable.

---

## Policy Gate

A **policy gate** is a control point that evaluates directives before execution.

It may:
- Allow
- Block
- Escalate
- Require human approval

Policies enforce safety, cost, compliance, and business rules.

---

## Orchestration

**Orchestration** is the coordination of time, dependencies, and retries across the system.

Temporal is used to:
- Schedule cognition and evaluation
- Enforce cadence
- Coordinate multi-step workflows
- Persist short-term workflow state

---

## Memory

**Memory** refers to all persistent or semi-persistent state external to agents.

Agents do not own memory; they access it via defined interfaces.

---

## Relational Memory (Postgres)

Structured, authoritative truth stored in Postgres.

Examples:
- Goals
- Metrics
- Tasks
- Role bindings
- Evaluation results

If Postgres says something happened, it happened.

---

## Vector Memory

Semantic memory stored as embeddings.

Used for:
- Conceptual recall
- Similarity search
- Historical context retrieval

This supports "search by meaning," not exact matching.

---

## Object Storage

An object store (e.g. Cloudflare R2) used for large, unstructured data.

Examples:
- Reports
- PDFs
- CSVs
- Logs
- Generated artifacts

Postgres stores references, not the objects themselves.

---

## Artifact

An **artifact** is a durable output produced by execution or analysis.

Artifacts are:
- Immutable or append-only
- Reviewable
- Auditable
- Referenced from structured memory

Artifacts are evidence, not opinion.

---

## Evaluation

**Evaluation** is the process of assessing outcomes relative to goals.

It is performed by:
- Supervisor or evaluator agents
- Rule-based checks
- Comparative benchmarks

Evaluations influence future planning and agent replacement.

---

## Performance Contract

A **performance contract** defines how an agent role is judged.

It includes:
- Success criteria
- Cost constraints
- Timeliness expectations
- Outcome alignment

Agents are aware of contracts but not enforcement mechanics.

---

## Replaceability

**Replaceability** means agent implementations can be swapped without:

- Losing memory
- Changing role definitions
- Disrupting workflows
- Invalidating evaluation history

This is a core architectural guarantee.
