# A one-line prompt using terminal colors and ordinary Unicode glyphs.
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
      branch=${branch//[[:cntrl:]]/}
      branch=${branch//\%/%%}
      git_segment=" %F{242}│%f %F{magenta}git:${branch}%f"
    fi
  fi

  if (( last_status == 0 )); then
    status_segment='%F{green}✔%f'
  else
    status_segment="%F{red}✘ ${last_status}%f"
  fi

  PROMPT="%F{blue}%n@%m%f %F{242}│%f %F{cyan}%~%f${git_segment} %F{242}│%f ${status_segment} %F{242}│%f %F{white}%D{%I:%M:%S %p}%f %(!.%F{red}#.%F{green}❯)%f "
  RPROMPT=''
}

# Re-sourcing ~/.zshrc must not duplicate the hook.
add-zsh-hook -d precmd dotfiles_precmd
add-zsh-hook precmd dotfiles_precmd
