# Loaded only by the explicit minerva-zsh launcher, not by Rocky detection.
# Keep the site's module environment; initialize Lmod's Zsh function if needed.
if (( ! $+functions[module] )) && [[ -n ${LMOD_DIR:-} && -r "$LMOD_DIR/../init/profile" ]]; then
  source "$LMOD_DIR/../init/profile"
fi

if [[ -r "$HOME/.local/share/dotfiles/minerva/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
  source "$HOME/.local/share/dotfiles/minerva/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

# Keep syntax highlighting last.
if [[ -r "$HOME/.local/share/dotfiles/minerva/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
  source "$HOME/.local/share/dotfiles/minerva/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi
