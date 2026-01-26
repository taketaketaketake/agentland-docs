# Models

## Database Schema (Phase 2)

All tables use minimal schema: IDs, timestamps, TEXT for semantic fields.
No enums. No CHECK constraints. Business logic deferred to later phases.

### Governance Tables

#### agent_roles

Tracks role definitions and their current implementations.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| role_name | VARCHAR(255) | PRIMARY KEY | Unique role identifier |
| current_impl | VARCHAR(255) | nullable | Current implementation binding |
| status | TEXT | NOT NULL, default 'active' | Role status |
| last_review | TIMESTAMP WITH TIME ZONE | nullable | Last evaluation timestamp |
| created_at | TIMESTAMP WITH TIME ZONE | NOT NULL, default NOW() | Creation timestamp |

#### directives

Stores directive records (frozen intent). Directives are the hard boundary between thinking and doing.

**Core fields (Phase 2):**

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | UUID | PRIMARY KEY, default gen_random_uuid() | Unique identifier |
| role | TEXT | NOT NULL | Who the directive is addressed to (target) |
| type | TEXT | NOT NULL | Directive categorization |
| payload | JSONB | NOT NULL, default '{}' | Directive data |
| status | TEXT | NOT NULL, default 'draft' | Lifecycle status |
| created_at | TIMESTAMP WITH TIME ZONE | NOT NULL, default NOW() | Creation timestamp |

**Extended fields (Phase 4 - Directive Contract):**

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| issued_by | TEXT | NOT NULL | Who created this directive |
| objective | TEXT | NOT NULL | What to achieve |
| scope | TEXT | NOT NULL | Boundaries |
| constraints | JSONB | nullable | Limits (structured) |
| success_metrics | JSONB | nullable | Definition of done (structured) |
| budget | TEXT | nullable | Resource limit (text, not enforced) |
| timebox | TEXT | nullable | Time limit (text, not enforced) |

**Field Semantics:**
- `issued_by`: The creator of the directive (origin)
- `role`: The target - who the directive is addressed to
- `status`: Lifecycle state (lowercase ASCII by convention)

**Status Lifecycle:**

```
draft -> proposed -> approved -> executing -> complete
              |           |            |
              v           v            v
           blocked     blocked     aborted
              |
              v
           proposed (retry)
```

Valid transitions:
- `draft` → `proposed`
- `proposed` → `approved`, `blocked`
- `approved` → `executing`, `blocked`
- `executing` → `complete`, `aborted`
- `blocked` → `proposed` (retry)
- `complete`, `aborted` → (terminal, no further transitions)

### Memory Tables

#### memories

Stores memory entries.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | UUID | PRIMARY KEY, default gen_random_uuid() | Unique identifier |
| scope | TEXT | NOT NULL | Memory scope/visibility |
| content | TEXT | NOT NULL | Memory content |
| created_at | TIMESTAMP WITH TIME ZONE | NOT NULL, default NOW() | Creation timestamp |

#### memory_embeddings

Stores vector embeddings for semantic search.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| memory_id | UUID | PRIMARY KEY, FOREIGN KEY → memories.id ON DELETE CASCADE | Associated memory |
| embedding | VECTOR(1536) | NOT NULL | Embedding vector |
| created_at | TIMESTAMP WITH TIME ZONE | NOT NULL, default NOW() | Creation timestamp |

### Artifact Tables

#### artifacts

References to external artifacts (stored in object storage).

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | UUID | PRIMARY KEY, default gen_random_uuid() | Unique identifier |
| type | TEXT | NOT NULL | Artifact type |
| uri | TEXT | NOT NULL | Reference to external storage |
| created_at | TIMESTAMP WITH TIME ZONE | NOT NULL, default NOW() | Creation timestamp |

---

## Pydantic Models

Located in `src/infra/models/`. These are I/O contracts only — no business logic.

### Pattern

Each table has two models:
- `*Create` — input for INSERT (excludes auto-generated fields)
- `*Read` — output from SELECT (includes all fields)

### Governance (`src/infra/models/governance.py`)

```python
AgentRoleCreate(role_name, current_impl?, status?, last_review?)
AgentRoleRead(role_name, current_impl, status, last_review, created_at)

# Phase 4: Directive Contract (no default status - explicit intent required)
DirectiveCreate(
    issued_by,       # who created this
    objective,       # what to achieve
    scope,           # boundaries
    role,            # who it's addressed to (target)
    type,            # categorization
    status,          # REQUIRED - no default (explicit intent)
    constraints?,    # limits (dict)
    success_metrics?, # definition of done (dict)
    budget?,         # resource limit (text)
    timebox?,        # time limit (text)
    payload?         # additional data (dict, default {})
)

DirectiveRead(
    id, issued_by, objective, scope, role, type, status,
    constraints, success_metrics, budget, timebox,
    payload, created_at
)
```

### Directives (`src/infra/directives/`)

Directive lifecycle management (Phase 4):

```python
# Pure functions (no DB access)
validate_transition(current, next) -> bool
get_valid_next_statuses(current) -> list[str]
is_terminal_status(status) -> bool

# Single mutator (only function that writes to directives.status)
transition_directive_status(engine, directive_id, new_status) -> bool

# JSON schema export (read-only documentation)
get_directive_json_schema() -> dict
```

