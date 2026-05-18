#!/usr/bin/env bash
# Clone (or reuse) upstream Copilot CLI skill/agent repos and symlink them
# into ~/.copilot/skills/ and ~/.copilot/agents/. Idempotent.

set -euo pipefail

SCRIPT_DIR="$(cd -P -- "$(dirname -- "$0")" && pwd -P)"
LIST="$SCRIPT_DIR/extensions.txt"
ROOT="${COPILOT_EXTENSIONS_DIR:-$HOME/copilot-extensions}"

mkdir -p "$ROOT" "$HOME/.copilot/skills" "$HOME/.copilot/agents"

if [ ! -f "$LIST" ]; then
  echo "No extensions.txt found at $LIST" >&2
  exit 1
fi

while IFS='|' read -r kind repo src name ref; do
  # Skip comments and blank lines.
  case "${kind:-}" in
    ''|\#*) continue ;;
  esac

  repo_name="$(basename "$repo" .git)"
  dir="$ROOT/$repo_name"

  if [ ! -d "$dir/.git" ]; then
    echo "Cloning $repo -> $dir"
    git clone "$repo" "$dir"
  fi

  if [ -n "${ref:-}" ]; then
    echo "Pinning $repo_name to $ref"
    git -C "$dir" fetch --tags --quiet
    git -C "$dir" checkout --quiet "$ref"
  fi

  case "$kind" in
    skill) target="$HOME/.copilot/skills/$name" ;;
    agent) target="$HOME/.copilot/agents/$name" ;;
    *) echo "Unknown kind '$kind' for $repo" >&2; continue ;;
  esac

  source_path="$dir/$src"
  if [ ! -e "$source_path" ]; then
    echo "WARNING: source $source_path does not exist (skipping link)" >&2
    continue
  fi

  ln -sfn "$source_path" "$target"
  echo "Linked $target -> $source_path"
done < "$LIST"

echo "Done."
