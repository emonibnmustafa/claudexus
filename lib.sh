#!/usr/bin/env bash
# Shared helpers, sourced by the foreman-* commands.
FOREMAN_HOME="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
# Per-user overrides (FOREMAN_CODEX, FOREMAN_CODEX_MODEL, …). Never part of the repo.
[ -f "$HOME/.config/foreman/config.sh" ] && . "$HOME/.config/foreman/config.sh"

# The Codex CLI to drive. The CLI bundled in the ChatGPT/Codex desktop app is preferred: it supports the
# models of your logged-in account, while an older standalone install may not.
foreman_codex() {
  if [ -n "${FOREMAN_CODEX:-}" ]; then echo "$FOREMAN_CODEX"; return; fi
  local c
  for c in /Applications/ChatGPT.app/Contents/Resources/codex-cli/bin/codex \
           "$HOME/Applications/ChatGPT.app/Contents/Resources/codex-cli/bin/codex" \
           /Volumes/*/Applications/ChatGPT.app/Contents/Resources/codex-cli/bin/codex \
           /Applications/Codex.app/Contents/Resources/codex-cli/bin/codex; do
    if [ -x "$c" ]; then echo "$c"; return; fi
  done
  command -v codex || true
}

# Model for Codex: FOREMAN_CODEX_MODEL, else the one in ~/.codex/config.toml, else Codex's own default.
foreman_model() {
  if [ -n "${FOREMAN_CODEX_MODEL:-}" ]; then echo "$FOREMAN_CODEX_MODEL"; return; fi
  sed -n 's/^model *= *"\(.*\)".*/\1/p' "$HOME/.codex/config.toml" 2>/dev/null | head -1
}

foreman_repo() { git rev-parse --show-toplevel 2>/dev/null || { echo "foreman: run this inside a git repository" >&2; return 1; }; }