### Memory (`src/infra/models/memory.py`)

```python
MemoryCreate(scope, content)
MemoryRead(id, scope, content, created_at)

MemoryEmbeddingCreate(memory_id, embedding[1536])
MemoryEmbeddingRead(memory_id, embedding, created_at)
```

### Artifacts (`src/infra/models/artifacts.py`)

```python
ArtifactCreate(type, uri)
ArtifactRead(id, type, uri, created_at)
```

---

## Design Notes

### Why TEXT instead of ENUM?

Enums are semantic constraints that become premature design commitments.
TEXT fields allow flexibility during infrastructure phases.
Status values are lowercase ASCII strings by convention (draft, proposed, approved, etc.)
but are not enforced at the database schema level. Transitions are enforced in code.

### Why no FK from directives.role?

Foreign key to agent_roles would require:
- Roles created before directives
- Role names immutable

In early scaffolding, this creates ordering constraints.
The FK can be added when governance semantics are finalized.

### Why separate agentland database?

Application tables should not mix with Temporal's persistence tables.
Separation enables independent migrations, backups, and access control.

---

## Policy Models (Phase 5)

Located in `src/infra/policy/`. These are deterministic evaluation structures.

### Types (`src/infra/policy/types.py`)

```python
class PolicyVerdict(Enum):
    ALLOW = "allow"
    BLOCK = "block"

@dataclass(frozen=True)
class PolicyResult:
    verdict: PolicyVerdict
    reason: str
    policy_name: str
```

### Config (`src/infra/policy/config.py`)

```python
@dataclass(frozen=True)
class PolicyConfig:
    version: str              # Explicit versioning (e.g., "v1")
    budget_ceiling: Decimal   # Maximum allowed budget
    tool_allowlist: frozenset[str]   # Allowed directive types
    scope_allowlist: frozenset[str]  # Allowed scopes

DEFAULT_POLICY = PolicyConfig(
    version="v1",
    budget_ceiling=Decimal("100.00"),
    tool_allowlist=frozenset({"noop", "echo", "validate", "test"}),
    scope_allowlist=frozenset({"test", "development", "staging"}),
)
```

### Engine (`src/infra/policy/engine.py`)

```python
evaluate_directive(engine, directive_id, config) -> list[PolicyResult]
has_blocking_verdict(results) -> bool
get_block_reasons(results) -> list[str]
```

---

## Workflow Models (Phase 5)

Located in `src/workflows/`. These are Temporal workflow data structures.

### ApprovalResult (`src/workflows/approval.py`)

```python
@dataclass
class ApprovalResult:
    approved: bool             # Whether directive was approved
    directive_id: str          # UUID of evaluated directive
    policy_version: str        # Version of policy used
    policy_blocks: list[str]   # Reasons if blocked by policy
    human_override: bool       # True if human explicitly approved/rejected
    reason: str | None         # Human-provided reason
    artifact_uri: str | None   # URI of stored policy evaluation artifact
```

The `human_override` field distinguishes:
- Auto-approved (passed policy, no human required): `human_override=False`
- Human-approved (passed policy, human confirmed): `human_override=True`
- Human-rejected (passed policy, human blocked): `human_override=True`

This enables auditing of how each directive was approved.

---

## Execution Tables (Phase 6)

### execution_runs

Tracks execution attempts for approved directives. Supports retries (directive can have multiple runs).

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | UUID | PRIMARY KEY, default gen_random_uuid() | Unique run identifier |
| directive_id | UUID | FOREIGN KEY → directives.id, NOT NULL | Associated directive |
| status | TEXT | NOT NULL, default 'pending' | Execution status |
| started_at | TIMESTAMP WITH TIME ZONE | nullable | When execution started |
| completed_at | TIMESTAMP WITH TIME ZONE | nullable | When execution finished |
| created_at | TIMESTAMP WITH TIME ZONE | NOT NULL, default NOW() | Creation timestamp |

**Indexes:**
- `ix_execution_runs_directive_id` on directive_id
- `ix_execution_runs_status` on status

**Status Lifecycle:**

```
pending -> running -> completed
                  |-> failed
                  |-> canceled
```

Valid transitions:
- `pending` → `running`
- `running` → `completed`, `failed`, `canceled`
- `completed`, `failed`, `canceled` → (terminal, no further transitions)

---

## Execution Models (Phase 6)

Located in `src/infra/models/execution.py`. These are I/O contracts only.

### Pydantic Models

```python
class ExecutionRunCreate(BaseModel):
    directive_id: UUID
    status: str = "pending"

class ExecutionRunRead(BaseModel):
    id: UUID
    directive_id: UUID
    status: str
    started_at: Optional[datetime]
    completed_at: Optional[datetime]
    created_at: datetime
    model_config = {"from_attributes": True}
```

### Execution Lifecycle (`src/infra/execution/lifecycle.py`)

```python
# Pure functions (no DB access)
validate_transition(current, next) -> bool
get_valid_next_statuses(current) -> list[str]
is_terminal_status(status) -> bool

# Single mutator (only function that writes to execution_runs.status)
transition_execution_status(engine, run_id, new_status) -> bool
```

The single mutator pattern ensures all status changes go through one validated code path.
It also manages timestamp updates (`started_at` when transitioning to running, `completed_at` when transitioning to terminal states).
