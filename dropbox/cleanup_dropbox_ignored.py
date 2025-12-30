#!/usr/bin/env python3
"""
cleanup_dropbox_ignored.py

Linux:
- Enumerate files via `find <root> -type f -print0`.
- Match rules via trusted PurePosixPath.match + suffix loop (Dropbox-ish semantics).
- Speed-up: sound literal-component prefilter to skip impossible rules.

WARNING:
- Deleting/moving inside Dropbox affects the cloud state.
"""

from __future__ import annotations

import argparse
import json
import logging
import os
import shutil
import stat
import subprocess
import sys
import time
from dataclasses import dataclass
from pathlib import Path, PurePosixPath
from typing import Iterable, Iterator, Optional, Tuple

LOG = logging.getLogger("cleanup_dropbox_ignored")


# -----------------------------
# Logging / tqdm
# -----------------------------


def setup_logging(verbosity: int) -> None:
    level = (
        logging.WARNING
        if verbosity <= 0
        else (logging.INFO if verbosity == 1 else logging.DEBUG)
    )
    h = logging.StreamHandler(stream=sys.stderr)
    h.setFormatter(logging.Formatter("%(levelname)s: %(message)s"))
    LOG.handlers.clear()
    LOG.addHandler(h)
    LOG.setLevel(level)


def maybe_tqdm(enabled: bool, total: Optional[int], desc: str) -> Optional[object]:
    if not enabled:
        return None
    try:
        from tqdm import tqdm  # type: ignore
    except Exception:
        LOG.info(
            "Progress requested but tqdm is not available. Install with: pip install tqdm"
        )
        return None
    return tqdm(total=total, unit="files", dynamic_ncols=True, desc=desc)


# -----------------------------
# Dropbox root detection
# -----------------------------


def detect_dropbox_root() -> Path:
    info = Path.home() / ".dropbox" / "info.json"
    if info.exists():
        try:
            data = json.loads(info.read_text(encoding="utf-8"))
            for key in ("personal", "business"):
                if key in data and isinstance(data[key], dict) and "path" in data[key]:
                    return Path(data[key]["path"]).expanduser()
            for val in data.values():
                if isinstance(val, dict) and "path" in val:
                    return Path(val["path"]).expanduser()
        except Exception as e:
            LOG.debug("Failed reading %s: %s", info, e)

    fallback = Path.home() / "Dropbox"
    if fallback.exists():
        return fallback

    raise FileNotFoundError(
        "Could not determine Dropbox root. Pass --root PATH explicitly."
    )


# -----------------------------
# Rules parsing + trusted matching
# -----------------------------

_GLOB_META = set("*?[]")


def _has_glob_meta(s: str) -> bool:
    return any(c in _GLOB_META for c in s)


def _literal_components(pattern_wo_anchor: str) -> list[str]:
    """
    Extract *literal* path components (no glob metacharacters) from a pattern.
    These components are necessary (if pattern matches, these literals appear as components).
    Safe prefilter: we only use them to skip rules when missing.
    """
    comps: list[str] = []
    for part in pattern_wo_anchor.split("/"):
        if not part or part == "**":
            continue
        if _has_glob_meta(part):
            continue
        comps.append(part.lower())
    return comps


def _contains_component(rel_posix_lower: str, comp_lower: str) -> bool:
    # component boundary check via sentinel slashes
    hay = f"/{rel_posix_lower}/"
    needle = f"/{comp_lower}/"
    return needle in hay


@dataclass(frozen=True)
class Rule:
    negated: bool
    anchored: bool
    pat2: str  # pattern without leading '/'
    has_slash: bool
    required_components: tuple[
        str, ...
    ]  # literal components (lowercase) used for prefilter


def parse_rules(rules_path: Path) -> list[Rule]:
    rules: list[Rule] = []
    for raw in rules_path.read_text(encoding="utf-8").splitlines():
        s = raw.strip()
        if not s or s.startswith("#"):
            continue
        neg = s.startswith("!")
        pat_raw = s[1:].strip() if neg else s
        if not pat_raw:
            continue

        anchored = pat_raw.startswith("/")
        pat2 = pat_raw.lstrip("/") if anchored else pat_raw
        pat2_l = pat2.lower()

        rules.append(
            Rule(
                negated=neg,
                anchored=anchored,
                pat2=pat2_l,
                has_slash=("/" in pat2_l),
                required_components=tuple(_literal_components(pat2_l)),
            )
        )
    return rules


