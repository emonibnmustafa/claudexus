#!/usr/bin/env bash
# Shared helpers, sourced by the claudexus-* commands.
CLAUDEXUS_HOME="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
# Per-user overrides (CLAUDEXUS_CODEX, CLAUDEXUS_CODEX_MODEL, …). Never part of the repo.
[ -f "$HOME/.config/claudexus/config.sh" ] && . "$HOME/.config/claudexus/config.sh"

# The Codex CLI to drive. The CLI bundled in the ChatGPT/Codex desktop app is preferred: it supports the
# models of your logged-in account, while an older standalone install may not.
claudexus_codex() {
  if [ -n "${CLAUDEXUS_CODEX:-}" ]; then echo "$CLAUDEXUS_CODEX"; return; fi
  local c
  for c in /Applications/ChatGPT.app/Contents/Resources/codex-cli/bin/codex \
           "$HOME/Applications/ChatGPT.app/Contents/Resources/codex-cli/bin/codex" \
           /Volumes/*/Applications/ChatGPT.app/Contents/Resources/codex-cli/bin/codex \
           /Applications/Codex.app/Contents/Resources/codex-cli/bin/codex; do
    if [ -x "$c" ]; then echo "$c"; return; fi
  done
  command -v codex || true
}

# Model for Codex: CLAUDEXUS_CODEX_MODEL, else the one in ~/.codex/config.toml, else Codex's own default.
claudexus_model() {
  if [ -n "${CLAUDEXUS_CODEX_MODEL:-}" ]; then echo "$CLAUDEXUS_CODEX_MODEL"; return; fi
  sed -n 's/^model *= *"\(.*\)".*/\1/p' "$HOME/.codex/config.toml" 2>/dev/null | head -1
}

claudexus_repo() { git rev-parse --show-toplevel 2>/dev/null || { echo "claudexus: run this inside a git repository" >&2; return 1; }; }
