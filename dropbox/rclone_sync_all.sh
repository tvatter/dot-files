#!/usr/bin/env bash
set -euo pipefail

FLAGS=(
  --progress --stats 30s --stats-one-line
  --transfers 32 --checkers 32
  --dropbox-batch-mode sync --dropbox-batch-size 800
  --dropbox-chunk-size 128M
  --tpslimit 12 --tpslimit-burst 0
  --log-level INFO
)

ts="$(date +%F_%H%M)"

echo "===== $ts starting Dropbox sync ====="
rclone sync "$HOME/Dropbox" "dropbox:" \
    "${FLAGS[@]}" --exclude ".dropbox" \
    --log-file "$HOME/rclone_sync_dropbox_${ts}.log"
#for d in thibault photos officiel fanny fanny_thibault_research; do
#  echo "===== $(date -Is) syncing $d ====="
#  rclone sync "$HOME/Dropbox/$d" "dropbox:$d" \
#    "${FLAGS[@]}" \
#    --log-file "$HOME/rclone_sync_${d}_${ts}.log"
#done

echo "===== $(date -Is) DONE ====="