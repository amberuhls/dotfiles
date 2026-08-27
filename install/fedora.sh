#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$HOME/.dotfiles"

sudo dnf install -y \
  bat \
  btop \
  eza \
  fd-find \
  fzf \
  git \
  micro \
  ripgrep \
  zoxide \
  zsh \
  zsh-autosuggestions \
  zsh-syntax-highlighting

source "$DOTFILES/install/common.sh"

setup_common_dotfiles
ensure_zsh_default_shell

echo
echo "Fedora dotfiles setup complete."
echo "Start a fresh shell with:"
echo "  exec zsh"
