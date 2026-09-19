#!/usr/bin/env bash
set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/.dotfiles}"
BOX_NAME="${STEAMOS_DOTFILES_BOX:-steamos-dotfiles}"
BOX_IMAGE="${STEAMOS_DOTFILES_IMAGE:-docker.io/library/archlinux:latest}"

source "$DOTFILES/install/common.sh"

for command_name in distrobox podman; do
  if ! command -v "$command_name" >/dev/null 2>&1; then
    echo "Error: $command_name is not available." >&2
    echo "SteamOS 3.5+ normally includes Distrobox and Podman." >&2
    exit 1
  fi
done

# ~/.zshrc, ~/.config/git/ignore, ~/.local/bin/msvpn, etc.
# These live in $HOME and persist normally across SteamOS updates.
setup_common_dotfiles

if ! podman container exists "$BOX_NAME"; then
  echo
  echo "Creating Distrobox: $BOX_NAME"

  distrobox create \
    --yes \
    --name "$BOX_NAME" \
    --image "$BOX_IMAGE"
fi

echo
echo "Installing CLI tools in $BOX_NAME..."

distrobox enter "$BOX_NAME" -- \
  sudo pacman -Syu --noconfirm --needed \
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
    zsh-history-substring-search \
    zsh-syntax-highlighting

# Make zsh the login shell inside the container only.
distrobox enter "$BOX_NAME" -- \
  sudo usermod --shell /usr/bin/zsh "$USER"

echo
echo "SteamOS dotfiles setup complete."
echo "The SteamOS base system was not modified."
echo
echo "Enter your persistent CLI environment with:"
echo "  distrobox enter $BOX_NAME"
