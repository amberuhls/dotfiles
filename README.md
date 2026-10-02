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

Commands taking at least five seconds add a duration such as `12.3s`. This is
elapsed foreground command-line time, not CPU time or background-job duration.
Blank prompts do not accumulate idle time. Root's entire `user@hostname` label
is bold red. SSH sessions show `ssh`; Distrobox shows `box:name`, and other
recognized containers show `container` or `container:runtime`. Detection uses
environment variables and standard Docker/Podman marker files; it is a visual
cue, not a guarantee of isolation. No container commands run during prompting.

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

Shell checks: `python3 -B -m unittest discover -s tests -v` (requires Zsh and Python 3).

Configuration loads shared settings, Linux and distro settings, the shared
prompt, then optional `~/.zshrc.local` overrides. Put machine-specific settings
there. Remove any old theme initialization from that local file when migrating;
the managed configuration no longer loads `~/.p10k.zsh` or Oh My Zsh. Existing
theme files and installed fonts are left on disk.

## Shell utilities

History records timestamps for new commands. Use `ht` to list history with
dates and times; `h` keeps the existing plain listing. Commands are still saved
as they are entered, and running shells do not automatically import each
other's history. New shells can read previously saved commands. Existing
history is retained; older entries cannot acquire accurate timestamps retroactively.

`ls`, `ll`, `la`, `l`, and `tree` use eza without icons, including when
`EZA_ICONS_AUTO` is set elsewhere. Reloading the configuration keeps PATH entries
unique. fzf uses its built-in Zsh integration when available and falls back to
distro or installation-prefix scripts on older versions.

`serve` serves the current directory on loopback by default:

```sh
serve                       # 127.0.0.1:8000
serve 9000                  # 127.0.0.1:9000
serve 9000 0.0.0.0           # explicitly listen on all IPv4 interfaces
```

## Checking an installation

```sh
dotfiles doctor
```

The distro and Minerva installers link this command into `~/.local/bin`.
For an existing setup, rerun its installer after pulling, or run the checker
directly without reinstalling packages:

```sh
bash ~/.dotfiles/bin/dotfiles doctor
```

The checker reports incorrect or missing managed symlinks, missing CLI tools
(including Debian's `batcat`/`fdfind` alternatives), and plugin file availability.
On systems with a KDE session or KDE 6 tools, it also checks KDE utility commands,
the Konsole font and profile's existence, and per-screen desktop prerequisites.
It does not compare every KDE setting or verify that plugins are loaded into the
current shell. It changes no configuration and returns 1 if there are warnings,
0 otherwise. Run it inside `minerva-zsh` on Minerva or the CLI Distrobox on
SteamOS so it sees the tools you actually use.

## Layout

- `install/`: distro installers and shared symlink setup.
- `zsh/`: shared shell behavior, native prompt, and distro integrations.
- `git/ignore`: global Git ignore rules.
- `bin/msvpn`: NetworkManager helper for the Mount Sinai VPN.
- `bin/dotfiles`: read-only installation checks.
- `konsole/`: shared terminal profile and default-profile setting.
- `kde/`: portable window-management settings and shortcuts; see
  [KDE setup](kde/README.md) for the separate preview/apply workflow.
- `archive/macos/`: historical macOS files, no longer loaded or maintained.
