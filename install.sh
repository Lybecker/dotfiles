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

# On Linux (Codespaces), set zsh as the default login shell so VS Code's
# integrated terminal picks it up via $SHELL. Idempotent.
if [ "$(uname -s)" = "Linux" ] && command -v zsh >/dev/null 2>&1; then
  zsh_path="$(command -v zsh)"
  if [ "${SHELL:-}" != "$zsh_path" ]; then
    # chsh needs zsh to be listed in /etc/shells
    if ! grep -qx "$zsh_path" /etc/shells 2>/dev/null; then
      echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null || true
    fi
    sudo chsh -s "$zsh_path" "$(whoami)" 2>/dev/null || \
      chsh -s "$zsh_path" 2>/dev/null || \
      echo "Could not chsh to zsh; run manually if desired." >&2
  fi
fi

# Symlink VS Code user settings (settings.json, keybindings.json) if present.
case "$(uname -s)" in
  Darwin) VSCODE_USER="$HOME/Library/Application Support/Code/User" ;;
  Linux)  VSCODE_USER="$HOME/.config/Code/User" ;;
  *)      VSCODE_USER="" ;;
esac
if [ -n "${VSCODE_USER:-}" ] && [ -d "$SCRIPT_DIR/vscode" ]; then
  mkdir -p "$VSCODE_USER"
  for f in settings.json keybindings.json; do
    if [ -f "$SCRIPT_DIR/vscode/$f" ]; then
      backup_and_link "$SCRIPT_DIR/vscode/$f" "$VSCODE_USER/$f"
    fi
  done
fi

# Point git at our global ignore file (idempotent).
if command -v git >/dev/null 2>&1; then
  git config --global core.excludesfile "$HOME/.gitignore_global"
fi

echo "Done."
