#!/bin/bash
#
# PreToolUse hook: fires before git commit.
# BLOCKS the commit (exit 2) if:
#   1. A phase is marked COMPLETE without a corresponding audit file
#   2. Source files with STUB/asyncio.sleep markers exist without docs/stubs.md entries
#   3. Source files changed but glossary-triggered docs were not updated
#
# This is the hard gate. It cannot be bypassed by the LLM.
#

set -e

INPUT=$(cat)
PROJECT_DIR=$(echo "$INPUT" | jq -r '.cwd')
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Only fire on git commit commands
if [[ "$COMMAND" != *"git commit"* ]]; then
  exit 0
fi

ERRORS=()

# ─── Check 1: Phase completion without audit ─────────────────────
# If any phase in the plan is marked COMPLETE, there must be a
# corresponding docs/audits/phase-NN-audit.md file.

PLAN_FILE="$PROJECT_DIR/docs/plan/plan-template.md"
if [ -f "$PLAN_FILE" ]; then
  # Look for COMPLETE phases
  while IFS= read -r line; do
    PHASE_NUM=$(echo "$line" | grep -oE 'PHASE [0-9]+' | grep -oE '[0-9]+')
    if [ -n "$PHASE_NUM" ]; then
      AUDIT_FILE="$PROJECT_DIR/docs/audits/phase-${PHASE_NUM}-audit.md"
      if [ ! -f "$AUDIT_FILE" ]; then
        ERRORS+=("Phase $PHASE_NUM is marked COMPLETE but docs/audits/phase-${PHASE_NUM}-audit.md does not exist.")
      fi
    fi
  done < <(grep -i 'COMPLETE' "$PLAN_FILE" | grep -i 'PHASE' 2>/dev/null || true)
fi

# Also check any other plan files in docs/plan/
for plan in "$PROJECT_DIR"/docs/plan/*.md; do
  [ -f "$plan" ] || continue
  [ "$plan" = "$PLAN_FILE" ] && continue
  while IFS= read -r line; do
    PHASE_NUM=$(echo "$line" | grep -oE 'PHASE [0-9]+' | grep -oE '[0-9]+')
    if [ -n "$PHASE_NUM" ]; then
      AUDIT_FILE="$PROJECT_DIR/docs/audits/phase-${PHASE_NUM}-audit.md"
      if [ ! -f "$AUDIT_FILE" ]; then
        ERRORS+=("Phase $PHASE_NUM is marked COMPLETE in $(basename "$plan") but docs/audits/phase-${PHASE_NUM}-audit.md does not exist.")
      fi
    fi
  done < <(grep -i 'COMPLETE' "$plan" | grep -i 'PHASE' 2>/dev/null || true)
done

# ─── Check 2: Stub registry completeness ────────────────────────
# Scan staged source files for stub markers. Each must have an entry
# in docs/stubs.md.

STUBS_FILE="$PROJECT_DIR/docs/stubs.md"
STAGED_SRC=$(git -C "$PROJECT_DIR" diff --cached --name-only --diff-filter=d 2>/dev/null | grep -E '^src/' || true)

if [ -n "$STAGED_SRC" ] && [ -f "$STUBS_FILE" ]; then
  while IFS= read -r src_file; do
    FULL_PATH="$PROJECT_DIR/$src_file"
    [ -f "$FULL_PATH" ] || continue

    # Check for stub markers in staged content
    HAS_STUB=$(git -C "$PROJECT_DIR" show ":$src_file" 2>/dev/null | grep -inE '(STUB|# ---.*STUB|asyncio\.sleep.*#.*stub|async def.*stub)' | head -1 || true)

    if [ -n "$HAS_STUB" ]; then
      # Verify the file is mentioned in stubs.md
      if ! grep -q "$src_file" "$STUBS_FILE" 2>/dev/null; then
        ERRORS+=("$src_file contains stub markers but is not registered in docs/stubs.md")
      fi
    fi
  done <<< "$STAGED_SRC"
fi

# ─── Check 3: Glossary-triggered doc staleness ──────────────────
# If src/ files are staged but glossary-triggered docs are not,
# warn. Only block if contracts.md is stale (interface changes are
# high-risk).

STAGED_DOCS=$(git -C "$PROJECT_DIR" diff --cached --name-only 2>/dev/null | grep -E '^docs/' || true)

if [ -n "$STAGED_SRC" ]; then
  # contracts.md is mandatory when src/ changes
  if ! echo "$STAGED_DOCS" | grep -q 'docs/contracts.md' 2>/dev/null; then
    # Only block if interface-related files changed
    INTERFACE_CHANGES=$(echo "$STAGED_SRC" | grep -iE '(interface|protocol|schema|server\.py)' || true)
    if [ -n "$INTERFACE_CHANGES" ]; then
      ERRORS+=("Source interface files changed ($INTERFACE_CHANGES) but docs/contracts.md was not updated.")
    fi
  fi
fi

# ─── Verdict ─────────────────────────────────────────────────────

if [ ${#ERRORS[@]} -gt 0 ]; then
  {
    echo ""
    echo "=========================================="
    echo "  COMMIT BLOCKED: Documentation Incomplete"
    echo "=========================================="
    echo ""
    for err in "${ERRORS[@]}"; do
      echo "  - $err"
    done
    echo ""
    echo "Fix these issues before committing."
    echo "See docs/glossary/markdown-glossary.md for routing rules."
    echo ""
  } >&2
  exit 2
fi

exit 0
