#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$HOME/.dotfiles"

if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew is required before running this script."
  exit 1
fi

brew install \
  bat \
  btop \
  eza \
  fd \
  fzf \
  git \
  micro \
  ripgrep \
  zoxide \
  zsh-autosuggestions \
  zsh-syntax-highlighting \
  powerlevel10k

source "$DOTFILES/install/common.sh"

setup_common_dotfiles

# Mac-specific configs
if [[ -f "$DOTFILES/ghostty/config" ]]; then
  link_file \
    "$DOTFILES/ghostty/config" \
    "$HOME/.config/ghostty/config"
fi

if [[ -f "$DOTFILES/aerospace/aerospace.toml" ]]; then
  link_file \
    "$DOTFILES/aerospace/aerospace.toml" \
    "$HOME/.aerospace.toml"
fi

echo
echo "macOS dotfiles setup complete."
echo "Start a fresh shell with:"
echo "  exec zsh"
