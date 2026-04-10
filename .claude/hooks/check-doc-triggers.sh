#!/bin/bash
#
# PostToolUse hook: fires after Edit/Write on source files.
# Checks the glossary routing table and warns Claude if triggered docs
# weren't modified in this session.
#
# Exit 0 always (PostToolUse can't block). Warnings go to stdout
# as additionalContext so Claude sees them and can self-correct.
#

set -e

INPUT=$(cat)
PROJECT_DIR=$(echo "$INPUT" | jq -r '.cwd')
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Only care about source file edits
if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# Normalize to relative path
REL_PATH="${FILE_PATH#$PROJECT_DIR/}"

# ─── Routing table ───────────────────────────────────────────────
# Maps source path patterns to docs that SHOULD be updated.
# Derived from docs/glossary/markdown-glossary.md routing summary.
# Add project-specific routes below.
# ─────────────────────────────────────────────────────────────────

declare -A ROUTES

# Source code changes
ROUTES["src/"]="docs/architecture.md docs/contracts.md"

# Schema / model changes
ROUTES["models"]="docs/models.md"
ROUTES["schema"]="docs/models.md"
ROUTES["migration"]="docs/models.md"

# Stub patterns
ROUTES["stub"]="docs/stubs.md"
ROUTES["noop"]="docs/stubs.md"
ROUTES["STUB"]="docs/stubs.md"

# Interface / protocol changes
ROUTES["interface"]="docs/contracts.md"
ROUTES["protocol"]="docs/contracts.md"

# Plan changes
ROUTES["docs/plan/"]="docs/plan/plan-template.md"

# New markdown files
ROUTES[".md"]="docs/glossary/markdown-glossary.md"

# ─── Check which routes match ────────────────────────────────────

TRIGGERED_DOCS=()
SEEN=()

for pattern in "${!ROUTES[@]}"; do
  if [[ "$REL_PATH" == *"$pattern"* ]]; then
    for doc in ${ROUTES[$pattern]}; do
      # Deduplicate
      if [[ ! " ${SEEN[*]} " =~ " ${doc} " ]]; then
        SEEN+=("$doc")
        # Check if the doc was modified in this git session
        if [ -f "$PROJECT_DIR/$doc" ]; then
          if ! git -C "$PROJECT_DIR" diff --name-only HEAD 2>/dev/null | grep -q "$doc"; then
            if ! git -C "$PROJECT_DIR" diff --cached --name-only 2>/dev/null | grep -q "$doc"; then
              TRIGGERED_DOCS+=("$doc")
            fi
          fi
        fi
      fi
    done
  fi
done

# ─── Output warning if docs need attention ───────────────────────

if [ ${#TRIGGERED_DOCS[@]} -gt 0 ]; then
  DOCS_LIST=$(printf "  - %s\n" "${TRIGGERED_DOCS[@]}")
  cat <<EOF
WARNING: The edit to $REL_PATH may require documentation updates.

The following docs may need to be updated based on the glossary routing table:
$DOCS_LIST

Check docs/glossary/markdown-glossary.md for the full routing rules.
EOF
fi

exit 0
