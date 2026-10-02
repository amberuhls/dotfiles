# Dotfiles

Shared Zsh configuration for Fedora, Ubuntu, and CachyOS. Clone this repository
to `~/.dotfiles` on each computer, then run the matching installer:

```sh
bash ~/.dotfiles/install/fedora.sh
# or: bash ~/.dotfiles/install/ubuntu.sh
# or: bash ~/.dotfiles/install/cachyos.sh
```

For **Minerva (Rocky Linux 9, no root access)**, follow
[the Minerva instructions](install/minerva.md). Its separate user-only installer
uses Miniforge and leaves Bash login files and research environments in place.

Installers install CLI tools and Zsh plugins, back up existing non-symlink
configuration, and link the shared files. They print instructions for changing
your default shell when needed. Start a fresh shell with `exec zsh` afterward.

`~/Code/dotfiles` is a development checkout; runtime configuration deliberately
loads from `~/.dotfiles`. Changes in a development checkout must be transferred
to the deployment checkout before they affect your shell.

## Shell appearance

The shared native Zsh prompt stays on one line and uses ordinary Unicode glyphs.
No theme framework, Powerlevel10k, or Nerd Font is required. The optional Konsole
baseline uses ordinary Noto Sans Mono and Breeze colors.

```text
amber@workstation │ ~/Code/project │ venv:project │ git:main │ ✔ │ 11:36:32 AM ❯
```

The directory is cyan, the Git branch is magenta, and active environments are
bold yellow. Detached Git HEADs show a short commit ID. Failed commands show a
red `✘` and exit code; root shells use a red `#` marker. The prompt remains in
scrollback and avoids Git working-tree scans.

Environment indicators update before each prompt and disappear on deactivation:

- `venv:name` for activated Python venvs (`VIRTUAL_ENV`), including tools that
  use that activation mechanism. Generic `.venv`, `venv`, `.env`, and `env`
  directory names display their parent project name instead.
- `conda:name` for an active Conda environment (`CONDA_PREFIX`), including base.
  A venv layered over Conda shows both labels.
- `nix:pure` or `nix:impure` when `IN_NIX_SHELL` is set.

These indicators describe the shell's activated environment, not every runtime
installed or selected by a version manager. Running an environment's Python by
absolute path or using a one-off command such as `uv run` does not activate the
parent shell. No environment manager or interpreter is run to build the labels.
The prompt disables venv/Conda's own prompt prefixes to avoid duplicates.

Prompt checks: `python3 -B -m unittest discover -s tests -v` (requires Zsh and Python 3).

Configuration loads shared settings, Linux and distro settings, the shared
prompt, then optional `~/.zshrc.local` overrides. Put machine-specific settings
there. Remove any old theme initialization from that local file when migrating;
the managed configuration no longer loads `~/.p10k.zsh` or Oh My Zsh. Existing
theme files and installed fonts are left on disk.

## Layout

- `install/`: distro installers and shared symlink setup.
- `zsh/`: shared shell behavior, native prompt, and distro integrations.
- `git/ignore`: global Git ignore rules.
- `bin/msvpn`: NetworkManager helper for the Mount Sinai VPN.
- `konsole/`: shared terminal profile and default-profile setting.
- `kde/`: portable window-management settings and shortcuts; see
  [KDE setup](kde/README.md) for the separate preview/apply workflow.
- `archive/macos/`: historical macOS files, no longer loaded or maintained.
