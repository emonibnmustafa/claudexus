#!/usr/bin/env bash
# Smoke test: init in a throwaway repo, check files, check it never overwrites.
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT; cd "$tmp"
git init -q . && git config user.email t@t && git config user.name t
"$root/bin/foreman-init" >/dev/null
for f in AGENTS.md CLAUDE.md docs/continuity/CURRENT.md docs/continuity/TASKS.md docs/continuity/DECISIONS.md docs/continuity/JOURNAL.md .gitignore; do
  [ -f "$f" ] || { echo "missing $f"; exit 1; }
done
grep -q "$(basename "$tmp")" AGENTS.md || { echo "project name not filled in"; exit 1; }
grep -qx ".worktrees/" .gitignore || { echo ".gitignore entry missing"; exit 1; }
echo "custom" > AGENTS.md
out=$("$root/bin/foreman-init"); echo "$out" | grep -q "kept   AGENTS.md" || { echo "did not report keeping AGENTS.md"; exit 1; }
[ "$(cat AGENTS.md)" = "custom" ] || { echo "overwrote AGENTS.md"; exit 1; }
out=$("$root/bin/foreman" help); echo "$out" | grep -q "foreman task" || { echo "help broken"; exit 1; }
bash -n "$root"/bin/foreman* "$root/install.sh" "$root/uninstall.sh"
PYTHONDONTWRITEBYTECODE=1 python3 -c "import ast,sys; ast.parse(open(sys.argv[1]).read())" "$root/bin/_codex_state.py"
echo "smoke test passed"
