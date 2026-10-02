import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]


class ShellQualityTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.home = Path(self.temp.name)
        (self.home / ".dotfiles").symlink_to(ROOT)
        self.bin = self.home / "package/bin"
        self.bin.mkdir(parents=True)
        self.env = {
            "HOME": str(self.home), "PATH": f"{self.bin}:{os.defpath}",
            "TERM": "xterm-256color", "LC_ALL": "C.UTF-8",
        }
        self.stub("fzf", "exit 0")
        self.stub("eza", "exit 0")
        self.stub("zoxide", "exit 0")

    def stub(self, name, code):
        path = self.bin / name
        path.write_text("#!/bin/sh\n" + code + "\n")
        path.chmod(0o755)

    def zsh(self, code, source="common", interactive=False):
        result = subprocess.run(
            ["zsh", "-f", *(["-i"] if interactive else []), "-c",
             f'source "$HOME/.dotfiles/zsh/{source}.zsh"\n' + code],
            env=self.env, cwd=self.home, capture_output=True, text=True,
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        return result.stdout

    def test_reload_deduplicates_path_and_disables_icons(self):
        self.zsh('''
source "$HOME/.dotfiles/zsh/common.zsh"
[[ ${(M)#path:#$HOME/.local/bin} == 1 ]] || exit 1
[[ ${(M)#path:#$HOME/go/bin} == 1 ]] || exit 2
for name in ls ll la l tree; do
  [[ ${aliases[$name]} == *--icons=never* ]] || exit 3
done
''')

    def test_serve_binds_loopback_and_allows_explicit_network_address(self):
        output = self.zsh('''
python3() { print -rl -- "$@"; }
serve
serve 9000 0.0.0.0
''')
        self.assertIn("http.server\n8000\n--bind\n127.0.0.1", output)
        self.assertIn("http.server\n9000\n--bind\n0.0.0.0", output)

    def test_timestamped_history_without_live_sharing(self):
        self.zsh('''
[[ -o extendedhistory && -o incappendhistory && ! -o sharehistory ]] || exit 1
[[ $aliases[ht] == 'fc -li' && $aliases[h] == history ]] || exit 2
print -s -- 'echo synthetic-history-entry'
fc -W "$HISTFILE"
''', interactive=True)
        history = (self.home / ".zsh_history").read_text()
        self.assertRegex(history, r": \d+:\d+;echo synthetic-history-entry")

    def test_serve_rejects_invalid_arguments_before_running_python(self):
        self.zsh('''
python3() { touch "$HOME/python-was-called"; }
for port in nope 0 65536; do
  serve "$port" 2>/dev/null
  [[ $? == 2 ]] || exit 1
done
serve 8000 127.0.0.1 extra 2>/dev/null
[[ $? == 2 && ! -e "$HOME/python-was-called" ]] || exit 2
''')

    def test_modern_fzf_runs_once_and_skips_legacy(self):
        self.stub("fzf", '''echo call >> "$HOME/fzf-calls"
echo 'typeset -g fzf_test=modern' ''')
        directory = self.home / "package/share/fzf"
        directory.mkdir(parents=True)
        (directory / "key-bindings.zsh").write_text("exit 99\n")
        self.zsh('[[ $fzf_test == modern ]]', source="fzf")
        self.assertEqual((self.home / "fzf-calls").read_text(), "call\n")

    def test_legacy_fzf_package_layouts(self):
        self.stub("fzf", "exit 2")
        for layout in ("share/fzf", "share/fzf/shell", "share/doc/fzf/examples"):
            with self.subTest(layout=layout):
                directory = self.home / "package" / layout
                directory.mkdir(parents=True, exist_ok=True)
                (directory / "key-bindings.zsh").write_text("typeset -g test_keys=yes\n")
                (directory / "completion.zsh").write_text("typeset -g test_completion=yes\n")
                self.zsh('[[ $test_keys == yes && $test_completion == yes ]]', source="fzf")
                (directory / "key-bindings.zsh").unlink()
                (directory / "completion.zsh").unlink()

    def test_doctor_reports_wrong_links_without_modifying_them(self):
        local_bin = self.home / ".local/bin"
        local_bin.mkdir(parents=True)
        (local_bin / "dotfiles").symlink_to(ROOT / "bin/dotfiles")
        # Use only synthetic tool executables, without desktop detection.
        for name in ("zsh", "git", "micro", "less", "btop", "rg", "batcat", "fdfind"):
            self.stub(name, "exit 0")
        target = self.home / ".zshrc"
        target.symlink_to(self.home / "missing-zshrc")
        before = sorted(str(p.relative_to(self.home)) for p in self.home.rglob("*"))
        result = subprocess.run(
            [shutil.which("bash"), str(ROOT / "bin/dotfiles"), "doctor"],
            env={**self.env, "PATH": str(self.bin)},
            cwd=self.home, capture_output=True, text=True,
        )
        self.assertEqual(result.returncode, 1, result.stderr)
        self.assertIn("should link to", result.stdout)
        self.assertIn("batcat available", result.stdout)
        self.assertIn("fdfind available", result.stdout)
        self.assertIn("KDE checks skipped", result.stdout)
        self.assertEqual(target.readlink(), self.home / "missing-zshrc")
        self.assertEqual(before, sorted(str(p.relative_to(self.home)) for p in self.home.rglob("*")))


if __name__ == "__main__":
    unittest.main()
