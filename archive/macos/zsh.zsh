# Homebrew
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

if command -v brew >/dev/null 2>&1; then
  BREW_PREFIX="$(brew --prefix)"

  [[ -d "$BREW_PREFIX/opt/coreutils/libexec/gnubin" ]] &&
    export PATH="$BREW_PREFIX/opt/coreutils/libexec/gnubin:$PATH"

  [[ -d "$BREW_PREFIX/opt/findutils/libexec/gnubin" ]] &&
    export PATH="$BREW_PREFIX/opt/findutils/libexec/gnubin:$PATH"

  [[ -d "$BREW_PREFIX/opt/grep/libexec/gnubin" ]] &&
    export PATH="$BREW_PREFIX/opt/grep/libexec/gnubin:$PATH"

  [[ -d "$BREW_PREFIX/opt/gnu-sed/libexec/gnubin" ]] &&
    export PATH="$BREW_PREFIX/opt/gnu-sed/libexec/gnubin:$PATH"

  [[ -d "$BREW_PREFIX/opt/gnu-tar/libexec/gnubin" ]] &&
    export PATH="$BREW_PREFIX/opt/gnu-tar/libexec/gnubin:$PATH"

  [[ -d "$BREW_PREFIX/opt/diffutils/libexec/gnubin" ]] &&
    export PATH="$BREW_PREFIX/opt/diffutils/libexec/gnubin:$PATH"
fi

cleanzip() {
  if [[ $# -ne 2 ]]; then
    echo "Usage: cleanzip SOURCE OUTPUT.zip" >&2
    return 2
  fi

  ditto -c -k --norsrc --keepParent "$1" "$2"
}
