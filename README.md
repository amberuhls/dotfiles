# Dotfiles

Shared Zsh configuration for Fedora, Ubuntu, and CachyOS. Clone this repository
to `~/.dotfiles` on each computer, then run the matching installer:

```sh
bash ~/.dotfiles/install/fedora.sh
# or: bash ~/.dotfiles/install/ubuntu.sh
# or: bash ~/.dotfiles/install/cachyos.sh
```

Installers install CLI tools and Zsh plugins, back up existing non-symlink
configuration, and link the shared files. They print instructions for changing
your default shell when needed. Start a fresh shell with `exec zsh` afterward.

`~/Code/dotfiles` is a development checkout; runtime configuration deliberately
loads from `~/.dotfiles`. Changes in a development checkout must be transferred
to the deployment checkout before they affect your shell.

## Shell appearance

The shared native Zsh prompt uses terminal colors and plain ASCII. No theme
framework, Powerlevel10k, icons, or Nerd Font is required. The optional Konsole
baseline uses ordinary Noto Sans Mono and Breeze colors.

```text
~/Code/dotfiles git:(main)
> 
```

The directory is cyan, the Git branch is magenta, and the input marker is green.
Detached Git HEADs show a short commit ID. Failed commands add a red `exit:N`
beside the directory; root shells use a red `#` marker. The prompt avoids Git
working-tree scans to keep large repositories responsive.

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
