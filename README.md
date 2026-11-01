# Claudexus

**Claude runs the crew. Codex does the work.**

*Claudexus = Claude + Codex + nexus: the hub that connects them.*

You pay for Claude *and* Codex, but you still babysit both. Claudexus turns them into one engineering team: **Claude Code is the lead** who plans, delegates and reviews; **Codex is the engineer** who builds. They share one project memory, watch each other's usage limits, and hand work over cleanly when a limit runs out. You give a goal and come back to finished work.

```
you ──goal──▶ Claude (lead) ──brief──▶ Codex (engineer, own git worktree)
                 ▲  review, run, merge ◀──report──┘
                 └─ shared memory: AGENTS.md · CURRENT.md · TASKS.md · DECISIONS.md
```

## Why it's different

- **You can watch it.** Every task Claude hands over shows up in a Codex chat you can open. Claude writes the same exchange in your chat: `Claude → Codex` / `Codex → Claude` / `Decision`.
- **Hands-free, not reckless.** The pair decides and keeps going. They only stop to ask before a push to `main`, going live, deleting data, or spending money.
- **Usage-aware.** The lead checks both usage limits before delegating: more work to Codex when Claude is running low, smaller or cheaper tasks when Codex is.
- **Nothing gets lost when a limit hits.** At 95% usage the active agent writes one complete handoff. The other one picks up exactly where it stopped, from files and `git`, not from chat memory.
- **No collisions.** Each task gets its own `git worktree` and branch (`agent/<task>`). The lead reviews the diff and the real output before merging.
- **Gets smarter.** After each task the pair records lessons that feed the next one.
- **Plain files, no service.** Markdown, shell and a little Python. No server, no account, no telemetry.

## Install (about a minute)

**Ask Claude to do it.** Paste this into Claude Code:

> Install Claudexus: run `git clone --depth 1 https://github.com/emonibnmustafa/claudexus ~/.claudexus && ~/.claudexus/install.sh`, then run `claudexus doctor` and tell me the result.

**Or by hand:**

```sh
git clone --depth 1 https://github.com/emonibnmustafa/claudexus ~/.claudexus
~/.claudexus/install.sh
claudexus doctor
```

You need: `git`, `python3`, [Claude Code](https://claude.com/claude-code), and [Codex](https://developers.openai.com/codex) (desktop app recommended). Claudexus auto-detects the Codex CLI; see [Configuration](#configuration) to change that.

## Use it

In any project, open Claude Code and type:

```
/claudexus
```

Claude sets the project up (`AGENTS.md` filled in from your actual code, shared memory in `docs/continuity/`), then asks you for one thing: **create a chat in the Codex app inside that project** with the message it gives you, and say "done". After that, hand Claude a goal and walk away.

Codex can run it too: `$claudexus`.

## What's in your repo afterwards

| File | Purpose |
|---|---|
| `AGENTS.md` | Permanent project rules: code map, conventions, build/test commands. Read by both agents (`CLAUDE.md` just imports it). |
| `docs/continuity/CURRENT.md` | Where work stands right now; rewritten at handoff. |
| `docs/continuity/TASKS.md` | The shared task board: owner and status of every task. |
| `docs/continuity/DECISIONS.md` | Lasting decisions and why, including the ones the agents made while you were away. |
| `docs/continuity/JOURNAL.md` | Append-only log of who did what. |
| `docs/continuity/tasks/` | Every brief and Codex's report, for audit. |

## Commands

| Command | Does |
|---|---|
| `claudexus init` | Adds the structure to the current repo. Never overwrites a file. |
| `claudexus link` | Connects the Codex-app chat you created to this repo. |
| `claudexus task [--agent opencode] <id> <brief.md> [medium\|high\|xhigh]` | Gives Codex (or OpenCode) a task in `.worktrees/<id>`, waits, saves its report. |
| `claudexus usage` | Codex 5-hour and weekly usage and reset times. |
| `claudexus doctor` | Checks that everything is installed. |

## How the handoff works

Nobody can write a note *after* a usage limit cuts them off, so the protocol writes it *before*: at 95% the agent records your request word for word, the plan with each step's status (`planned → in progress → implemented → verified`), the exact next action, decisions and reasons, the changed and untracked files, and what was verified on which commit. The next agent starts by reading that file, then `git status`/`git diff`, trusts the code over the notes, and says in one line where it resumes. If a limit hit before the note could be written, the protocol points it at the other agent's session transcript.

## Configuration

Optional, in `~/.config/claudexus/config.sh`:

```sh
CLAUDEXUS_CODEX=/path/to/codex            # which Codex CLI to drive
CLAUDEXUS_CODEX_MODEL=your-model-name     # default: the model in ~/.codex/config.toml
```

`CLAUDEXUS_OPENCODE` and `CLAUDEXUS_OPENCODE_MODEL` (for example a free DeepSeek model) enable OpenCode as a second engineer.

Personal preferences (reply language, tone, house rules) go in `~/.config/claudexus/owner.md`; both agents read it. Your own lessons accumulate in `~/.config/claudexus/LESSONS.md`.

## Honest limits

- **Early and experimental.** Built and used daily on macOS with the Codex desktop app. Linux works with the Codex CLI (tasks run headless, without a chat to watch). Windows is untested.
- **Relies on Codex internals.** Linking a chat and reading usage use Codex's local index and session logs, which can change between Codex versions. `claudexus link` backs the index up first (`~/.config/claudexus/backups`). If something breaks, open an issue with your `claudexus doctor` output.
- **Claude can't switch its own model mid-session.** It shifts load to cheaper subagents and Codex instead.
- **Not affiliated** with Anthropic or OpenAI. Claude and Codex are their products and subject to their terms and plan limits.

## Uninstall

`~/.claudexus/uninstall.sh` removes the global rules and skills. Your projects' files stay.

## Contributing

Lessons learned running this for real are the most valuable contribution: open a pull request against `protocol.md` with what you changed and why. `bash test/smoke.sh` must pass.

## License

MIT
