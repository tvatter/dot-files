#!/usr/bin/env python3
"""
cleanup_dropbox_ignored.py

Linux:
- Enumerate files via `find <root> -type f -print0`.
- Fast ignore evaluation for simplified Dropbox rules: structural predicates.
- Fallback to trusted PurePosixPath.match + suffix loop for unclassified patterns.

WARNING:
- Deleting/moving inside Dropbox affects the cloud state.

"""

from __future__ import annotations

import argparse
import json
import logging
import os
import shutil
import subprocess
import sys
import time
from dataclasses import dataclass
from pathlib import Path, PurePosixPath
from typing import Iterator, Optional, Tuple

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
# Rule compilation: fast predicates + fallback
# -----------------------------

_GLOB_META = set("*?[]")


def _has_glob_meta(s: str) -> bool:
    return any(c in _GLOB_META for c in s)


@dataclass(frozen=True)
class FallbackRule:
    negated: bool
    anchored: bool
    pat2: str  # lower, without leading '/'


@dataclass
class CompiledRules:
    # If True, we can short-circuit on first match (no negations, no anchored rules).
    any_match_semantics: bool

    # Basename tests (lowercase)
    basename_exact: set[str]
    basename_prefix: tuple[str, ...]
    basename_suffix: tuple[str, ...]
    # special basename shapes
    basename_endswith_tilde: bool
    basename_hash_wrapped: bool  # #*#
    basename_prefix_dot_underscore: bool  # ._*
    basename_prefix_dot_hash: bool  # .#*

    # Directory/component tests (lowercase), applied to directory components only
    dir_exact: set[str]
    dir_prefix: tuple[str, ...]
    dir_suffix: tuple[str, ...]  # e.g. ".egg-info"

    # Fallback (trusted matcher) rules, in original order
    fallback: list[FallbackRule]

    # For full semantics (negations/anchored), keep all rules in order (fast+fallback)
    # as normalized raw patterns; used only if any_match_semantics=False.
    ordered_raw: list[Tuple[bool, bool, str]]  # (negated, anchored, pat2_lower)


def compile_rules(rules_path: Path) -> CompiledRules:
    basename_exact: set[str] = set()
    basename_prefix: list[str] = []
    basename_suffix: list[str] = []

    dir_exact: set[str] = set()
    dir_prefix: list[str] = []
    dir_suffix: list[str] = []

    fallback: list[FallbackRule] = []
    ordered_raw: list[Tuple[bool, bool, str]] = []

    has_negation = False
    has_anchored = False

    # These specials are triggered by presence of matching patterns.
    enable_tilde = False
    enable_hashwrap = False
    enable_dot_underscore = False
    enable_dot_hash = False

    for raw in rules_path.read_text(encoding="utf-8").splitlines():
        s = raw.strip()
        if not s or s.startswith("#"):
            continue

        neg = s.startswith("!")
        if neg:
            has_negation = True
            s = s[1:].strip()
        if not s:
            continue

        anchored = s.startswith("/")
        if anchored:
            has_anchored = True
            s = s.lstrip("/")

        pat = s.lower()
        ordered_raw.append((neg, anchored, pat))

        # We primarily support patterns of these forms:
        # - **/<name>              (basename match)
        # - **/<name>/**           (directory/component match)
        # where <name> may include a single trailing '*' (prefix), or a leading '*.' (suffix),
        # or be '*.egg-info' (component suffix), or simple specials (#*#, ._*, .#*, *~),
        # or '.coverage.*' (prefix).
        if pat.startswith("**/"):
            tail = pat[3:]

            # Directory-tree pattern?
            if tail.endswith("/**"):
                name = tail[:-3]  # strip '/**'
                # If it contains '/', treat as exact directory path component sequence?
                # In your simplified rules, these are single-component names (possibly with spaces).
                if "/" in name:
                    # Too risky to "optimize" multi-component directory patterns; fallback.
                    fallback.append(
                        FallbackRule(negated=neg, anchored=anchored, pat2=pat)
                    )
                    continue

                if name == "**":
                    # meaningless
                    continue

                # Component patterns
                if not _has_glob_meta(name):
                    dir_exact.add(name)
                    continue

                # prefix: foo*
                if name.endswith("*") and not _has_glob_meta(name[:-1]):
                    dir_prefix.append(name[:-1])
                    continue

                # suffix: *.egg-info
                if name.startswith("*.") and not _has_glob_meta(name[1:]):
                    dir_suffix.append(name[1:])  # ".egg-info"
                    continue

                # otherwise fallback
                fallback.append(FallbackRule(negated=neg, anchored=anchored, pat2=pat))
                continue

            # Basename-ish pattern (file name in any directory)
            name = tail
            if "/" in name:
                # unexpected here; fallback
                fallback.append(FallbackRule(negated=neg, anchored=anchored, pat2=pat))
                continue

            # Specials
            if name == "*~":
                enable_tilde = True
                continue
            if name == "#*#":
                enable_hashwrap = True
                continue
            if name == "._*":
                enable_dot_underscore = True
                continue
            if name == ".#*":
                enable_dot_hash = True
                continue

            # Prefix .coverage.* => prefix ".coverage."
            if name.endswith(".*") and not _has_glob_meta(name[:-2]):
                basename_prefix.append(
                    name[:-1]
                )  # keep trailing '.' (e.g. ".coverage.")
                continue

            # Simple exact
            if not _has_glob_meta(name):
                basename_exact.add(name)
                continue

            # Suffix *.ext or *.synctex.gz or *.so.pyd
            if name.startswith("*.") and not _has_glob_meta(name[1:]):
                basename_suffix.append(name[1:])  # ".ext" (including multi-dot)
                continue

            # Prefix foo* (rare for basenames in your set, but keep)
            if name.endswith("*") and not _has_glob_meta(name[:-1]):
                basename_prefix.append(name[:-1])
                continue

            # Otherwise fallback
            fallback.append(FallbackRule(negated=neg, anchored=anchored, pat2=pat))
            continue

        # Anything else: fallback
        fallback.append(FallbackRule(negated=neg, anchored=anchored, pat2=pat))

    # Dedup + normalize for faster loops
    basename_prefix_t = tuple(sorted(set(basename_prefix), key=len, reverse=True))
    basename_suffix_t = tuple(sorted(set(basename_suffix), key=len, reverse=True))
    dir_prefix_t = tuple(sorted(set(dir_prefix), key=len, reverse=True))
    dir_suffix_t = tuple(sorted(set(dir_suffix), key=len, reverse=True))

    any_match_semantics = (not has_negation) and (not has_anchored)

    return CompiledRules(
        any_match_semantics=any_match_semantics,
        basename_exact=basename_exact,
        basename_prefix=basename_prefix_t,
        basename_suffix=basename_suffix_t,
        basename_endswith_tilde=enable_tilde,
        basename_hash_wrapped=enable_hashwrap,
        basename_prefix_dot_underscore=enable_dot_underscore,
        basename_prefix_dot_hash=enable_dot_hash,
        dir_exact=dir_exact,
        dir_prefix=dir_prefix_t,
        dir_suffix=dir_suffix_t,
        fallback=fallback,
        ordered_raw=ordered_raw,
    )


