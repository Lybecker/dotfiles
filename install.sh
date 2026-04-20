#!/usr/bin/env bash
# Dotfiles installer.
# Symlinks tracked dotfiles into $HOME and installs zsh + oh-my-zsh.
# Works on macOS and GitHub Codespaces / Debian-Ubuntu.
# Idempotent: safe to re-run.

set -euo pipefail

# Resolve the directory this script lives in (POSIX-ish, handles symlinks).
SCRIPT_DIR="$(cd -P -- "$(dirname -- "$0")" && pwd -P)"

# Files in the repo that should be symlinked into $HOME.
FILES=(
  .bashrc
  .zshrc
  .aliases
  .exports
  .editorconfig
  .gitignore_global
)

backup_and_link() {
  local src="$1"
  local dst="$2"

  if [ -L "$dst" ]; then
    # Already a symlink; replace it to ensure it points to our repo.
    rm "$dst"
  elif [ -e "$dst" ]; then
    local backup
    backup="${dst}.backup.$(date +%Y%m%d%H%M%S)"
    echo "Backing up existing $dst -> $backup"
    mv "$dst" "$backup"
  fi

  ln -s "$src" "$dst"
  echo "Linked $dst -> $src"
}

for f in "${FILES[@]}"; do
  backup_and_link "$SCRIPT_DIR/$f" "$HOME/$f"
done

# Symlink every executable in ./bin into ~/bin (which is on $PATH via .bashrc/.zshrc)
mkdir -p "$HOME/bin"
if [ -d "$SCRIPT_DIR/bin" ]; then
  for src in "$SCRIPT_DIR/bin"/*; do
    [ -e "$src" ] || continue
    backup_and_link "$src" "$HOME/bin/$(basename "$src")"
  done
fi

# Install zsh + oh-my-zsh + plugins
"$SCRIPT_DIR/install-zsh.sh"

# Point git at our global ignore file (idempotent).
if command -v git >/dev/null 2>&1; then
  git config --global core.excludesfile "$HOME/.gitignore_global"
fi

echo "Done."
