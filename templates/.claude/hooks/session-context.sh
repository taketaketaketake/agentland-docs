#!/usr/bin/env python3
"""
SessionStart hook: injects the glossary routing table into Claude's context
so it knows which docs to update before doing any work.
"""

import sys, os, json, re


def main():
    data = json.load(sys.stdin)
    project_dir = data.get("cwd", "")
    glossary = os.path.join(project_dir, "docs", "glossary", "markdown-glossary.md")

    if not os.path.exists(glossary):
        return

    with open(glossary) as f:
        content = f.read()

    # Extract the Documentation Update Protocol section
    match = re.search(
        r"(## Documentation Update Protocol.*?)(?=\n## [^#]|\Z)",
        content,
        re.DOTALL,
    )
    if not match:
        return

    routing = match.group(1).strip()
    print(
        f"DOCUMENTATION ROUTING (from docs/glossary/markdown-glossary.md):\n\n"
        f"{routing}\n\n"
        f"You MUST check this routing table after making source code changes "
        f"and update the triggered docs before committing."
    )


if __name__ == "__main__":
    try:
        main()
    except Exception:
        pass
    sys.exit(0)
