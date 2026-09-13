#!/usr/bin/env python3
"""Preview or merge the curated Plasma 6 / Konsole baseline using KConfig."""

import argparse
import configparser
import os
from pathlib import Path
import shutil
import subprocess
import tempfile


ROOT = Path(__file__).resolve().parents[1]


def entries(source):
    parser = configparser.ConfigParser(interpolation=None)
    parser.optionxform = str
    parser.read(source)
    for group in parser.sections():
        for key in parser[group]:
            # KConfig handles escaped tabs in shortcut lists, not ConfigParser.
            value = subprocess.check_output(
                ["kreadconfig6", "--file", str(source), "--group", group,
                 "--key", key], text=True
            ).removesuffix("\n")
            yield group, key, value


def session_running():
    result = subprocess.run(
        ["pgrep", "-u", str(os.getuid()), "-x",
         "kwin_wayland|kwin_x11|plasmashell|kglobalacceld|konsole"],
        capture_output=True, text=True
    )
    if result.returncode not in (0, 1):
        raise RuntimeError("Unable to check for running KDE applications")
    return result.returncode == 0


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--apply", action="store_true",
                        help="write settings; log out of Plasma and run from a TTY")
    args = parser.parse_args()
    print("Independent per-screen desktops require Plasma 6.7+ on Wayland.")
    for tool in ("kreadconfig6", "kwriteconfig6", "pgrep"):
        if not shutil.which(tool):
            parser.error(f"Required command not found: {tool} (Plasma 6 required)")

    config = Path(os.environ.get("XDG_CONFIG_HOME") or Path.home() / ".config")
    data = Path(os.environ.get("XDG_DATA_HOME") or Path.home() / ".local/share")
    state = Path(os.environ.get("XDG_STATE_HOME") or Path.home() / ".local/state")
    if not all(path.is_absolute() for path in (config, data, state)):
        parser.error("XDG directories must be absolute paths")

    sources = [
        (ROOT / "konsole/Dotfiles.profile", data / "konsole/Dotfiles.profile"),
        (ROOT / "konsole/konsolerc", config / "konsolerc"),
        (ROOT / "kde/kwinrc", config / "kwinrc"),
        (ROOT / "kde/kglobalshortcutsrc", config / "kglobalshortcutsrc"),
    ]
    changes = [(target, list(entries(source))) for source, target in sources]
    for target, settings in changes:
        print(target)
        for group, key, value in settings:
            print(f"  [{group}] {key} = {value!r}")

    if not args.apply:
        print("\nPreview only. Log out of Plasma, then run with --apply from a TTY.")
        return
    if session_running():
        parser.error("Close Konsole and log out of Plasma before applying from a TTY.")
    for target, _ in changes:
        if target.is_symlink() or (target.exists() and not target.is_file()):
            parser.error(f"Expected a regular file or absent path: {target}")

    backup_root = state / "dotfiles/kde-backups"
    backup_root.mkdir(parents=True, exist_ok=True)
    backup = Path(tempfile.mkdtemp(prefix="apply-", dir=backup_root))
    # Back up every destination before the first write, including a record of
    # absent files so a first installation can also be undone.
    restore = []
    for index, (target, _) in enumerate(changes):
        saved = backup / str(index)
        if target.exists():
            shutil.copy2(target, saved)
        restore.append({"target": str(target), "backup": str(saved) if saved.exists() else None})
    import json
    (backup / "manifest.json").write_text(json.dumps(restore, indent=2) + "\n")
    print(f"\nBackup: {backup}", flush=True)

    for target, settings in changes:
        target.parent.mkdir(parents=True, exist_ok=True)
        for group, key, value in settings:
            subprocess.run(
                ["kwriteconfig6", "--file", str(target), "--group", group,
                 "--key", key, "--", value], check=True
            )
    print("Applied. Log in to Plasma to load the settings.")


if __name__ == "__main__":
    main()
