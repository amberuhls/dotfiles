#!/usr/bin/env bash
set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/.dotfiles}"

backup_if_regular_file() {
  local path="$1"

  if [[ -e "$path" && ! -L "$path" ]]; then
    local backup="${path}.backup"

    if [[ -e "$backup" ]]; then
      backup="${path}.backup.$(date +%Y%m%d-%H%M%S)"
    fi

    echo "Backing up $path -> $backup"
    mv "$path" "$backup"
  fi
}

link_file() {
  local source="$1"
  local target="$2"

  mkdir -p "$(dirname "$target")"

  backup_if_regular_file "$target"

  if [[ -L "$target" ]]; then
    rm "$target"
  fi

  echo "Linking $target -> $source"
  ln -s "$source" "$target"
}

setup_common_dotfiles() {
  link_file "$DOTFILES/zsh/zshrc" "$HOME/.zshrc"
  link_file "$DOTFILES/bat/config" "$HOME/.config/bat/config"
  link_file "$DOTFILES/git/ignore" "$HOME/.config/git/ignore"

  git config --global core.excludesfile "$HOME/.config/git/ignore"
}

ensure_zsh_default_shell() {
  if [[ "${SHELL:-}" != "$(command -v zsh)" ]]; then
    echo
    echo "Current default shell: ${SHELL:-unknown}"
    echo "zsh location: $(command -v zsh)"
    echo
    echo "To make zsh your default shell, run:"
    echo "  chsh -s $(command -v zsh)"
  fi
}
