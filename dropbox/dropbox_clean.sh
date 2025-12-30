#!/usr/bin/env bash
set -euo pipefail

# cleanup_dropbox_ignored.sh
#
# Finds files that match rules.dropboxignore and optionally deletes them.
# IMPORTANT:
# - Deleting files inside Dropbox will delete them from Dropbox cloud as well.
# - Use dry-run first.

usage() {
  cat <<'EOF'
Usage:
  cleanup_dropbox_ignored.sh [--root PATH] [--rules PATH] [--list PATH]
                             [--dry-run | --delete] [--yes]
                             [--move-to PATH]

Options:
  --root PATH     Dropbox root folder. If omitted, tries ~/.dropbox/info.json then ~/Dropbox.
  --rules PATH    Path to rules.dropboxignore (default: <root>/rules.dropboxignore).
  --list PATH     Write matched paths to this file (default: ./dropbox_ignored_paths.txt).
  --dry-run       Do not modify anything (default).
  --delete        Permanently delete matched files.
  --move-to PATH  Move matched files to PATH (outside Dropbox) instead of deleting.
  --yes           Required with --delete or --move-to (safety latch).

Examples:
  cleanup_dropbox_ignored.sh --dry-run
  cleanup_dropbox_ignored.sh --delete --yes
  cleanup_dropbox_ignored.sh --move-to "$HOME/.cache/dropbox_ignored_backup/$(date +%F)" --yes
EOF
}

ROOT=""
RULES=""
LIST_OUT="./dropbox_ignored_paths.txt"
MODE="dry"
YES="no"
MOVE_TO=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --root) ROOT="$2"; shift 2;;
    --rules) RULES="$2"; shift 2;;
    --list) LIST_OUT="$2"; shift 2;;
    --dry-run) MODE="dry"; shift 1;;
    --delete) MODE="delete"; shift 1;;
    --move-to) MODE="move"; MOVE_TO="$2"; shift 2;;
    --yes) YES="yes"; shift 1;;
    -h|--help) usage; exit 0;;
    *) echo "Unknown argument: $1" >&2; usage; exit 2;;
  esac
done

python3 - <<'PY'
import argparse
import json
import os
import shutil
import sys
from pathlib import Path, PurePosixPath

def detect_dropbox_root() -> Path | None:
    info = Path.home() / ".dropbox" / "info.json"
    if info.exists():
        try:
            data = json.loads(info.read_text(encoding="utf-8"))
            # Prefer personal, otherwise pick first available section
            for key in ("personal", "business"):
                if key in data and "path" in data[key]:
                    return Path(data[key]["path"]).expanduser()
            for key, val in data.items():
                if isinstance(val, dict) and "path" in val:
                    return Path(val["path"]).expanduser()
        except Exception:
            pass
    # Fallback
    fallback = Path.home() / "Dropbox"
    return fallback if fallback.exists() else None

def parse_rules(rules_path: Path):
    rules = []
    for raw in rules_path.read_text(encoding="utf-8").splitlines():
        s = raw.strip()
        if not s or s.startswith("#"):
            continue
        neg = s.startswith("!")
        pat = s[1:].strip() if neg else s
        rules.append((neg, pat))
    return rules

def path_matches_pattern(rel_posix: str, pattern: str) -> bool:
    # Dropbox rules are case-insensitive
    rel = rel_posix.lower()
    pat = pattern.lower()

    anchored = pat.startswith("/")
    pat2 = pat.lstrip("/") if anchored else pat

    p = PurePosixPath(rel)
    pat_has_slash = "/" in pat2

    # For unanchored patterns containing '/', approximate "match anywhere" by
    # trying all suffixes of the path.
    if anchored:
        return p.match(pat2)
    if not pat_has_slash:
        # Component-only pattern: PurePath.match already behaves like "match name anywhere"
        return p.match(pat2)
    parts = p.parts
    for i in range(len(parts)):
        if PurePosixPath(*parts[i:]).match(pat2):
            return True
    return False