def path_matches_rule(rel_posix_lower: str, rule: Rule) -> bool:
    """
    Trusted semantics:
    - anchored: PurePosixPath(rel).match(pat2)
    - unanchored with no '/': PurePosixPath(rel).match(pat2)
    - unanchored with '/': try all suffixes of rel parts (component boundary suffixes)
    """
    p = PurePosixPath(rel_posix_lower)

    if rule.anchored:
        return p.match(rule.pat2)

    if not rule.has_slash:
        return p.match(rule.pat2)

    parts = p.parts
    for i in range(len(parts)):
        if PurePosixPath(*parts[i:]).match(rule.pat2):
            return True
    return False


def is_ignored(rel_posix: str, rules: Iterable[Rule]) -> bool:
    """
    Last-match-wins with negations, plus a sound literal-component prefilter.
    """
    rel_l = rel_posix.lower()

    ignored = False
    for r in rules:
        # Safe skip: if pattern requires literal components that are absent, it cannot match.
        if r.required_components:
            # All required literals must appear as components somewhere
            if not all(_contains_component(rel_l, c) for c in r.required_components):
                continue

        if path_matches_rule(rel_l, r):
            ignored = not r.negated
    return ignored


# -----------------------------
# find enumeration
# -----------------------------


def _run_find_print0(root: Path) -> subprocess.Popen[bytes]:
    cmd = ["find", str(root.resolve()), "-type", "f", "-print0"]
    return subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=None)


def iter_files_find(root: Path) -> Iterator[str]:
    """
    Yield absolute file paths as strings (decoded), from `find -print0`.
    """
    proc = _run_find_print0(root)
    assert proc.stdout is not None
    buf = b""
    for chunk in iter(lambda: proc.stdout.read(1 << 20), b""):
        buf += chunk
        while True:
            i = buf.find(b"\0")
            if i < 0:
                break
            raw = buf[:i]
            buf = buf[i + 1 :]
            if raw:
                yield raw.decode("utf-8", errors="surrogateescape")
    rc = proc.wait()
    if rc != 0:
        raise RuntimeError(f"find exited with code {rc}")


def count_files_find(root: Path) -> int:
    proc = _run_find_print0(root)
    assert proc.stdout is not None
    total = 0
    for chunk in iter(lambda: proc.stdout.read(1 << 20), b""):
        total += chunk.count(b"\0")
    rc = proc.wait()
    if rc != 0:
        raise RuntimeError(f"find exited with code {rc}")
    return total


# -----------------------------
# Core
# -----------------------------


@dataclass
class Match:
    path: Path
    rel: str
    size: int


def human_bytes(n: int) -> str:
    units = ["B", "KiB", "MiB", "GiB", "TiB", "PiB"]
    x = float(n)
    for u in units:
        if x < 1024 or u == units[-1]:
            return f"{x:.2f} {u}" if u != "B" else f"{int(x)} {u}"
        x /= 1024.0
    return f"{n} B"


def ensure_outside_dropbox(dest: Path, root: Path) -> None:
    dest = dest.resolve()
    root = root.resolve()
    try:
        dest.relative_to(root)
    except ValueError:
        return
    raise ValueError(f"--move-to must be outside Dropbox root ({root}); got {dest}")


def collect_matches(
    root: Path,
    rules_path: Path,
    list_out: Path,
    progress: bool,
    count_first: bool,
    progress_every: int,
) -> Tuple[list[Match], int, int]:
    rules = parse_rules(rules_path)
    LOG.debug("Loaded %d rules from %s", len(rules), rules_path)

    root = root.resolve()
    root_str = str(root)

    total_files: Optional[int] = None
    if progress and count_first:
        LOG.info("Counting files for determinate progress total (extra find pass)...")
        total_files = count_files_find(root)
        LOG.info("Found %d files.", total_files)

    pbar = maybe_tqdm(progress, total_files, desc="match")

    matches: list[Match] = []
    total_size = 0
    scanned = 0

    t0 = time.time()
    for abs_s in iter_files_find(root):
        scanned += 1
        rel = os.path.relpath(abs_s, root_str).replace(os.sep, "/")

        if progress_every and scanned % progress_every == 0:
            LOG.info("Scanned %d files; matches so far: %d", scanned, len(matches))

        if rel.lower() == "rules.dropboxignore":
            if pbar is not None:
                pbar.update(1)
            continue

        if is_ignored(rel, rules):
            p = Path(abs_s)
            try:
                st = p.lstat()
            except FileNotFoundError:
                if pbar is not None:
                    pbar.update(1)
                continue
            if stat.S_ISREG(st.st_mode):
                size = int(st.st_size)
                total_size += size
                matches.append(Match(path=p, rel=rel, size=size))

        if pbar is not None:
            pbar.update(1)

    if pbar is not None:
        pbar.close()

    matches.sort(key=lambda m: m.size, reverse=True)
    list_out.parent.mkdir(parents=True, exist_ok=True)
    list_out.write_text("".join(m.rel + "\n" for m in matches), encoding="utf-8")

    elapsed = max(1e-9, time.time() - t0)
    LOG.info(
        "Scanned %d files in %.1fs (%.0f files/s).", scanned, elapsed, scanned / elapsed
    )

    return matches, total_size, scanned


