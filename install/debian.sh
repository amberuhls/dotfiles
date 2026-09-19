#!/usr/bin/env bash
set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/.dotfiles}"

if (( EUID == 0 )); then
  APT=()
else
  if ! command -v sudo >/dev/null 2>&1; then
    echo "Error: sudo is required when running as a non-root user." >&2
    exit 1
  fi

  APT=(sudo)
fi

"${APT[@]}" apt update

"${APT[@]}" apt install -y \
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
echo "Debian dotfiles setup complete."
echo "Start a fresh shell with:"
echo "  exec zsh"