def _trusted_match(
    rel_posix_lower: str, negated: bool, anchored: bool, pat2: str
) -> bool:
    """
    Trusted semantics (your original):
    - anchored: PurePosixPath(rel).match(pat2)
    - unanchored with no '/': PurePosixPath(rel).match(pat2)
    - unanchored with '/': try all suffixes (component boundary)
    """
    p = PurePosixPath(rel_posix_lower)
    if anchored:
        return p.match(pat2)
    if "/" not in pat2:
        return p.match(pat2)
    parts = p.parts
    for i in range(len(parts)):
        if PurePosixPath(*parts[i:]).match(pat2):
            return True
    return False


def _fast_match(rel_posix_lower: str, cr: CompiledRules) -> bool:
    """
    Fast "any rule matches" evaluation (valid only when cr.any_match_semantics=True).
    """
    # Basename
    # (rel is already lower, and uses '/')
    basename = rel_posix_lower.rsplit("/", 1)[-1]

    if basename in cr.basename_exact:
        return True

    if cr.basename_prefix_dot_underscore and basename.startswith("._"):
        return True
    if cr.basename_prefix_dot_hash and basename.startswith(".#"):
        return True
    if cr.basename_endswith_tilde and basename.endswith("~"):
        return True
    if (
        cr.basename_hash_wrapped
        and basename.startswith("#")
        and basename.endswith("#")
        and len(basename) >= 2
    ):
        return True

    for pre in cr.basename_prefix:
        if basename.startswith(pre):
            return True
    for suf in cr.basename_suffix:
        if basename.endswith(suf):
            return True

    # Directory components (exclude basename)
    if (cr.dir_exact or cr.dir_prefix or cr.dir_suffix) and "/" in rel_posix_lower:
        parts = rel_posix_lower.split("/")
        dir_parts = parts[:-1]
        if cr.dir_exact:
            for part in dir_parts:
                if part in cr.dir_exact:
                    return True
        if cr.dir_prefix:
            for part in dir_parts:
                for pre in cr.dir_prefix:
                    if part.startswith(pre):
                        return True
        if cr.dir_suffix:
            for part in dir_parts:
                for suf in cr.dir_suffix:
                    if part.endswith(suf):
                        return True

    # Fallback rules (rare)
    for r in cr.fallback:
        if _trusted_match(rel_posix_lower, r.negated, r.anchored, r.pat2):
            return True

    return False


