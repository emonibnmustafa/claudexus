#!/usr/bin/env bash
# Installs Foreman for the current user. Safe to run again. Nothing outside your home directory is touched.
set -euo pipefail
src="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

# Foreman lives at ~/.foreman (a link if you cloned it somewhere else).
if [ "$src" != "$(cd "$HOME/.foreman" 2>/dev/null && pwd -P || true)" ]; then ln -sfn "$src" "$HOME/.foreman"; fi
chmod +x "$src"/bin/* "$src"/install.sh "$src"/uninstall.sh 2>/dev/null || true

# Adds (or refreshes) a marked block in a file; leaves everything else in it alone.
put_block() { # file, text
  local f="$1" text="$2" tmp
  mkdir -p "$(dirname "$f")"; [ -L "$f" ] && rm "$f"; touch "$f"
  tmp=$(mktemp); awk '/<!-- foreman:begin -->/{skip=1} !skip{print} /<!-- foreman:end -->/{skip=0}' "$f" > "$tmp"
  { cat "$tmp"; printf '<!-- foreman:begin -->\n%s\n<!-- foreman:end -->\n' "$text"; } > "$f"; rm -f "$tmp"
}
put_block "$HOME/.claude/CLAUDE.md" '## Foreman (Claude + Codex team)
@~/.foreman/protocol.md'
put_block "$HOME/.codex/AGENTS.md" '## Foreman (Claude + Codex team)
Follow the protocol in ~/.foreman/protocol.md: read it at the start of every session.'

for d in "$HOME/.claude/skills" "$HOME/.codex/skills"; do mkdir -p "$d"; ln -sfn "$src/skills/foreman" "$d/foreman"; done

# `foreman` on PATH.
line='export PATH="$HOME/.foreman/bin:$PATH"'
for rc in "$HOME/.zshrc" "$HOME/.bashrc"; do
  if [ -f "$rc" ] || [ "$rc" = "$HOME/.zshrc" ]; then grep -qxF "$line" "$rc" 2>/dev/null || echo "$line" >> "$rc"; fi
done

echo "Foreman installed."
echo "  1. Open a new terminal, or run: export PATH=\"\$HOME/.foreman/bin:\$PATH\""
echo "  2. Check: foreman doctor"
echo "  3. In any project, open Claude Code and type: /foreman"
