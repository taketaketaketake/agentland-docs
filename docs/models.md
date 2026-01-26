# Models

## Database Schema (Phase 2)

All tables use minimal schema: IDs, timestamps, TEXT for semantic fields.
No enums. No CHECK constraints. Business logic deferred to later phases.

### Governance Tables

#### 

#### 

### 

#### 

#### 

### 

#### 

## 

### 

### 
```

### 
```

### 
```

### 
```

---

## 

### 

### Why no FK from directives.role?

Foreign key to agent_roles would require:
- Roles created before directives
- Role names immutable

In early scaffolding, this creates ordering constraints.
The FK can be added when governance semantics are finalized.

### 
---


```

The single mutator pattern ensures all status changes go through one validated code path.
It also manages timestamp updates (`started_at` when transitioning to running, `completed_at` when transitioning to terminal states).
