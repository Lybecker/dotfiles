.PHONY: help install link zsh lint

help:
	@echo "Targets:"
	@echo "  install   Symlink dotfiles and install zsh + plugins"
	@echo "  link      Symlink dotfiles only (no zsh install)"
	@echo "  zsh       Run install-zsh.sh only"
	@echo "  lint      Run shellcheck on all shell scripts"

install:
	./install.sh

link:
	@SCRIPT_DIR="$$(pwd)" bash -c '\
		FILES=(.bashrc .zshrc .aliases .exports .editorconfig .gitignore_global); \
		for f in "$${FILES[@]}"; do \
			ln -sfn "$$SCRIPT_DIR/$$f" "$$HOME/$$f" && echo "Linked ~/$$f"; \
		done'

zsh:
	./install-zsh.sh

lint:
	@if ! command -v shellcheck >/dev/null 2>&1; then \
		echo "shellcheck not installed"; exit 1; \
	fi
	shellcheck --severity=error install.sh install-zsh.sh bin/*.sh
	shellcheck --severity=error --shell=bash .bashrc .aliases .exports
