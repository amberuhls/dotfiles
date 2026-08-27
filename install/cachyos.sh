#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$HOME/.dotfiles"

sudo pacman -S --needed \
  bat \
  btop \
  eza \
  fd \
  fzf \
  git \
  micro \
  ripgrep \
  zoxide \
  zsh \
  zsh-autosuggestions \
  zsh-syntax-highlighting \
  zsh-history-substring-search

source "$DOTFILES/install/common.sh"

setup_common_dotfiles
ensure_zsh_default_shell

echo
echo "CachyOS dotfiles setup complete."
echo "Start a fresh shell with:"
echo "  exec zsh"
