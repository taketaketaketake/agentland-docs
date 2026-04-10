#!/usr/bin/env python3
"""
PreToolUse hook (Bash → git commit): hard gate on documentation completeness.

BLOCKS the commit (exit 2) if:
  1. A phase is marked COMPLETE without a corresponding audit file
  2. Staged source files contain stub markers without docs/stubs.md entries
  3. Staged interface/protocol files changed without docs/contracts.md update

Source files = anything not under docs/, .claude/, .github/, scripts/, or dotfiles.
This avoids hardcoding src/ so it works with any project layout.

Exit 2 = block.  Exit 0 = allow.
"""

import sys, os, re, json, subprocess, glob


def main():
    data = json.load(sys.stdin)
    project_dir = data.get("cwd", "")
    command = data.get("tool_input", {}).get("command", "")

    if "git commit" not in command:
        sys.exit(0)

    errors = []

    check_phase_audits(project_dir, errors)
    staged_src = get_staged_source_files(project_dir)
    check_stub_registry(project_dir, staged_src, errors)
    check_interface_docs(project_dir, staged_src, errors)

    if errors:
        msg = "\n".join(f"  - {e}" for e in errors)
        print(
            f"\n{'=' * 42}\n"
            f"  COMMIT BLOCKED: Documentation Incomplete\n"
            f"{'=' * 42}\n\n"
            f"{msg}\n\n"
            f"Fix these issues before committing.\n"
            f"See docs/glossary/markdown-glossary.md for routing rules.\n",
            file=sys.stderr,
        )
        sys.exit(2)


# ── Check 1: Phase completion without audit ──────────────────────


def check_phase_audits(project_dir, errors):
    """Every COMPLETE phase must have a docs/audits/phase-NN-audit.md."""
    plan_dir = os.path.join(project_dir, "docs", "plan")
    if not os.path.isdir(plan_dir):
        return

    for plan_file in glob.glob(os.path.join(plan_dir, "*.md")):
        with open(plan_file) as f:
            content = f.read()

        # Match "### Status: COMPLETE" or "#### Status: COMPLETE"
        # to avoid false positives from prose like "Phase Completion Rules"
        for match in re.finditer(
            r"##\s+PHASE\s+(\d+)\b.*?###\s*Status:\s*COMPLETE",
            content,
            re.DOTALL | re.IGNORECASE,
        ):
            phase_num = match.group(1)
            audit_file = os.path.join(
                project_dir, "docs", "audits", f"phase-{phase_num}-audit.md"
            )
            if not os.path.exists(audit_file):
                errors.append(
                    f"Phase {phase_num} is marked COMPLETE in {os.path.basename(plan_file)} "
                    f"but docs/audits/phase-{phase_num}-audit.md does not exist."
                )


# ── Check 2: Stub registry completeness ─────────────────────────

STUB_PATTERNS = re.compile(
    r"#\s*-{3,}\s*STUB|#\s*STUB:|STUB\s*=\s*True|"
    r"raise\s+NotImplementedError|"
    r"pass\s*#\s*stub|"
    r"asyncio\.sleep.*#.*stub",
    re.IGNORECASE,
)


def check_stub_registry(project_dir, staged_src, errors):
    """Staged source files with stub markers must be in docs/stubs.md."""
    stubs_file = os.path.join(project_dir, "docs", "stubs.md")
    if not staged_src or not os.path.exists(stubs_file):
        return

    with open(stubs_file) as f:
        stubs_content = f.read()

    for src_file in staged_src:
        try:
            result = subprocess.run(
                ["git", "show", f":{src_file}"],
                cwd=project_dir,
                capture_output=True,
                text=True,
                timeout=5,
            )
            if STUB_PATTERNS.search(result.stdout):
                if src_file not in stubs_content:
                    errors.append(
                        f"{src_file} contains stub markers but is not "
                        f"registered in docs/stubs.md"
                    )
        except (subprocess.TimeoutExpired, FileNotFoundError):
            pass


# ── Check 3: Interface doc staleness ─────────────────────────────

INTERFACE_PATTERNS = re.compile(
    r"interface|protocol|handler|route|endpoint|server|api",
    re.IGNORECASE,
)


def check_interface_docs(project_dir, staged_src, errors):
    """If interface-related source files changed, contracts.md must be staged."""
    if not staged_src:
        return

    contracts = os.path.join(project_dir, "docs", "contracts.md")
    if not os.path.exists(contracts):
        return

    # Check if contracts.md is already staged
    try:
        result = subprocess.run(
            ["git", "diff", "--cached", "--name-only"],
            cwd=project_dir,
            capture_output=True,
            text=True,
            timeout=5,
        )
        if "docs/contracts.md" in result.stdout:
            return  # Already staged, OK
    except (subprocess.TimeoutExpired, FileNotFoundError):
        return

    interface_files = [f for f in staged_src if INTERFACE_PATTERNS.search(f)]
    if interface_files:
        files_str = ", ".join(interface_files[:3])
        if len(interface_files) > 3:
            files_str += f" (+{len(interface_files) - 3} more)"
        errors.append(
            f"Interface-related source files changed ({files_str}) "
            f"but docs/contracts.md was not updated."
        )


# ── Helpers ──────────────────────────────────────────────────────

# Directories that are NOT source code
NON_SOURCE = {"docs", ".claude", ".github", ".git", "scripts", "node_modules"}


def get_staged_source_files(project_dir):
    """Return staged files that are source code (not docs/config/dotfiles)."""
    try:
        result = subprocess.run(
            ["git", "diff", "--cached", "--name-only", "--diff-filter=d"],
            cwd=project_dir,
            capture_output=True,
            text=True,
            timeout=5,
        )
    except (subprocess.TimeoutExpired, FileNotFoundError):
        return []

    source_files = []
    for f in result.stdout.strip().split("\n"):
        if not f:
            continue
        top_dir = f.split("/")[0] if "/" in f else ""
        if top_dir in NON_SOURCE:
            continue
        if f.startswith("."):
            continue
        source_files.append(f)

    return source_files


if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        # On unexpected errors, allow the commit but warn
        print(f"doc-check hook error: {e}", file=sys.stderr)
    sys.exit(0)
