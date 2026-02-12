import argparse
import logging
import os
import subprocess
from pathlib import Path

from tqdm import tqdm

DEFAULT_ROOT = Path.home() / "Dropbox"
DEFAULT_OUT_IGNORED = Path.home() / "dropbox_currently_ignored.txt"
DEFAULT_OUT_UNWATCHED = Path.home() / "dropbox_currently_unwatched.txt"

# directories to skip to avoid noise / weird statuses
DEFAULT_SKIP_DIR_PREFIXES = (".dropbox", ".dropbox.cache")


def setup_logging(verbosity: int) -> logging.Logger:
    level = logging.WARNING
    if verbosity == 1:
        level = logging.INFO
    elif verbosity >= 2:
        level = logging.DEBUG
    logging.basicConfig(level=level, format="%(levelname)s: %(message)s")
    return logging.getLogger("dropbox-status")


def run_filestatus(dirpath: Path) -> list[tuple[str, str]]:
    # returns list of (name, status) for entries in dirpath
    try:
        proc = subprocess.run(
            ["dropbox", "filestatus"],
            cwd=dirpath,
            stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL,
            text=True,
            check=False,
        )
    except FileNotFoundError:
        raise SystemExit("dropbox CLI not found in PATH")
    lines = proc.stdout.splitlines()
    out = []
    for line in lines:
        if ":" not in line:
            continue
        name, status = line.split(":", 1)
        name = name.strip()
        status = status.strip()
        if not name:
            continue
        out.append((name, status))
    return out


def list_directories(root: Path, skip_prefixes: set[str]) -> list[Path]:
    proc = subprocess.run(
        ["find", str(root), "-type", "d"],
        stdout=subprocess.PIPE,
        stderr=subprocess.DEVNULL,
        text=True,
        check=False,
    )
    if proc.returncode != 0:
        raise SystemExit("find failed to list directories")

    directories = []
    for dirpath in proc.stdout.splitlines():
        drel = Path(dirpath).relative_to(root)
        if drel.parts and drel.parts[0] in skip_prefixes:
            continue
        directories.append(Path(dirpath))
    return directories


def collect_statuses(
    root: Path, skip_prefixes: set[str], show_progress: bool
) -> tuple[list[str], list[str]]:
    directories = list_directories(root, skip_prefixes)
    ignored = []
    unwatched = []

    iterator = directories
    if show_progress:
        iterator = tqdm(directories, desc="Processing Dropbox directories")

    for dirpath in iterator:
        drel = dirpath.relative_to(root)
        entries = run_filestatus(dirpath)
        for name, status in entries:
            if status == "ignored":
                rel = drel / name
                ignored.append(rel.as_posix())
            elif status == "unwatched":
                rel = drel / name
                unwatched.append(rel.as_posix())

    ignored_set = set(ignored)
    unwatched_set = set(unwatched)
    ignored_set.discard("rules.dropboxignore")
    for prefix in skip_prefixes:
        ignored_set.discard(prefix)
        unwatched_set.discard(prefix)

    return sorted(ignored_set), sorted(unwatched_set)


def write_paths(paths: list[str], out_path: Path) -> None:
    out_path.write_text("\n".join(paths) + ("\n" if paths else ""), encoding="utf-8")


def read_paths(path_file: Path) -> list[str]:
    return [
        p.strip()
        for p in path_file.read_text(encoding="utf-8").splitlines()
        if p.strip()
    ]


def rename_paths(
    root: Path,
    rel_paths: list[str],
    suffix: str,
    dry_run: bool,
    logger: logging.Logger,
) -> None:
    rel_paths.sort(key=lambda s: s.count("/"), reverse=True)

    for rel in rel_paths:
        rel_path = Path(rel)
        if rel_path.is_absolute():
            logger.warning("Skipping absolute path: %s", rel)
            continue
        if ".." in rel_path.parts:
            logger.warning("Skipping path with parent traversal: %s", rel)
            continue

        p = root / rel_path
        if not p.exists():
            logger.debug("Missing path: %s", p)
            continue
        tmp = p.with_name(p.name + suffix)
        if tmp.exists():
            logger.warning("Temporary path already exists, skipping: %s", tmp)
            continue

        logger.info("Renaming %s", p)
        if dry_run:
            continue
        os.rename(p, tmp)
        os.rename(tmp, p)


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="List Dropbox ignored/unwatched paths or trigger resync via rename."
    )
    parser.add_argument("-r", "--root", type=Path, default=DEFAULT_ROOT)
    parser.add_argument(
        "-s",
        "--skip-prefix",
        action="append",
        default=list(DEFAULT_SKIP_DIR_PREFIXES),
        help="Top-level directory prefix to skip (repeatable)",
    )
    parser.add_argument("-v", "--verbose", action="count", default=0)
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Only applies to rename subcommand",
    )

    subparsers = parser.add_subparsers(dest="command", required=True)

    list_parser = subparsers.add_parser("list", help="List ignored/unwatched paths")
    list_parser.add_argument("--out-ignored", type=Path, default=DEFAULT_OUT_IGNORED)
    list_parser.add_argument(
        "--out-unwatched", type=Path, default=DEFAULT_OUT_UNWATCHED
    )
    list_parser.add_argument(
        "--no-progress", action="store_true", help="Disable tqdm progress bar"
    )

    rename_parser = subparsers.add_parser(
        "rename", help="Rename ignored paths to trigger resync"
    )
    rename_parser.add_argument("--paths-file", type=Path, default=DEFAULT_OUT_IGNORED)
    rename_parser.add_argument("--suffix", default=".__dbx_readd__")

    return parser


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()
    logger = setup_logging(args.verbose)

    root = args.root.expanduser().resolve()
    skip_prefixes = set(args.skip_prefix)

    if args.command == "list":
        ignored, unwatched = collect_statuses(
            root, skip_prefixes, show_progress=not args.no_progress
        )
        write_paths(ignored, args.out_ignored)
        write_paths(unwatched, args.out_unwatched)
        logger.info("Wrote %d ignored paths to %s", len(ignored), args.out_ignored)
        logger.info(
            "Wrote %d unwatched paths to %s", len(unwatched), args.out_unwatched
        )
        return 0

    if args.command == "rename":
        rel_paths = read_paths(args.paths_file)
        rename_paths(root, rel_paths, args.suffix, args.dry_run, logger)
        return 0

    parser.error("Unknown command")
    return 2


if __name__ == "__main__":
    raise SystemExit(main())
