#!/usr/bin/env bash
# Installs Claudexus for the current user. Safe to run again. Nothing outside your home directory is touched.
set -euo pipefail
src="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

# Claudexus lives at ~/.claudexus (a link if you cloned it somewhere else).
if [ "$src" != "$(cd "$HOME/.claudexus" 2>/dev/null && pwd -P || true)" ]; then ln -sfn "$src" "$HOME/.claudexus"; fi
chmod +x "$src"/bin/* "$src"/install.sh "$src"/uninstall.sh 2>/dev/null || true

# Adds (or refreshes) a marked block in a file; leaves everything else in it alone.
put_block() { # file, text
  local f="$1" text="$2" tmp
  mkdir -p "$(dirname "$f")"; [ -L "$f" ] && rm "$f"; touch "$f"
  tmp=$(mktemp); awk '/<!-- claudexus:begin -->/{skip=1} !skip{print} /<!-- claudexus:end -->/{skip=0}' "$f" > "$tmp"
  { cat "$tmp"; printf '<!-- claudexus:begin -->\n%s\n<!-- claudexus:end -->\n' "$text"; } > "$f"; rm -f "$tmp"
}
put_block "$HOME/.claude/CLAUDE.md" '## Claudexus (Claude + Codex team)
@~/.claudexus/protocol.md'
put_block "$HOME/.codex/AGENTS.md" '## Claudexus (Claude + Codex team)
Follow the protocol in ~/.claudexus/protocol.md: read it at the start of every session.'

for d in "$HOME/.claude/skills" "$HOME/.codex/skills"; do mkdir -p "$d"; ln -sfn "$src/skills/claudexus" "$d/claudexus"; done

# `claudexus` on PATH.
line='export PATH="$HOME/.claudexus/bin:$PATH"'
for rc in "$HOME/.zshrc" "$HOME/.bashrc"; do
  if [ -f "$rc" ] || [ "$rc" = "$HOME/.zshrc" ]; then grep -qxF "$line" "$rc" 2>/dev/null || echo "$line" >> "$rc"; fi
done

echo "Claudexus installed."
echo "  1. Open a new terminal, or run: export PATH=\"\$HOME/.claudexus/bin:\$PATH\""
echo "  2. Check: claudexus doctor"
echo "  3. In any project, open Claude Code and type: /claudexus"
