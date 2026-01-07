#!/usr/bin/env bash
set -euo pipefail



REMOTE="dropbox:thibault"
MAX_DEPTH=6               # adjust
TPS_LIST=12                # listing is what triggers 429s; keep low
TPS_PURGE=2
TIMESTAMP="$(date +%F_%H%M)"
LOG="$HOME/rclone_bfs_purge_${TIMESTAMP}.log"

# Basename match: directory name (no trailing slash) must match one of these
UNWANTED_RE='^(__pycache__|\.pytest_cache|\.mypy_cache|\.ruff_cache|\.pytype|\.hypothesis|htmlcov|\.nox|\.tox|\.eggs|\.ipynb_checkpoints|\.conda|\.mamba|conda-bld|\.Rproj\.user|CMakeFiles|build|dist|target|\.venv|venv|\.pixi|node_modules|\.npm|\.yarn|\.pnpm-store|\.parcel-cache|\.next|\.nuxt|\.svelte-kit|\.cache|\.Trash)$'

# frontier contains paths *relative* to REMOTE, without leading/trailing slash
frontier_file="$(mktemp)"
next_file="$(mktemp)"
trap 'rm -f "$frontier_file" "$next_file"' EXIT

# depth 0: start at remote root
printf "%s\n" "" > "$frontier_file"

for ((depth=0; depth<=MAX_DEPTH; depth++)); do
  : > "$next_file"
  echo "=== depth $depth ===" | tee -a "$LOG"

  while IFS= read -r rel; do
    # Build the directory to list: REMOTE[/rel]
    if [[ -z "$rel" ]]; then
      dir="$REMOTE"
    else
      dir="$REMOTE/$rel"
    fi

    # List immediate child directories (one level only)
    # lsf --dirs-only returns names with trailing '/'
    # Use --fast-list; keep TPS low to avoid 429.
    children="$(
      rclone lsf "$dir" --dirs-only \
        --tpslimit "$TPS_LIST" --tpslimit-burst 0 --fast-list \
        --log-level INFO --log-file "$LOG" \
      || true
    )"

    # If throttled, rclone will sleep internally; if it errors out, we continue.
    while IFS= read -r child; do
      [[ -z "$child" ]] && continue
      child="${child%/}"          # strip trailing slash
      base="$child"

      # Construct child relative path for queue/purge
      if [[ -z "$rel" ]]; then
        child_rel="$child"
      else
        child_rel="$rel/$child"
      fi

      if [[ "$base" =~ $UNWANTED_RE ]]; then
        echo "PURGE $REMOTE/$child_rel" | tee -a "$LOG"
        rclone purge "$REMOTE/$child_rel" \
          --tpslimit "$TPS_PURGE" --tpslimit-burst 0 \
          --log-level INFO --log-file "$LOG" \
          || true
      else
        # Keep exploring this directory at next depth
        printf "%s\n" "$child_rel" >> "$next_file"
      fi
    done <<< "$children"

  done < "$frontier_file"

  # Prepare next depth
  mv "$next_file" "$frontier_file"
  : > "$next_file"

  # Early exit if nothing left to traverse
  if [[ ! -s "$frontier_file" ]]; then
    echo "Frontier empty at depth $depth; done." | tee -a "$LOG"
    break
  fi
done
