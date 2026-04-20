#!/usr/bin/env bash
# Installs zsh, oh-my-zsh, and the zsh-autosuggestions plugin.
# Idempotent: safe to run multiple times. Supports macOS and Debian/Ubuntu (Codespaces).

set -e

unameOut="$(uname -s)"
case "${unameOut}" in
  Linux*)  MACHINE=Linux;;
  Darwin*) MACHINE=Mac;;
  *)       MACHINE="UNKNOWN:${unameOut}";;
esac

# Install zsh if missing
if ! command -v zsh >/dev/null 2>&1; then
  case "$MACHINE" in
    Linux)
      sudo apt-get update
      sudo apt-get install -y zsh
      ;;
    Mac)
      # zsh ships with macOS; nothing to do
      ;;
    *)
      echo "Unsupported OS: $MACHINE" >&2
      exit 1
      ;;
  esac
fi

# Install oh-my-zsh (unattended) if missing
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  ZSH="$HOME/.oh-my-zsh" RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Install zsh-autosuggestions plugin if missing
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions \
    "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

# Install zsh-syntax-highlighting plugin if missing
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
    "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi
