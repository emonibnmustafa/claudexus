#!/usr/bin/env bash
# Removes what install.sh added. Your projects' files (AGENTS.md, docs/continuity) are left alone.
set -euo pipefail
strip() { [ -f "$1" ] && { t=$(mktemp); awk '/<!-- claudexus:begin -->/{skip=1} !skip{print} /<!-- claudexus:end -->/{skip=0}' "$1" > "$t"; cat "$t" > "$1"; rm -f "$t"; } || true; }
strip "$HOME/.claude/CLAUDE.md"; strip "$HOME/.codex/AGENTS.md"
unlink "$HOME/.claude/skills/claudexus" 2>/dev/null || true; unlink "$HOME/.codex/skills/claudexus" 2>/dev/null || true
echo "Removed the global rules and skills. Delete ~/.claudexus and the PATH line in ~/.zshrc/~/.bashrc yourself if you want it gone."
