---
name: claudexus
description: Set up or resume Claudexus in the current project — Claude Code leads and Codex does the work through a shared Codex-app chat, with shared project records, usage-aware delegation and a handoff at 95% usage. Use when the user types /claudexus or $claudexus, or says "set up claudexus", "start the team", "get Codex working with you", or opens a project that has no AGENTS.md.
---

# /claudexus — Claude leads, Codex works

Follow `~/.claudexus/protocol.md` (loaded globally). Steps:

1. **Already set up?** If `AGENTS.md` and `docs/continuity/CURRENT.md` exist: read them and the latest `JOURNAL.md` entries, run `git status`, `git log`, `git diff`, and tell the user in one line where work resumes. If `.team/codex-thread-id` is missing, go to step 3.
2. **New project:** run `claudexus init`. Read the codebase and fill every section of `AGENTS.md` with real facts: product, code map, conventions with example files, exact build/test/run commands, the owner's rules. Ask only for what the code can't tell you.
3. **Link Codex:** tell the user, in one short message: "In the Codex app, open this project and start a new chat with exactly: `Claudexus ↔ Codex · <project> — shared work log. Reply "ready" only.` Then tell me when it answered." Then run `claudexus link` and send a one-line read-only ping through `claudexus task` to confirm the reply arrives. No Codex app? Skip the chat: `claudexus task` runs Codex headless.
4. **Goal:** write the user's goal verbatim into `CURRENT.md`, split it into tasks on `TASKS.md`, commit on `agent/setup`, and start. Check both usage limits first (`/usage`, `claudexus usage`).
5. **Report:** what is set up, what is linked, the first tasks and who has them.

If you are **Codex** running this skill: do steps 1, 2 and 4. For step 3 tell the user that Claude links the chat, then wait for tasks.
