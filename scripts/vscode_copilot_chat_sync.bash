#!/bin/bash
set -e

# This script merges the chat session index from the current VS Code state with the one from a backup, and updates the current state with the merged result.

# Source state file:
source_hash="5257bdc3442c95e67fbad1ad9c4c2ad7"
source_folder="$HOME/Downloads/$source_hash"
source_db="$source_folder/state.vscdb"

# Target state file:
target_hash="c73bec41d0c0ca18c2ac7217462b7741"
target_folder="$HOME/.config/Code/User/workspaceStorage/$target_hash"
target_db="$target_folder/state.vscdb"

# Copy the content of the chatEditingSessions and chatSessions folders from the source to the target, overwriting existing files.
cp -r "$source_folder/chatEditingSessions/"* "$target_folder/chatEditingSessions/"
cp -r "$source_folder/chatSessions/"* "$target_folder/chatSessions/"

# Extract the chat session index from both source and target state databases.
sqlite3 "$source_db" \
  "SELECT value FROM ItemTable WHERE key = 'chat.ChatSessionStore.index';" \
  > copilot_source_index.json

sqlite3 "$target_db" \
  "SELECT value FROM ItemTable WHERE key = 'chat.ChatSessionStore.index';" \
  > copilot_target_index.json

TARGET_DB="$target_db" python - <<'PY'
import json
from pathlib import Path
import sqlite3
import os

src = json.loads(Path("copilot_source_index.json").read_text())
dst = json.loads(Path("copilot_target_index.json").read_text())

src_entries = src.get("entries", {})
dst_entries = dst.get("entries", {})

merged_entries = {**src_entries, **dst_entries}

merged = {
    "version": max(src.get("version", 1), dst.get("version", 1)),
    "entries": merged_entries,
}

Path("copilot_merged_index.json").write_text(
    json.dumps(merged, separators=(",", ":"))
)

print(f"source: {len(src_entries)} entries")
print(f"target: {len(dst_entries)} entries")
print(f"merged: {len(merged_entries)} entries")

db = Path(os.environ["TARGET_DB"]).expanduser()
value = Path("copilot_merged_index.json").read_text()

con = sqlite3.connect(str(db))
cur = con.cursor()
cur.execute(
    "UPDATE ItemTable SET value = ? WHERE key = 'chat.ChatSessionStore.index'",
    (value,),
)
con.commit()
con.close()
PY

rm copilot_source_index.json copilot_target_index.json copilot_merged_index.json
