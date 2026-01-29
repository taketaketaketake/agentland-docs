# Markdown File Relationship Map

<!-- This document visualizes the relationships between all markdown files in your repository. -->
<!-- Generate this map after setting up your documentation structure. -->

## Table of Contents

- [Visual Map](#visual-map)
- [File Index](#file-index)
- [Relationship Types](#relationship-types)

---

## Visual Map

<!-- Create an ASCII diagram showing how your documentation files relate to each other. -->
<!-- Example structure: -->

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
        └───────────────────────┘   └──────────────────────┘   └────────────────────┘
```

---

## File Index

| File | Category | Role | Key Relationships |
|------|----------|------|-------------------|
| **README.md** | Entry Point | Repository overview | |
| **CLAUDE.md** | AI Instructions | Persistent context | |
| **implementation-plan.md** | Planning | Phase tracking | |

<!-- Add all your markdown files here -->

---

## Relationship Types

| Type | Symbol | Description |
|------|--------|-------------|
| **Authoritative Source** | `═══>` | File is the single source of truth |
| **Enforcement/Procedure** | `◄══►` | File enforces rules or procedures |
| **Documentation Pointer** | `───>` | Simple reference or link |
| **Creates/Generates** | `╰──►` | File creates or generates another |
| **Appends To** | `++=>` | File appends data to another |
| **Validates Against** | `✓──>` | File validates using another as reference |

---

## Update Protocol

This file should be updated when:
- New markdown files are added to the repository
- Existing markdown files are renamed or moved
- Cross-references between markdown files change
- The relationship structure of the documentation changes significantly
