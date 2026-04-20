# Lybecker's dotfiles

Plain symlink-based dotfiles. Works on macOS and GitHub Codespaces / Debian-Ubuntu.

## Install

```sh
git clone https://github.com/<you>/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

`install.sh` symlinks every tracked dotfile (e.g. `.bashrc`, `.zshrc`) into `$HOME`
and then runs `install-zsh.sh` to install zsh, oh-my-zsh, and the
`zsh-autosuggestions` plugin. Existing files are backed up with a timestamp
suffix. The script is idempotent.

## Layout

- `.bashrc`, `.zshrc` — shell config, symlinked into `$HOME`.
- `.aliases`, `.exports` — shared aliases and env vars sourced by both rc files.
- `.editorconfig`, `.gitignore_global` — editor + git hygiene, symlinked into `$HOME`.
- `install.sh` — entrypoint installer (symlinks + calls `install-zsh.sh` + wires `core.excludesfile`).
- `install-zsh.sh` — installs zsh, oh-my-zsh, `zsh-autosuggestions`, and `zsh-syntax-highlighting`.
- `bin/` — anything here is symlinked into `~/bin`, which is on `$PATH`.
- `Makefile` — `make install`, `make link`, `make zsh`, `make lint`.
- `.github/workflows/ci.yml` — shellcheck on push/PR.
- `.github/copilot-instructions.md` — guidance for AI agents editing this repo.

## Machine-local overrides

Anything you don't want tracked in git goes in `~/.bashrc.local` or `~/.zshrc.local`.
Both rc files source these if they exist.

## Guides

- [The art of the command line](https://github.com/jlevy/the-art-of-command-line)
