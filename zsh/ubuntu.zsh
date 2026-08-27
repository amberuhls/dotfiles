if [[ -r "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]]; then
  export ZSH="$HOME/.oh-my-zsh"

  plugins=(
    git
    zsh-autosuggestions
  )

  ZSH_THEME="powerlevel10k/powerlevel10k"
  source "$ZSH/oh-my-zsh.sh"
fi

# Ubuntu packages bat as batcat on some releases
if ! command -v bat >/dev/null 2>&1 && command -v batcat >/dev/null 2>&1; then
  alias bat='batcat'
fi

if ! command -v fd >/dev/null 2>&1 && command -v fdfind >/dev/null 2>&1; then
  alias fd='fdfind'
fi

[[ -r "$HOME/.p10k.zsh" ]] && source "$HOME/.p10k.zsh"

if [[ -r "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
  source "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi
