# Markdown File Relationship Map

This document visualizes the relationships between all markdown files in the agentland-docs repository.

## Table of Contents

- [Visual Map](#visual-map)
- [File Index](#file-index)
- [Detailed Relationships](#detailed-relationships)
- [Relationship Types](#relationship-types)
- [Hub Analysis](#hub-analysis)

---

## Visual Map

```
                                    ┌─────────────────────────┐
                                    │  markdown-glossary.md   │
                                    │  (Central Hub)          │
                                    │  Authoritative source   │
                                    │  for update triggers    │
                                    └───────────┬─────────────┘
                                                │
                    ┌───────────────────────────┼──────────────────────────┐
                    │                           │                          │
        ┌───────────▼───────────┐   ┌───────────▼──────────┐   ┌──────────▼─────────┐
        │     README.md         │   │   CLAUDE.md          │   │ implementation-    │
        │                       │   │                      │   │ plan.md            │
        │  - Entry point        │   │  - AI instructions   │   │                    │
        │  - Overview           │   │  - Phase protocol    │   │  - Phase tracking  │
        └───────────────────────┘   └──────────┬───────────┘   └─────────┬──────────┘
                                               │                          │
                                    ┌──────────▼──────────┐              │
                                    │   vision.md         │              │
                                    │   architecture.md   │              │
                                    │   invariants.md     │              │
                                    │   models.md         │              │
                                    └─────────────────────┘              │
                                                                         │
        ┌────────────────────────────────────────────────────────────────┘
        │
        │         ┌─────────────────────────┐           ┌──────────────────────────┐
        └────────►│  phase-audit.md         │──────────►│  phase-NN-audit.md      │
                  │  (Skill/Enforcement)    │  creates  │  (Generated reports)     │
                  │                         │           │                          │
                  └────┬────────────────────┘           └──────────────────────────┘
                       │
                       │ validates
                       │
                  ┌────▼────────────────────┐
                  │  adr-template.md        │
                  │                         │
                  └─────────────────────────┘
                       │
                       │ used by
                       │
                  ┌────▼────────────────────┐
                  │  adr-001-*.md           │
                  │  (Actual ADRs)          │
                  └─────────────────────────┘


        ┌─────────────────────────┐           ┌──────────────────────────┐
        │  codebase-health.md     │──────────►│  health-log.md          │
        │  (Skill/Monitoring)     │  appends  │  (Health reports)        │
        │                         │           │                          │
        └─────────────────────────┘           └──────────────────────────┘


        ┌─────────────────────────┐
        │  stubs.md               │
        │  artifacts.md           │◄──────── Referenced by phase-audit.md
        │  contracts.md           │          (Retrospective checks)
        │  glossary.md            │
        └─────────────────────────┘
```

---

## File Index

| File | Category | Role | Key Relationships |
|------|----------|------|-------------------|
| **README.md** | Entry Point | Repository overview | → vision.md, markdown-glossary.md |
| **CLAUDE.md** | AI Instructions | Persistent context for Claude | → vision.md, README.md, markdown-glossary.md, invariants.md |
| **implementation-plan.md** | Planning | Phase tracking and status | ← phase-audit.md, codebase-health.md |
| **docs/vision.md** | Core Docs | Long-term intent | ← CLAUDE.md, README.md |
| **docs/architecture.md** | Core Docs | Structural reality | ← markdown-glossary.md |
| **docs/invariants.md** | Core Docs | Non-negotiable constraints | ← CLAUDE.md |
| **docs/models.md** | Core Docs | Data models | ← markdown-glossary.md |
| **docs/glossary/markdown-glossary.md** | Authority | Update trigger definitions | → 15+ files (Hub) |
| **docs/glossary/glossary.md** | Reference | Term definitions | ← markdown-glossary.md |
| **docs/health-log.md** | Monitoring | Health check results | ← codebase-health.md |
| **docs/stubs.md** | Registry | Stub tracking | ← phase-audit.md (retrospective) |
| **docs/artifacts.md** | Taxonomy | Artifact definitions | ← phase-audit.md (retrospective) |
| **docs/contracts.md** | Interfaces | Contract specifications | ← phase-audit.md (retrospective) |
| **docs/decisions/adr-template.md** | Template | ADR structure | ← phase-audit.md (validation) |
| **docs/audits/phase-NN-audit.md** | Reports | Phase audit results | ← phase-audit.md (creates) |
| **skills/llm/phase-audit.md** | Skill | Phase completion audit | → markdown-glossary.md, implementation-plan.md, adr-template.md |
| **skills/llm/codebase-health.md** | Skill | Health monitoring | → implementation-plan.md, health-log.md |
| **scripts/hooks/README.md** | Tooling | Git hooks documentation | (Independent) |

---

## Detailed Relationships

### CLAUDE.md
**Type:** AI Instructions  
**Description:** Provides persistent, high-signal context for Claude when working in the repository.

**Outgoing References:**
- `@docs/vision.md` - Defines long-term intent
- `@README.md` - Repository overview
- `@docs/glossary/markdown-glossary.md` - Authoritative source for update triggers
- `docs/invariants.md` - References invariant about phase completion

**Incoming References:** None (top-level instruction file)

---

### skills/llm/phase-audit.md
**Type:** Skill (Enforcement)  
**Description:** Validates phase completion requirements and enforces documentation updates.

**Outgoing References:**
- `docs/glossary/markdown-glossary.md` (lines 40, 32, 262, 343) - Authoritative for update triggers
- `docs/decisions/adr-template.md` (lines 97, 262-263) - ADR structure validation
- `implementation-plan.md` (lines 47, 75-81, 258) - Phase tracking
- `docs/stubs.md` (line 356) - Stub registry (retrospective)
- `docs/artifacts.md` (line 356) - Artifact taxonomy (retrospective)
- `docs/contracts.md` (line 356) - Interface contracts (retrospective)
- `docs/audits/phase-NN-audit.md` (lines 214-251) - Creates audit files

**Incoming References:**
- Referenced by CLAUDE.md as part of Phase Completion Protocol

---

### skills/llm/codebase-health.md
**Type:** Skill (Monitoring)  
**Description:** Performs health checks on the codebase and logs results.

**Outgoing References:**
- `implementation-plan.md` (line 47) - Reads phase status
- `docs/health-log.md` (lines 5, 84) - Appends health check results

**Incoming References:** None (invoked as needed)

---

### docs/glossary/markdown-glossary.md
**Type:** Authority Document (Central Hub)  
**Description:** The authoritative source for update triggers. Defines when and how each markdown file should be updated.

**Outgoing References (Documents update triggers for 15+ files):**
- `README.md` (lines 42-69)
- `CLAUDE.md` (lines 73-100)
- `implementation-plan.md` (lines 103-129)
- `docs/vision.md` (lines 180-204)
- `docs/architecture.md` (lines 206-232)
- `docs/invariants.md` (lines 234-257)
- `docs/models.md` (lines 259-283)
- `docs/health-log.md` (lines 285-310)
- `docs/decisions/adr-template.md` (lines 531-559)
- `docs/stubs.md` (lines 373-399)
- `docs/artifacts.md` (lines 403-429)
- `docs/contracts.md` (lines 468-494)
- `docs/audits/phase-NN-audit.md` (lines 433-465)
- `docs/glossary/glossary.md` (lines 498-515)

**Incoming References:**
- `CLAUDE.md` - Cites as authoritative source
- `skills/llm/phase-audit.md` - Uses for validation logic
- `README.md` - Points to for documentation structure

---

### README.md
**Type:** Entry Point  
**Description:** Repository overview and entry point for developers.

**Outgoing References:**
- `docs/vision.md` - "See [docs/vision.md](docs/vision.md)" (line 45)
- `docs/glossary/markdown-glossary.md` - "See [docs/glossary/markdown-glossary.md]" (line 47)

**Incoming References:**
- `CLAUDE.md` - @README.md reference
- `docs/glossary/markdown-glossary.md` - Documents when to update

---

### implementation-plan.md
**Type:** Planning Document  
**Description:** Tracks phase implementation status and progress.

**Outgoing References:** None (leaf node in terms of outbound references)

**Incoming References:**
- `skills/llm/phase-audit.md` - Reads and validates phase status
- `skills/llm/codebase-health.md` - Reads phase information
- `docs/glossary/markdown-glossary.md` - Documents update triggers

---

### docs/vision.md
**Type:** Core Documentation  
**Description:** Defines the long-term vision and intent of the system.

**Outgoing References:** None

**Incoming References:**
- `CLAUDE.md` - @docs/vision.md reference
- `README.md` - Links to vision
- `docs/glossary/markdown-glossary.md` - Documents update triggers

---

### docs/architecture.md
**Type:** Core Documentation  
**Description:** Defines the structural reality and architecture of the system.

**Outgoing References:** None

**Incoming References:**
- `docs/glossary/markdown-glossary.md` - Documents update triggers

---

### docs/invariants.md
**Type:** Core Documentation  
**Description:** Defines non-negotiable constraints and rules.

**Outgoing References:** None

**Incoming References:**
- `CLAUDE.md` - References §15 (Phase Completion Protocol)
- `docs/glossary/markdown-glossary.md` - Documents update triggers

---

### docs/models.md
**Type:** Core Documentation  
**Description:** Defines data models and structures.

**Outgoing References:** None

**Incoming References:**
- `docs/glossary/markdown-glossary.md` - Documents update triggers

---

### docs/health-log.md
**Type:** Log File  
**Description:** Records health check results over time.

**Outgoing References:** None

**Incoming References:**
- `skills/llm/codebase-health.md` - Appends results
- `docs/glossary/markdown-glossary.md` - Documents update triggers

---

### docs/stubs.md
**Type:** Registry  
**Description:** Tracks stub implementations and placeholders.

**Outgoing References:** None

**Incoming References:**
- `skills/llm/phase-audit.md` - Retrospective validation
- `docs/glossary/markdown-glossary.md` - Documents update triggers

---

### docs/artifacts.md
**Type:** Taxonomy  
**Description:** Defines artifact types and classifications.

**Outgoing References:** None

**Incoming References:**
- `skills/llm/phase-audit.md` - Retrospective validation
- `docs/glossary/markdown-glossary.md` - Documents update triggers

---

### docs/contracts.md
**Type:** Interface Specification  
**Description:** Defines interface contracts and specifications.

**Outgoing References:** None

**Incoming References:**
- `skills/llm/phase-audit.md` - Retrospective validation
- `docs/glossary/markdown-glossary.md` - Documents update triggers

---

### docs/decisions/adr-template.md
**Type:** Template  
**Description:** Template for Architecture Decision Records.

**Outgoing References:** None

**Incoming References:**
- `skills/llm/phase-audit.md` - Validates ADR structure
- `docs/glossary/markdown-glossary.md` - Documents update triggers

---

### docs/audits/phase-NN-audit.md
**Type:** Generated Report  
**Description:** Phase completion audit reports (created by phase-audit.md skill).

**Outgoing References:**
- References to ADR files created during the phase (e.g., `docs/decisions/adr-001-agent-runtime.md`)

**Incoming References:**
- Created by `skills/llm/phase-audit.md`
- Template defined in `docs/glossary/markdown-glossary.md`

---

### docs/glossary/glossary.md
**Type:** Reference  
**Description:** Defines terms and concepts used throughout the repository.

**Outgoing References:** None

**Incoming References:**
- `docs/glossary/markdown-glossary.md` - Documents update triggers

---

### scripts/hooks/README.md
**Type:** Tooling Documentation  
**Description:** Documents Git hooks and automation scripts.

**Outgoing References:** None

**Incoming References:** None (independent tooling documentation)

---

## Relationship Types

| Type | Symbol | Description | Count |
|------|--------|-------------|-------|
| **Authoritative Source** | `═══>` | File is the single source of truth | 3 |
| **Enforcement/Procedure** | `◄══►` | File enforces rules or procedures | 2 |
| **Documentation Pointer** | `───>` | Simple reference or link | 10+ |
| **Creates/Generates** | `╰──►` | File creates or generates another | 2 |
| **Appends To** | `++=>` | File appends data to another | 1 |
| **Validates Against** | `✓──>` | File validates using another as reference | 4 |
| **Retrospective Check** | `⟲──>` | File checks for consistency in hindsight | 3 |

---

## Hub Analysis

### Central Hub: docs/glossary/markdown-glossary.md

**Why it's the hub:**
- Referenced by 3+ critical files (CLAUDE.md, phase-audit.md, README.md)
- Documents update triggers for 15+ other files
- Explicitly cited as "authoritative source" in multiple places
- Acts as the routing mechanism for documentation updates

**Connections:** 15+ outgoing references

**Impact:** Changes to this file affect the entire documentation governance system

### Secondary Hubs

1. **CLAUDE.md** (4 outgoing references)
   - Critical for AI collaboration
   - References core documentation
   - Enforces Phase Completion Protocol

2. **skills/llm/phase-audit.md** (7+ outgoing references)
   - Enforcement mechanism
   - Validates multiple file types
   - Creates audit reports

### Leaf Nodes (No outgoing references)

Files that are referenced but don't reference others:
- docs/vision.md
- docs/architecture.md
- docs/invariants.md
- docs/models.md
- docs/health-log.md
- docs/stubs.md
- docs/artifacts.md
- docs/contracts.md
- docs/glossary/glossary.md
- docs/decisions/adr-template.md
- scripts/hooks/README.md
- implementation-plan.md

---

## Usage Notes

### For Developers
1. Start with **README.md** for an overview
2. Read **CLAUDE.md** if you're working with AI agents
3. Consult **docs/glossary/markdown-glossary.md** to understand when files should be updated
4. Check **implementation-plan.md** for current phase status

### For AI Agents
1. **CLAUDE.md** is your primary instruction set
2. **docs/glossary/markdown-glossary.md** defines your update responsibilities
3. **skills/llm/phase-audit.md** defines the phase completion protocol
4. **docs/invariants.md** contains non-negotiable rules

### For Documentation Updates
1. Consult **docs/glossary/markdown-glossary.md** for update triggers
2. Use **skills/llm/phase-audit.md** to validate completeness
3. Follow **docs/decisions/adr-template.md** for architectural decisions

---

## Metadata

- **Created:** 2026-01-27
- **Total Markdown Files:** 18
- **Total Relationships Mapped:** 50+
- **Central Hub:** docs/glossary/markdown-glossary.md
- **Deepest Dependency Chain:** CLAUDE.md → markdown-glossary.md → (15 files)
- **Independent Files:** 1 (scripts/hooks/README.md)

---

## Update Protocol

This file should be updated when:
- New markdown files are added to the repository
- Existing markdown files are renamed or moved
- Cross-references between markdown files change
- The relationship structure of the documentation changes significantly

**Responsibility:** Maintainers should review this map quarterly or when making significant documentation restructuring.
