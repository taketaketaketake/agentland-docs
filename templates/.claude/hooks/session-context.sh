#!/bin/bash
#
# SessionStart hook: loads the glossary routing table into Claude's
# context at the start of every session so it knows which docs to
# update without being told.
#

set -e

INPUT=$(cat)
PROJECT_DIR=$(echo "$INPUT" | jq -r '.cwd')
GLOSSARY="$PROJECT_DIR/docs/glossary/markdown-glossary.md"

if [ ! -f "$GLOSSARY" ]; then
  exit 0
fi

# Extract just the routing summary table — the compact version
# of which docs to update for which change types.
ROUTING=$(sed -n '/^## Documentation Update Protocol/,/^## /p' "$GLOSSARY" | head -n -1)

if [ -n "$ROUTING" ]; then
  cat <<EOF
DOCUMENTATION ROUTING (from docs/glossary/markdown-glossary.md):

$ROUTING

You MUST check this routing table after making source code changes
and update the triggered docs before committing.
EOF
fi

exit 0
