# Minerva: user-only installation and updates

Run these commands on Minerva, using your existing SSH login and site-provided
Bash environment. Nothing runs with sudo or changes your account's login shell.

## First installation

```sh
git clone https://github.com/amberuhls/dotfiles.git ~/.dotfiles
module spider miniforge3
module load miniforge3
bash ~/.dotfiles/install/minerva.sh
~/.local/bin/minerva-zsh
```

If a clone already exists, use `git -C ~/.dotfiles pull --ff-only` instead of
cloning. If the module has no default version, load an available version reported
by `module spider miniforge3`. Minerva's documentation currently gives
`miniforge3/26.1.1-3` as an example. Run the installer from a fresh login shell
without an active research Conda environment.

The installer uses the loaded Conda executable but installs only into
`~/.local/share/dotfiles/minerva/env`. It uses conda-forge exclusively and never
updates the site Miniforge installation. It installs Zsh, Git, bat, btop, eza,
fd, fzf, micro, ripgrep, and zoxide, plus user-owned clones of the two Zsh plugins.
Packages and plugin checkouts update when you rerun it; versions are not locked.

Minerva documents a 30 GB home quota. The CLI environment stays in your home;
to put its package download cache in your allocated work storage, set an actual
user-owned path before running the installer, for example:

```sh
export CONDA_PKGS_DIRS=/path/to/your/work/dotfiles-conda-pkgs
```

Otherwise the cache uses `~/.cache/dotfiles/conda-pkgs`. The installer does not
edit `.condarc`. Installation requires access to conda-forge and GitHub from
Minerva; this has not been tested against the live cluster.

## Normal use

After logging in normally, run:

```sh
~/.local/bin/minerva-zsh
```

This starts an interactive Zsh with the shared prompt and CLI tools. `exit`
returns to the original shell. No `chsh`, `conda init`, automatic environment
activation, or edits to `.bashrc`/`.bash_profile` are needed. Existing `.zshrc`
files are backed up by the common symlink installer; `.zshrc.local` remains the
place for machine-specific overrides.

Only the selected CLI executables enter PATH, not the entire Conda environment's
`bin` directory. Research Python, compilers, and libraries are not activated by
this setup. Lmod's Zsh initialization is loaded when its inherited `LMOD_DIR`
provides the standard init script; verify `module list` after switching shells.
If it is unavailable, use the original Bash shell for module operations until
the site's Zsh initialization path is configured in `.zshrc.local`.

Keep job scripts' existing shebangs and environment setup. Do not launch this
interactive shell from batch jobs. No KDE, Konsole, font, or VPN configuration
is installed on the cluster; your local Konsole profile controls SSH appearance.

## Synchronizing changes

Commit and push shared configuration from the development checkout, then on
Minerva (from the original Bash login shell):

```sh
git -C ~/.dotfiles pull --ff-only
module load miniforge3
bash ~/.dotfiles/install/minerva.sh
~/.local/bin/minerva-zsh
```

For configuration-only updates, pulling and starting a fresh `minerva-zsh` is
enough. Rerun the installer to update packages, plugins, or installed links.
Git synchronizes tracked configuration only; local secrets, research data,
histories, and `.zshrc.local` are not transferred.

Sources: [Minerva Conda guidance](https://labs.icahn.mssm.edu/minervalab/documentation/conda/)
and [Minerva Lmod guidance](https://labs.icahn.mssm.edu/minervalab/documentation/software-environment-lmod/).
