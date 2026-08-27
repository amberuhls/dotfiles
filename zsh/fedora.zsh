if [[ -r /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
  source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

# Powerlevel10k
if [[ -r "$HOME/.powerlevel10k/powerlevel10k.zsh-theme" ]]; then
  source "$HOME/.powerlevel10k/powerlevel10k.zsh-theme"
fi

[[ -r "$HOME/.p10k.zsh" ]] && source "$HOME/.p10k.zsh"

# Keep syntax highlighting last
if [[ -r /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
  source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi
