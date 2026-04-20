# Copilot instructions for this repo

This repo is a small, personal dotfiles collection. No templating tools
(chezmoi, stow, etc.) are used — just plain files and symlinks driven by
`install.sh`. Keep it that way unless explicitly asked to change.

## Where things go

| File / dir | Purpose | Notes for edits |
|---|---|---|
| `.bashrc` | Bash shell config. Symlinked to `~/.bashrc` by `install.sh`. | Put bash-specific config here. Cross-shell aliases/exports go in `.aliases` / `.exports` instead. Guard OS- or tool-specific lines with `command -v` / `uname` checks. |
| `.zshrc` | Zsh shell config. Symlinked to `~/.zshrc` by `install.sh`. Uses oh-my-zsh. | Put zsh-specific config and the `plugins=(...)` array here. Never hardcode absolute paths like `/home/<user>/...` — use `$HOME`. `zsh-syntax-highlighting` must be the last plugin. |
| `.aliases` | Shared aliases sourced by both `.bashrc` and `.zshrc`. | POSIX-compatible only. Guard tool-specific aliases with `command -v`. |
| `.exports` | Shared env vars (PATH, EDITOR, LANG, brew shellenv) sourced by both rc files. | POSIX-compatible only. |
| `.editorconfig` | Editor whitespace/indent rules. Symlinked to `~/.editorconfig`. | |
| `.gitignore_global` | Global gitignore. `install.sh` wires `git config --global core.excludesfile ~/.gitignore_global`. | |
| `bin/` | Executable scripts. `install.sh` symlinks each entry into `~/bin`, which is on `$PATH` via `.exports`. | Add small, portable shell scripts here. Use `#!/usr/bin/env bash` or `#!/bin/sh`. `chmod +x` the file. |
| `vscode/settings.json` | VS Code user settings. Symlinked to `~/Library/Application Support/Code/User/settings.json` on macOS, `~/.config/Code/User/settings.json` on Linux. | Keep JSON valid. Not used by Codespaces web UI (that uses Settings Sync). |
| `install.sh` | Entry point. Symlinks tracked files + `bin/` + `vscode/` into `$HOME`, runs `install-zsh.sh`, `chsh`'s to zsh on Linux, wires git global ignore. | Must stay idempotent. Back up existing non-symlink targets before replacing. Works on macOS and Debian/Ubuntu. |
| `install-zsh.sh` | Installs zsh (Linux only), oh-my-zsh, `zsh-autosuggestions`, `zsh-syntax-highlighting`. | Must stay idempotent and cross-platform. Gate `apt-get` behind a `uname` check. |
| `Makefile` | Convenience targets: `install`, `link`, `zsh`, `lint`. | |
| `.github/workflows/ci.yml` | Runs `shellcheck` on push/PR. | |
| `README.md` | Human-facing overview + install instructions. | Update when adding a new top-level file or changing install behavior. |
| `.github/copilot-instructions.md` | This file. | Keep in sync with repo structure. |

Machine-local overrides: put anything you don't want tracked in
`~/.bashrc.local` / `~/.zshrc.local`. Both rc files source them if present.

## Adding a new dotfile

1. Drop the file in the repo root using its real name (e.g. `.gitconfig`, not `dot_gitconfig`).
2. Add the filename to the `FILES=(...)` array in `install.sh`.
3. Re-run `./install.sh` to create the symlink.
4. Update `README.md` if it belongs in the layout table.

## Adding a new bin script

1. Put it in `bin/` with a shebang and `chmod +x`.
2. No installer change needed — `install.sh` picks it up automatically.

## Portability rules

- Target environments: **macOS** and **GitHub Codespaces (Debian/Ubuntu)**.
- Do not assume `apt`, `brew`, `kubectl`, `docker`, etc. are installed. Guard with `command -v <tool> >/dev/null 2>&1`.
- Do not `sudo` on macOS. Keep `sudo apt-get ...` inside `Linux` branches.
- Do not hardcode `$HOME` paths; use the variable.
- Do not `source` files using relative paths from rc files — the rc is evaluated from `$HOME`, not the repo dir.

## Non-goals

- No secrets, no templating, no per-machine diffs. If that becomes needed, revisit tool choice (chezmoi, stow) first.
