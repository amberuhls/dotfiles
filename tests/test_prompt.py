import os
from pathlib import Path
import subprocess
import tempfile
import unittest


PROMPT_FILE = Path(__file__).resolve().parents[1] / "zsh/prompt.zsh"


class PromptTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.home = Path(self.temp.name)
        self.env = {
            "HOME": str(self.home),
            "PATH": os.defpath,
            "TERM": "xterm-256color",
            "PROMPT_FILE": str(PROMPT_FILE),
            "LC_ALL": "C.UTF-8",
        }

    def run_zsh(self, script, **variables):
        result = subprocess.run(
            ["zsh", "-f", "-c", 'source "$PROMPT_FILE"\n' + script],
            cwd=self.home, env={**self.env, **variables},
            capture_output=True, text=True,
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        return result.stdout

    def test_real_venv_activation_and_deactivation(self):
        venv = self.home / "demo-project" / ".venv"
        subprocess.run(
            ["python3", "-m", "venv", "--without-pip", str(venv)],
            check=True, env=self.env, capture_output=True,
        )
        output = self.run_zsh('''
source "$TEST_VENV/bin/activate"
false
dotfiles_precmd
print -r -- "$PROMPT"
cd /
true
dotfiles_precmd
print -r -- "$PROMPT"
deactivate
dotfiles_precmd
print -r -- "$PROMPT"
''', TEST_VENV=str(venv)).splitlines()
        self.assertIn("venv:demo-project", output[0])
        self.assertIn("✘ 1", output[0])
        self.assertIn("venv:demo-project", output[1])
        self.assertIn("✔", output[1])
        self.assertNotIn("venv:", output[2])
        self.assertTrue(all(line.startswith("%F{blue}") for line in output))

    def test_nested_and_named_environments(self):
        output = self.run_zsh('''
dotfiles_precmd
print -r -- "$PROMPT"
unset VIRTUAL_ENV CONDA_PREFIX CONDA_DEFAULT_ENV IN_NIX_SHELL
dotfiles_precmd
print -r -- "$PROMPT"
''', VIRTUAL_ENV="/synthetic/envs/analysis", CONDA_PREFIX="/synthetic/conda",
            CONDA_DEFAULT_ENV="base", IN_NIX_SHELL="impure").splitlines()
        self.assertIn("venv:analysis conda:base nix:impure", output[0])
        for label in ("venv:", "conda:", "nix:"):
            self.assertNotIn(label, output[1])

    def test_conda_path_and_fallback_name(self):
        for extra in ({}, {"CONDA_DEFAULT_ENV": "/synthetic/envs/stats"}):
            output = self.run_zsh('dotfiles_precmd; print -r -- "$PROMPT"',
                                  CONDA_PREFIX="/synthetic/envs/stats", **extra)
            self.assertIn("conda:stats", output)

    def test_environment_text_is_not_prompt_code(self):
        output = self.run_zsh('''
dotfiles_precmd
print -P -- "$PROMPT"
''', VIRTUAL_ENV="/synthetic/%F{red}$(touch PWNED)\n")
        self.assertIn("venv:%F{red}$(touch PWNED)", output)
        self.assertEqual(len(output.splitlines()), 1)
        self.assertFalse((self.home / "PWNED").exists())

    def test_reload_and_inactive_environment(self):
        output = self.run_zsh('''
source "$PROMPT_FILE"
[[ ${(M)#precmd_functions:#dotfiles_precmd} == 1 ]] || exit 1
[[ $VIRTUAL_ENV_DISABLE_PROMPT == 1 && $CONDA_CHANGEPS1 == false ]] || exit 2
dotfiles_precmd
print -r -- "$PROMPT"
''')
        self.assertEqual(len(output.splitlines()), 1)
        self.assertNotIn("venv:", output)
        self.assertNotIn("conda:", output)
        self.assertNotIn("nix:", output)


if __name__ == "__main__":
    unittest.main()
