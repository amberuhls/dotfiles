# A one-line prompt using terminal colors and ordinary Unicode glyphs.
# Expand prompt escapes, but never execute branch or environment names.
setopt PROMPT_PERCENT
unsetopt PROMPT_SUBST

# The prompt renders environment state itself; avoid duplicate manager prefixes.
export VIRTUAL_ENV_DISABLE_PROMPT=1
export CONDA_CHANGEPS1=false

autoload -Uz add-zsh-hook
zmodload zsh/datetime

dotfiles_preexec() {
  typeset -gF _dotfiles_command_started=$EPOCHREALTIME
}

dotfiles_precmd() {
  local last_status=$?
  local branch git_segment='' status_segment=''
  local env_name env_segment=''
  local identity='%F{blue}%n@%m%f'
  local context_segment='' duration_segment='' duration
  local -F elapsed
  local -a environments=()
  local -a contexts=()

  # Clear after each command so idle time and blank Enter presses are excluded.
  if (( ${+_dotfiles_command_started} )); then
    elapsed=$(( EPOCHREALTIME - _dotfiles_command_started ))
    unset _dotfiles_command_started
    if (( elapsed >= 5 )); then
      printf -v duration '%.1fs' "$elapsed"
      duration_segment=" %F{242}│%f %F{yellow}${duration}%f"
    fi
  fi

  if (( EUID == 0 )); then
    identity='%B%F{red}%n@%m%f%b'
  fi
  if [[ -n ${SSH_CONNECTION:-} || -n ${SSH_TTY:-} ]]; then
    contexts+=(ssh)
  fi
  if [[ -n ${CONTAINER_ID:-} ]]; then
    contexts+=("box:${CONTAINER_ID}")
  elif [[ -n ${container:-} ]]; then
    contexts+=("container:${container}")
  elif [[ -e /run/.containerenv || -e /.dockerenv ]]; then
    contexts+=(container)
  fi
  if (( ${#contexts} )); then
    env_name="${(j: :)contexts}"
    env_name=${env_name//[[:cntrl:]]/}
    env_name=${env_name//\%/%%}
    context_segment=" %F{242}│%f %F{yellow}${env_name}%f"
  fi

  if [[ -n ${VIRTUAL_ENV:-} ]]; then
    env_name=${VIRTUAL_ENV:t}
    if [[ "$env_name" == (.venv|venv|.env|env) ]]; then
      env_name=${VIRTUAL_ENV:h:t}
    fi
    environments+=("venv:${env_name}")
  fi

  if [[ -n ${CONDA_PREFIX:-} ]]; then
    env_name=${CONDA_DEFAULT_ENV:-${CONDA_PREFIX:t}}
    environments+=("conda:${env_name:t}")
  fi

  if [[ -n ${IN_NIX_SHELL:-} ]]; then
    environments+=("nix:${IN_NIX_SHELL}")
  fi

  if (( ${#environments} )); then
    env_name="${(j: :)environments}"
    env_name=${env_name//[[:cntrl:]]/}
    env_name=${env_name//\%/%%}
    env_segment=" %F{242}│%f %B%F{yellow}${env_name}%f%b"
  fi

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

  PROMPT="${identity}${context_segment} %F{242}│%f %F{cyan}%~%f${env_segment}${git_segment} %F{242}│%f ${status_segment}${duration_segment} %F{242}│%f %F{white}%D{%I:%M:%S %p}%f %(!.%F{red}#.%F{green}❯)%f "
  RPROMPT=''
}

# Re-sourcing ~/.zshrc must not duplicate the hook.
add-zsh-hook -d precmd dotfiles_precmd
add-zsh-hook precmd dotfiles_precmd
add-zsh-hook -d preexec dotfiles_preexec
add-zsh-hook preexec dotfiles_preexec