# -----------------------------
# CLI
# -----------------------------


def build_parser() -> argparse.ArgumentParser:
    p = argparse.ArgumentParser(
        description="Clean Dropbox files matching rules.dropboxignore."
    )
    p.add_argument(
        "--root", type=Path, default=None, help="Dropbox root (default: auto-detect)."
    )
    p.add_argument("--rules", type=Path, default=None, help="rules.dropboxignore path.")
    p.add_argument(
        "--list",
        dest="list_out",
        type=Path,
        default=Path("./dropbox_ignored_paths.txt"),
        help="Write matched relative paths here.",
    )
    action = p.add_mutually_exclusive_group()
    action.add_argument("--dry-run", action="store_true", help="No changes (default).")
    action.add_argument("--delete", action="store_true", help="Delete matched files.")
    action.add_argument(
        "--move-to", type=Path, default=None, help="Move matched files outside Dropbox."
    )
    p.add_argument(
        "--yes", action="store_true", help="Required for --delete/--move-to."
    )
    p.add_argument("--top", type=int, default=25, help="Show N largest matches.")
    p.add_argument("--progress", action="store_true", help="Show progress bar (tqdm).")
    p.add_argument(
        "--count-first",
        action="store_true",
        help="Pre-count files to make progress determinate (extra find pass).",
    )
    p.add_argument(
        "--progress-every",
        type=int,
        default=2000,
        help="Log every N scanned files (0 disables).",
    )
    p.add_argument(
        "-v", "--verbose", action="count", default=1, help="Increase verbosity."
    )
    return p


def main(argv: Optional[list[str]] = None) -> int:
    args = build_parser().parse_args(argv)
    setup_logging(args.verbose)

    try:
        root = args.root.expanduser() if args.root else detect_dropbox_root()
    except FileNotFoundError as e:
        LOG.error("%s", e)
        return 2
    if not root.exists():
        LOG.error("Dropbox root does not exist: %s", root)
        return 2

    rules_path = (
        args.rules.expanduser() if args.rules else (root / "rules.dropboxignore")
    )
    if not rules_path.exists():
        LOG.error("rules.dropboxignore not found at: %s", rules_path)
        return 2

    list_out = args.list_out.expanduser()
    progress_every = args.progress_every if args.progress_every > 0 else 0

    matches, total_size, scanned = collect_matches(
        root=root,
        rules_path=rules_path,
        list_out=list_out,
        progress=args.progress,
        count_first=args.count_first,
        progress_every=progress_every,
    )

    LOG.info("Dropbox root : %s", root)
    LOG.info("Rules file   : %s", rules_path)
    LOG.info("Scanned      : %d files", scanned)
    LOG.info("Matches      : %d files", len(matches))
    LOG.info("Total size   : %s", human_bytes(total_size))
    LOG.info("List written : %s", list_out.resolve())

    LOG.info("Top %d largest matches:", min(args.top, len(matches)))
    for m in matches[: args.top]:
        LOG.info("  %10s  %s", human_bytes(m.size), m.rel)

    do_move = args.move_to is not None
    do_delete = bool(args.delete)
    if not do_move and not do_delete:
        LOG.info("Dry run: no changes made.")
        return 0

    if not args.yes:
        LOG.error("Refusing to modify files without --yes.")
        return 3

    if do_move:
        dest = args.move_to.expanduser()
        ensure_outside_dropbox(dest, root)
        dest.mkdir(parents=True, exist_ok=True)

        moved = 0
        for m in matches:
            if not m.path.exists():
                continue
            target = dest / m.rel
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.move(str(m.path), str(target))
            moved += 1
        LOG.info("Moved %d files to: %s", moved, dest)
        return 0

    if do_delete:
        LOG.warning(
            "Deleting files inside Dropbox will delete them from Dropbox cloud."
        )
        deleted = 0
        for m in matches:
            try:
                m.path.unlink()
                deleted += 1
            except FileNotFoundError:
                continue
        LOG.info("Deleted %d files.", deleted)
        return 0

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
