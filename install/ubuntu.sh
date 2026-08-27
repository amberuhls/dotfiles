#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$HOME/.dotfiles"

sudo apt update

sudo apt install -y \
  bat \
  btop \
  fd-find \
  fzf \
  git \
  micro \
  ripgrep \
  zoxide \
  zsh

source "$DOTFILES/install/common.sh"

setup_common_dotfiles
ensure_zsh_default_shell

echo
echo "Ubuntu dotfiles setup complete."
echo "Start a fresh shell with:"
echo "  exec zsh"
