# KDE Plasma 6 baseline

This is a curated baseline taken from the current workstation, applied separately
from the CLI installers. It requires Plasma 6's `kreadconfig6` and
`kwriteconfig6`, Python 3, and `pgrep`. Install Konsole and the ordinary **Noto
Sans Mono** font through your distro before applying. Older Plasma 5 systems
are not supported by this installer.

Independent desktop switching per screen requires **Plasma 6.7+ on Wayland**.
Older installations can use the other settings but do not implement this option.

## Preview and apply

```sh
python3 ~/.dotfiles/install/kde.py
```

The preview lists the settings the installer will write without changing files.
From the development checkout, use `python3 install/kde.py`; this installer
reads its baseline relative to its own location.

Log out of Plasma, switch to a TTY (for example Ctrl+Alt+F3), log in as your
normal user, and run:

```sh
python3 ~/.dotfiles/install/kde.py --apply
```

Log back into Plasma afterward. The installer refuses to apply while KWin,
Plasma Shell, the global shortcut daemon, or Konsole is running, since those
processes can overwrite configuration changes on exit. Do not run it with sudo.

Only the listed keys are merged using KDE's configuration tools. Other settings
are preserved, and existing files are copied to a unique backup directory under
`~/.local/state/dotfiles/kde-backups/` before any settings are written. XDG config,
data, and state directory overrides are supported. Existing symlink targets are
rejected to avoid changing another dotfiles checkout accidentally.

Each backup has a `manifest.json` mapping original paths to saved files. To undo
an application, log out again and copy each saved file back to its target;
remove targets whose backup is `null` (they did not exist before installation).
If an apply fails partway through, the same backup can restore the prior state.

## Window management

- Six virtual desktops in one row; desktop slide animation disabled.
- Each screen selects its current desktop independently from the shared set of
  six. Switching one screen's desktop leaves the others on their chosen desktop.
- Alt+Tab includes all screens, desktops, and activities. Meta+Tab includes only
  windows on the current screen, desktop, and activity. Both include minimized
  windows and all applications; Shift reverses cycling with the same filters.
- Alt+Tab shows the thumbnail-grid switcher with window highlighting and cycles
  in most-recently-used order. These were implicit defaults on the source
  workstation and are now explicit so other machines use the same presentation.
- Meta+Tab switches directly with no switcher overlay and no window-highlighting
  effect, in stacking order. These preserve the workstation's explicit
  `ShowTabBox=false`, `HighlightWindows=false`, and `SwitchingMode=1` settings.
- Desktop and monitor UUIDs, per-monitor tiles, display scaling, and Night Light
  stay machine-specific. Fresh desktops receive IDs from KWin.

`kglobalshortcutsrc` preserves the selected workstation bindings, including
alternate bindings. The main ones are:

| Action | Shortcut |
| --- | --- |
| Focus window above / left / below / right | Meta+Up/Left/Down/Right or Meta+I/J/K/L |
| Tile window above / left / below / right | Meta+Shift+Up/Left/Down/Right or Meta+Shift+I/J/K/L |
| Switch desktop | Meta+1 through Meta+6 |
| Send window to desktop | Meta+Shift+F1 through Meta+Shift+F6; existing shifted-number bindings also retained |
| Focus screen by number | Meta+Ctrl+1 through Meta+Ctrl+6 |
| Focus adjacent screen | Meta+Ctrl+arrow or Meta+Ctrl+I/J/K/L |
| Move window to adjacent screen | Meta+Ctrl+Shift+arrow or Meta+Ctrl+Shift+I/J/K/L |
| Maximize | Meta+F, Meta+Shift+F, or Meta+PgUp |
| Minimize | Meta+Shift+C or Meta+PgDown |
| Restore | Meta+Backspace |
| Universal window switcher | Alt+Tab |
| Current screen and desktop window switcher | Meta+Tab |
| Overview / desktop grid / tile editor | Meta+W / Meta+G / Meta+T |

Meta+1–6 task-manager launch bindings are disabled to free those keys for virtual
desktops. The lock-session binding is preserved as `Screensaver`, freeing Meta+L
for window focus. Next/previous-screen bindings are disabled so they do not
compete with Meta+Shift+Left/Right tiling. Adjacent-desktop bindings are disabled
to free Meta+Ctrl directions for screens; numbered desktop shortcuts remain.
Screen directions follow the monitor arrangement in Display Configuration, so
no monitor IDs are needed. Meta+Ctrl+1–6 selects KWin screen indices 0–5;
these indices follow KWin output ordering and are not stable monitor identities
across computers or hotplug changes. Adding Shift moves the window to that screen; it does
not select a particular tile there. Other applications' shortcuts are
preserved; inspect System Settings → Keyboard → Shortcuts for conflicts with
additional bindings you have assigned on a particular machine.

## Konsole

The `Dotfiles` profile becomes the default and uses Breeze colors, ordinary Noto
Sans Mono at 10 points, and 10,000 lines of scrollback. It inherits the default
shell, so make Zsh your login shell using the CLI installer's instructions.
Ensure the named font is installed on every machine for matching typography;
otherwise Qt substitutes another font. No Nerd Font is required.

The profile is merged into the user data directory as a regular file. GUI edits
remain local until you update the repository baseline; reapplying restores
managed values. Other profiles, including `amber.profile`, are preserved.

KDE references: [Konsole profiles](https://docs.kde.org/trunk_kf6/en/konsole/konsole/profiles.html)
and [KConfig](https://develop.kde.org/docs/features/configuration/introduction/).
Per-screen desktops were introduced in
[Plasma 6.7](https://blogs.kde.org/2026/04/18/this-week-in-plasma-per-screen-virtual-desktops-and-wayland-session-restore/).
