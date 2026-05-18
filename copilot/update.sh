#!/usr/bin/env bash
# Pull latest changes for every cloned Copilot CLI extension.
# Skips repos that are checked out to a detached ref (i.e. pinned via the
# optional 5th field in extensions.txt).

set -euo pipefail

ROOT="${COPILOT_EXTENSIONS_DIR:-$HOME/copilot-extensions}"

if [ ! -d "$ROOT" ]; then
  echo "No extensions installed at $ROOT. Run bootstrap.sh first." >&2
  exit 0
fi

shopt -s nullglob
for d in "$ROOT"/*/; do
  name="$(basename "$d")"
  if ! git -C "$d" symbolic-ref -q HEAD >/dev/null; then
    echo "▶ $name (detached HEAD, pinned — skipping)"
    continue
  fi
  echo "▶ $name"
  git -C "$d" pull --ff-only
done
