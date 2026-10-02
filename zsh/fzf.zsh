if command -v fzf >/dev/null 2>&1; then
  () {
    local integration directory script
    if integration=$(fzf --zsh 2>/dev/null); then
      eval "$integration"
      return
    fi

    # Older fzf packages ship scripts instead of the --zsh integration option.
    # Resolve symlinks for user-installed tools such as Minerva's CLI links.
    local prefix=${commands[fzf]:A:h:h}
    for script in key-bindings.zsh completion.zsh; do
      for directory in "$prefix/share/fzf" "$prefix/share/fzf/shell" \
          "$prefix/share/doc/fzf/examples" /usr/share/fzf \
          /usr/share/fzf/shell /usr/share/doc/fzf/examples; do
        if [[ -r "$directory/$script" ]]; then
          source "$directory/$script"
          break
        fi
      done
    done
  }
fi
