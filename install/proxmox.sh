#!/usr/bin/env bash
set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/.dotfiles}"

if ! command -v pveversion >/dev/null 2>&1; then
  echo "Error: this does not appear to be a Proxmox VE host." >&2
  exit 1
fi

echo "Detected: $(pveversion)"
echo "Installing user-space Debian dotfiles only."
echo "No Proxmox repositories, networking, kernel, storage, or virtualization configuration will be changed."
echo

bash "$DOTFILES/install/debian.sh"
