# A two-line prompt using terminal colors and ASCII only.
# Expand prompt escapes, but never execute text from a branch name.
setopt PROMPT_PERCENT
unsetopt PROMPT_SUBST

autoload -Uz add-zsh-hook

dotfiles_precmd() {
  local last_status=$?
  local branch git_segment='' status_segment=''

  if command -v git >/dev/null 2>&1; then
    branch=$(command git symbolic-ref --quiet --short HEAD 2>/dev/null) ||
      branch=$(command git rev-parse --short HEAD 2>/dev/null) || branch=''
    if [[ -n "$branch" ]]; then
      # Strip terminal control characters and escape Zsh prompt markers.
      branch=${branch//[[:cntrl:]]/}
      branch=${branch//\%/%%}
      git_segment=" %F{magenta}git:(${branch})%f"
    fi
  fi

  if (( last_status != 0 )); then
    status_segment=" %F{red}exit:${last_status}%f"
  fi

  PROMPT="%F{cyan}%~%f${git_segment}${status_segment}"$'\n''%(!.%F{red}#.%F{green}>)%f '
  RPROMPT=''
}

# Re-sourcing ~/.zshrc must not duplicate the hook.
add-zsh-hook -d precmd dotfiles_precmd
add-zsh-hook precmd dotfiles_precmd
