# -------------------------------------------------------------------
# Preferred programs
# -------------------------------------------------------------------

export EDITOR="micro"
export VISUAL="micro"
export PAGER="less"
export LESS="-FRX"

export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/go/bin:$PATH"

# -------------------------------------------------------------------
# History
# -------------------------------------------------------------------

HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000

setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS

# -------------------------------------------------------------------
# Completion
# -------------------------------------------------------------------

autoload -Uz compinit
compinit

zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' menu select

# -------------------------------------------------------------------
# Modern CLI tools
# -------------------------------------------------------------------

if command -v eza >/dev/null 2>&1; then
  alias ls='eza --group-directories-first'
  alias ll='eza -lah --group-directories-first --git'
  alias la='eza -a --group-directories-first'
  alias l='eza -lah --group-directories-first'
  alias tree='eza --tree'
fi

if command -v btop >/dev/null 2>&1; then
  alias top='btop'
fi

alias grep='grep --color=auto'

# cat remains the normal Unix cat.
# bat has its own config in ~/.config/bat/config.

# -------------------------------------------------------------------
# File operations
# -------------------------------------------------------------------

alias rm='rm -I'
alias cp='cp -i'
alias mv='mv -i'
alias md='mkdir -p'

alias df='df -h'

# -------------------------------------------------------------------
# Directory navigation
# -------------------------------------------------------------------

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# Use zoxide in place of interactive cd
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init --cmd cd zsh)"
fi

# -------------------------------------------------------------------
# Shortcuts
# -------------------------------------------------------------------

alias c='clear'
alias h='history'
alias zshconfig='micro ~/.zshrc'
alias reload='source ~/.zshrc'

showpath() {
  print -l $path
}

# -------------------------------------------------------------------
# Git
# -------------------------------------------------------------------

alias g='git'
alias ga='git add'
alias gaa='git add --all'
alias gb='git branch'
alias gc='git commit -m'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gd='git diff'
alias gds='git diff --staged'
alias gl='git log --oneline --graph --decorate'
alias gp='git push'
alias gpf='git push --force-with-lease'
alias gpl='git pull --ff-only'
alias gs='git status -sb'

# -------------------------------------------------------------------
# Python / Node
# -------------------------------------------------------------------

alias py='python3'

alias ni='npm install'
alias nr='npm run'
alias nrd='npm run dev'
alias nrs='npm run start'

# -------------------------------------------------------------------
# Functions
# -------------------------------------------------------------------

mcd() {
  if [[ $# -ne 1 ]]; then
    echo "Usage: mcd DIRECTORY" >&2
    return 2
  fi

  mkdir -p "$1" && cd "$1"
}

serve() {
  local port="${1:-8000}"
  echo "Serving current directory on http://localhost:$port"
  python3 -m http.server "$port"
}

# -------------------------------------------------------------------
# fzf
# -------------------------------------------------------------------

if command -v fzf >/dev/null 2>&1; then
  if fzf --zsh >/dev/null 2>&1; then
    source <(fzf --zsh)
  fi
fi

export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --inline-info"
export FZF_CTRL_R_OPTS="--sort --exact"

# Prefix-based history search
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search

zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

bindkey "^[[A" up-line-or-beginning-search
bindkey "^[[B" down-line-or-beginning-search
