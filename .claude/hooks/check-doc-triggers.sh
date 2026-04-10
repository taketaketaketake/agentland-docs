#!/usr/bin/env python3
"""
PostToolUse hook (Edit/Write): two-directional doc enforcement.

1. Source file edited → parse glossary routing table, warn if triggered docs
   aren't updated.
2. Doc file edited without source changes → warn to verify source alignment.

Supports .doc-ok to suppress false positives (one doc path per line).
Exit 0 always — PostToolUse cannot block.
"""

import sys, os, re, json, subprocess


def main():
    data = json.load(sys.stdin)
    project_dir = data.get("cwd", "")
    file_path = data.get("tool_input", {}).get("file_path", "")

    if not file_path or not project_dir:
        return

    rel_path = os.path.relpath(file_path, project_dir)

    # Load .doc-ok suppressions
    suppressed = load_doc_ok(project_dir)

    if is_doc_file(rel_path):
        # Direction 2: doc edited → remind to verify source alignment
        if not rel_path.startswith("docs/audits/") and not rel_path.startswith("docs/plan/"):
            print(
                f"NOTE: You edited {rel_path}. "
                f"Verify it accurately reflects the current source code."
            )
    elif not is_config_file(rel_path):
        # Direction 1: source file edited → check glossary routing triggers
        triggered = find_triggered_docs(project_dir, rel_path)
        triggered = [d for d in triggered if d not in suppressed]

        if triggered:
            docs_list = "\n".join(f"  - {d}" for d in triggered)
            print(
                f"WARNING: Edit to {rel_path} may require documentation updates.\n\n"
                f"Docs that may need updating (per glossary routing table):\n"
                f"{docs_list}\n\n"
                f"If these don't need changes, add paths to .doc-ok (one per line)."
            )


# ── Routing table parser ─────────────────────────────────────────


def parse_routing_table(glossary_path):
    """Extract the Routing Summary table from markdown-glossary.md.

    Returns {change_type_string: [doc_file_paths]}.
    """
    if not os.path.exists(glossary_path):
        return {}

    with open(glossary_path) as f:
        content = f.read()

    routes = {}
    in_table = False
    for line in content.split("\n"):
        if "Change Type" in line and "Files to Update" in line:
            in_table = True
            continue
        if in_table and line.strip().startswith("|---"):
            continue
        if in_table and line.strip().startswith("|"):
            cols = [c.strip() for c in line.split("|")[1:-1]]
            if len(cols) >= 2:
                change_type = cols[0].strip()
                doc_files = re.findall(r"`([^`]+)`", cols[1])
                if change_type and doc_files:
                    routes[change_type] = doc_files
        elif in_table:
            break

    return routes


# ── Path → change type matching ──────────────────────────────────

# Maps keywords in the glossary change type descriptions to file path
# patterns that plausibly correspond. This is the only heuristic layer —
# the doc file targets come from the glossary itself.
CHANGE_KEYWORDS = {
    "schema": ["schema", "migration", "alembic", "models", "database", "db"],
    "infrastructure": ["infra", "service", "deploy", "docker", "compose"],
    "invariant": ["invariant", "constraint"],
    "stub": ["stub", "noop", "mock", "fake"],
    "artifact": ["artifact"],
    "interface": [
        "interface",
        "protocol",
        "api",
        "server",
        "handler",
        "route",
        "endpoint",
    ],
    "markdown": [".md"],
}


def matches_change_type(path_lower, change_type_lower):
    """Does this file path plausibly relate to this change type?"""
    for category, keywords in CHANGE_KEYWORDS.items():
        if category in change_type_lower:
            if any(kw in path_lower for kw in keywords):
                return True
    return False


def find_triggered_docs(project_dir, rel_path):
    """Parse glossary, match path against routing table, return stale docs."""
    glossary = os.path.join(project_dir, "docs", "glossary", "markdown-glossary.md")
    routes = parse_routing_table(glossary)
    if not routes:
        return []

    path_lower = rel_path.lower()
    matched_docs = set()

    for change_type, doc_files in routes.items():
        if matches_change_type(path_lower, change_type.lower()):
            matched_docs.update(doc_files)

    # Filter to docs that haven't been modified in current git state
    return sorted(
        d for d in matched_docs
        if os.path.exists(os.path.join(project_dir, d))
        and not is_modified_in_git(project_dir, d)
    )


# ── Helpers ──────────────────────────────────────────────────────


def is_doc_file(rel_path):
    return rel_path.startswith("docs/")


def is_config_file(rel_path):
    return (
        rel_path.startswith(".")
        or rel_path.startswith("scripts/")
        or rel_path == "CLAUDE.md"
        or rel_path == "README.md"
        or rel_path.endswith(".json")
        or rel_path.endswith(".yml")
        or rel_path.endswith(".yaml")
        or rel_path.endswith(".toml")
    )


def load_doc_ok(project_dir):
    path = os.path.join(project_dir, ".doc-ok")
    if not os.path.exists(path):
        return set()
    with open(path) as f:
        return {
            line.strip()
            for line in f
            if line.strip() and not line.startswith("#")
        }


def is_modified_in_git(project_dir, doc_path):
    for cmd in [
        ["git", "diff", "--name-only", "HEAD"],
        ["git", "diff", "--cached", "--name-only"],
    ]:
        try:
            result = subprocess.run(
                cmd, cwd=project_dir, capture_output=True, text=True, timeout=5
            )
            if doc_path in result.stdout:
                return True
        except (subprocess.TimeoutExpired, FileNotFoundError):
            pass
    return False


if __name__ == "__main__":
    try:
        main()
    except Exception:
        pass  # Never crash — PostToolUse can't block anyway
    sys.exit(0)