def is_ignored(rel_posix: str, rules):
    ignored = False
    for neg, pat in rules:
        if path_matches_pattern(rel_posix, pat):
            ignored = not neg
    return ignored

def iter_all_paths(root: Path):
    # Yield relative POSIX paths for files + dirs; deletion will only touch files by default.
    for p in root.rglob("*"):
        try:
            rel = p.relative_to(root).as_posix()
        except Exception:
            continue
        yield p, rel

def human(n: int) -> str:
    # simple IEC
    units = ["B","KiB","MiB","GiB","TiB","PiB"]
    x = float(n)
    for u in units:
        if x < 1024 or u == units[-1]:
            return f"{x:.2f} {u}" if u != "B" else f"{int(x)} {u}"
        x /= 1024.0
    return f"{n} B"

# Read CLI args passed from bash via env
ROOT = os.environ.get("DB_ROOT", "")
RULES = os.environ.get("DB_RULES", "")
LIST_OUT = os.environ.get("DB_LIST_OUT", "./dropbox_ignored_paths.txt")
MODE = os.environ.get("DB_MODE", "dry")
YES = os.environ.get("DB_YES", "no")
MOVE_TO = os.environ.get("DB_MOVE_TO", "")

root = Path(ROOT).expanduser() if ROOT else detect_dropbox_root()
if root is None or not root.exists():
    print("ERROR: Could not determine Dropbox root. Pass --root PATH.", file=sys.stderr)
    sys.exit(2)

rules_path = Path(RULES).expanduser() if RULES else (root / "rules.dropboxignore")
if not rules_path.exists():
    print(f"ERROR: rules.dropboxignore not found at: {rules_path}", file=sys.stderr)
    sys.exit(2)

rules = parse_rules(rules_path)

matched_files = []
total_bytes = 0

for p, rel in iter_all_paths(root):
    # Skip the ignore file itself
    if rel.lower() == "rules.dropboxignore":
        continue
    if is_ignored(rel, rules) and p.is_file():
        try:
            st = p.lstat()
            total_bytes += st.st_size
        except FileNotFoundError:
            continue
        matched_files.append((p, rel))

matched_files.sort(key=lambda x: x[0].stat().st_size if x[0].exists() else 0, reverse=True)

out_path = Path(LIST_OUT).expanduser()
out_path.write_text("\n".join(rel for _, rel in matched_files) + ("\n" if matched_files else ""),
                    encoding="utf-8")

print(f"Dropbox root : {root}")
print(f"Rules file   : {rules_path}")
print(f"Matches      : {len(matched_files)} files")
print(f"Total size   : {human(total_bytes)}")
print(f"List written : {out_path.resolve()}")

# Show a small "largest files" preview
print("\nTop 25 largest matches:")
for p, rel in matched_files[:25]:
    try:
        sz = p.lstat().st_size
    except FileNotFoundError:
        continue
    print(f"  {human(sz):>10}  {rel}")

if MODE == "dry":
    print("\nDry run: no changes made.")
    sys.exit(0)

if YES != "yes":
    print("\nERROR: Refusing to modify files without --yes.", file=sys.stderr)
    sys.exit(3)

if MODE == "move":
    if not MOVE_TO:
        print("ERROR: --move-to PATH required in move mode.", file=sys.stderr)
        sys.exit(2)
    dest = Path(MOVE_TO).expanduser()
    dest.mkdir(parents=True, exist_ok=True)

    for p, rel in matched_files:
        if not p.exists():
            continue
        target = dest / rel
        target.parent.mkdir(parents=True, exist_ok=True)
        # move preserves content; avoids permanent loss
        shutil.move(str(p), str(target))

    print(f"\nMoved {len(matched_files)} files to: {dest}")
    sys.exit(0)

if MODE == "delete":
    deleted = 0
    for p, _ in matched_files:
        try:
            p.unlink()
            deleted += 1
        except FileNotFoundError:
            pass
    print(f"\nDeleted {deleted} files.")
    sys.exit(0)

print(f"ERROR: Unknown mode: {MODE}", file=sys.stderr)
sys.exit(2)
PY
