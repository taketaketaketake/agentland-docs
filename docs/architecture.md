# Architecture

## Current State

### Implemented

[List implemented components]

### Not Yet Implemented

[List pending components]

<!--
EXAMPLE (delete when filling in):

### Implemented

- API Gateway with tenant-aware routing and JWT auth
- Order Service with full lifecycle (placed → confirmed → preparing → ready → picked up)
- Kitchen Router assigning items to prep stations by menu category
- Inventory Tracker with event-sourced stock management
- PostgreSQL with per-location schema isolation

### Not Yet Implemented

- Third-party delivery webhooks (DoorDash, Uber Eats)
- Real-time kitchen display WebSocket push
- Cross-location reporting via read replicas
-->

## Layers

```
[Describe your architecture layers]
```

<!--
EXAMPLE (delete when filling in):

```
┌──────────────────────────────────────────────┐
│  CLIENTS       Kiosks · Mobile App · Webhooks │
├──────────────────────────────────────────────┤
│  GATEWAY       Auth · Rate Limiting · Routing │
├──────────────────────────────────────────────┤
│  SERVICES      Orders · Kitchen · Inventory   │
├──────────────────────────────────────────────┤
│  INTEGRATIONS  DoorDash · Uber · Square POS   │
├──────────────────────────────────────────────┤
│  DATA          PostgreSQL · Redis · Event Log  │
└──────────────────────────────────────────────┘
```
-->

## Boundaries

### Sacred Rule

[Define the most important architectural boundary]

### Current Boundary Integrity

[Describe boundary enforcement status]

<!--
EXAMPLE (delete when filling in):

### Sacred Rule

Orders are immutable after kitchen confirmation. No service may modify a
confirmed order. Modifications create a new linked order. This is enforced
at the database level with a CHECK constraint on order status transitions.

### Current Boundary Integrity

- Order immutability: ENFORCED (DB constraint + service validation)
- Inventory event sourcing: ENFORCED (no UPDATE queries on stock table)
- Integration isolation: ENFORCED (only Integration Service holds third-party credentials)
- Tenant isolation: ENFORCED (RLS policies on all tenant-scoped tables)
-->

## Infrastructure

### Services

[List services and their purposes]

### Databases

[List databases and their roles]

<!--
EXAMPLE (delete when filling in):

### Services

| Service | Port | Purpose |
|---|---|---|
| API Gateway | 3000 | Auth, rate limiting, tenant routing |
| Order Service | 3001 | Order lifecycle management |
| Kitchen Router | 3002 | Prep station assignment and load balancing |
| Inventory Tracker | 3003 | Real-time stock management (event-sourced) |
| Notification Hub | 3004 | SMS/push/webhook delivery for order status |
| Integration Service | 3005 | Third-party API adapter (DoorDash, Uber, Square) |

### Databases

| Instance | Purpose | Key Tables |
|---|---|---|
| PostgreSQL (primary) | Transactional data | orders, order_items, locations, menus |
| PostgreSQL (inventory) | Event-sourced stock | stock_events, stock_snapshots |
| Redis | Session cache, pub/sub | Order status broadcasts to kitchen displays |
-->
