#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$HOME/.dotfiles"
source "$DOTFILES/install/common.sh"

if ! command -v conda >/dev/null 2>&1; then
  echo 'Load a Minerva Miniforge module first: module load miniforge3' >&2
  echo 'Use module spider miniforge3 to find the available versions.' >&2
  exit 1
fi

root="$HOME/.local/share/dotfiles/minerva"
prefix="$root/env"
mkdir -p "$root/bin"
# Keep downloads user-owned without editing the research Conda configuration.
export CONDA_PKGS_DIRS="${CONDA_PKGS_DIRS:-$HOME/.cache/dotfiles/conda-pkgs}"
packages=(zsh git bat btop eza fd-find fzf micro ripgrep zoxide)

if [[ -d "$prefix/conda-meta" ]]; then
  conda install --yes --prefix "$prefix" --override-channels \
    --channel conda-forge --strict-channel-priority --update-all "${packages[@]}"
else
  conda create --yes --prefix "$prefix" --override-channels \
    --channel conda-forge --strict-channel-priority "${packages[@]}"
fi

# Expose only the requested CLI tools, not the environment's Python, libraries,
# compilers, or other dependencies. Do not activate this environment.
for tool in zsh git bat btop eza fd fzf micro rg zoxide; do
  if [[ ! -x "$prefix/bin/$tool" ]]; then
    echo "Missing expected executable: $prefix/bin/$tool" >&2
    exit 1
  fi
  link_file "$prefix/bin/$tool" "$root/bin/$tool"
done

for plugin in zsh-autosuggestions zsh-syntax-highlighting; do
  target="$root/plugins/$plugin"
  if [[ -d "$target/.git" ]]; then
    "$prefix/bin/git" -C "$target" pull --ff-only
  elif [[ -e "$target" ]]; then
    echo "Not a plugin Git checkout: $target" >&2
    exit 1
  else
    "$prefix/bin/git" clone --depth 1 "https://github.com/zsh-users/$plugin.git" "$target"
  fi
done

# No desktop configuration, VPN helper, chsh, or Bash startup changes on HPC.
link_file "$DOTFILES/zsh/zshrc" "$HOME/.zshrc"
link_file "$DOTFILES/git/ignore" "$HOME/.config/git/ignore"
"$prefix/bin/git" config --global core.excludesfile "$HOME/.config/git/ignore"
link_file "$DOTFILES/bin/minerva-zsh" "$HOME/.local/bin/minerva-zsh"

echo 'Minerva setup complete. Start with: ~/.local/bin/minerva-zsh'
echo 'Update later with: git -C ~/.dotfiles pull --ff-only && bash ~/.dotfiles/install/minerva.sh'
