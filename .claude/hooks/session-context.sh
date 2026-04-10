#!/usr/bin/env bash
# SessionStart hook: injects the glossary routing table into Claude's context
# so it knows which docs to update before doing any work.

set -euo pipefail

# Read JSON from stdin
INPUT=$(cat)
PROJECT_DIR=$(echo "$INPUT" | grep -o '"cwd":"[^"]*"' | head -1 | cut -d'"' -f4)

GLOSSARY="${PROJECT_DIR}/docs/glossary/markdown-glossary.md"

if [ ! -f "$GLOSSARY" ]; then
  exit 0
fi

# Extract the Documentation Update Protocol section
# Find the line number where it starts and where the next ## section begins
START=$(grep -n '^## Documentation Update Protocol' "$GLOSSARY" | head -1 | cut -d: -f1)

if [ -z "$START" ]; then
  exit 0
fi

# Find the next ## heading after START (not ###, just ##)
TOTAL_LINES=$(wc -l < "$GLOSSARY")
END=$TOTAL_LINES

NEXT=$(tail -n +"$((START + 1))" "$GLOSSARY" | grep -n '^## [^#]' | head -1 | cut -d: -f1)
if [ -n "$NEXT" ]; then
  END=$((START + NEXT - 1))
fi

ROUTING=$(sed -n "${START},${END}p" "$GLOSSARY" | sed '/^$/{ N; /^\n$/d; }')

echo "DOCUMENTATION ROUTING (from docs/glossary/markdown-glossary.md):"
echo ""
echo "$ROUTING"
echo ""
echo "You MUST check this routing table after making source code changes and update the triggered docs before committing."

exit 0