def is_ignored(rel_posix: str, cr: CompiledRules) -> bool:
    """
    If no negations/anchored rules exist: short-circuit on first match (fast).
    Otherwise: preserve last-match-wins semantics using trusted matcher for all rules
    (still benefits from fast-path checks before fallback).
    """
    rel_l = rel_posix.lower()

    if cr.any_match_semantics:
        return _fast_match(rel_l, cr)

    # Full semantics: last-match-wins.
    ignored = False
    # We can still evaluate fast predicates to detect matches cheaply, but we must
    # do it in order and allow later rules to override, so we cannot short-circuit.
    basename = rel_l.rsplit("/", 1)[-1]
    parts = rel_l.split("/") if "/" in rel_l else [rel_l]
    dir_parts = parts[:-1]

    for neg, anchored, pat2 in cr.ordered_raw:
        matched = False

        # Attempt fast classification again based on the textual pattern form.
        # If we cannot classify the pattern safely, fall back to trusted matcher.
        # NOTE: This path is mainly for completeness; in your simplified rules
        # any_match_semantics should be True.
        if not anchored and pat2.startswith("**/"):
            tail = pat2[3:]
            if tail.endswith("/**") and "/" not in tail[:-3]:
                name = tail[:-3]
                if not _has_glob_meta(name):
                    matched = name in dir_parts
                elif name.endswith("*") and not _has_glob_meta(name[:-1]):
                    pre = name[:-1]
                    matched = any(p.startswith(pre) for p in dir_parts)
                elif name.startswith("*.") and not _has_glob_meta(name[1:]):
                    suf = name[1:]
                    matched = any(p.endswith(suf) for p in dir_parts)
                else:
                    matched = _trusted_match(rel_l, neg, anchored, pat2)
            elif "/" not in tail:
                name = tail
                if name == "*~":
                    matched = basename.endswith("~")
                elif name == "#*#":
                    matched = (
                        basename.startswith("#")
                        and basename.endswith("#")
                        and len(basename) >= 2
                    )
                elif name == "._*":
                    matched = basename.startswith("._")
                elif name == ".#*":
                    matched = basename.startswith(".#")
                elif name.endswith(".*") and not _has_glob_meta(name[:-2]):
                    matched = basename.startswith(name[:-1])
                elif not _has_glob_meta(name):
                    matched = basename == name
                elif name.startswith("*.") and not _has_glob_meta(name[1:]):
                    matched = basename.endswith(name[1:])
                elif name.endswith("*") and not _has_glob_meta(name[:-1]):
                    matched = basename.startswith(name[:-1])
                else:
                    matched = _trusted_match(rel_l, neg, anchored, pat2)
            else:
                matched = _trusted_match(rel_l, neg, anchored, pat2)
        else:
            matched = _trusted_match(rel_l, neg, anchored, pat2)

        if matched:
            ignored = not neg

    return ignored


# -----------------------------
# find enumeration
# -----------------------------


def _run_find_print0(root: Path) -> subprocess.Popen[bytes]:
    cmd = ["find", str(root.resolve()), "-type", "f", "-print0"]
    return subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=None)


def iter_files_find(root: Path) -> Iterator[str]:
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
    cr = compile_rules(rules_path)

    if cr.any_match_semantics:
        LOG.debug(
            "Compiled rules from %s: any-match semantics enabled "
            "(no negations, no anchored rules).",
            rules_path,
        )
    else:
        LOG.debug(
            "Compiled rules from %s: full semantics (negations/anchored present).",
            rules_path,
        )

    LOG.debug(
        "Fast buckets: basename_exact=%d, basename_prefix=%d, basename_suffix=%d, "
        "dir_exact=%d, dir_prefix=%d, dir_suffix=%d, fallback=%d",
        len(cr.basename_exact),
        len(cr.basename_prefix),
        len(cr.basename_suffix),
        len(cr.dir_exact),
        len(cr.dir_prefix),
        len(cr.dir_suffix),
        len(cr.fallback),
    )

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

        if is_ignored(rel, cr):
            p = Path(abs_s)
            try:
                st = p.lstat()
            except FileNotFoundError:
                if pbar is not None:
                    pbar.update(1)
                continue
            if os.stat.S_ISREG(st.st_mode):
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
        "Scanned %d files in %.1fs (%.0f files/s).",
        scanned,
        elapsed,
        scanned / elapsed,
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
        default=20000,
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
