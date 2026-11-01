#!/usr/bin/env python3
"""Reads and (carefully) updates Codex's local state for Foreman. Standard library only.

Uses Codex internals (its SQLite thread index and session logs), which may change between Codex versions.
Everything that writes makes a backup first.
"""
import glob, json, os, shutil, sqlite3, sys, time, datetime

HOME = os.path.expanduser("~")
CODEX = os.path.join(HOME, ".codex")

def db_path():
    files = sorted(glob.glob(os.path.join(CODEX, "state_*.sqlite")), key=os.path.getmtime)
    if not files:
        sys.exit("foreman: no Codex state database found in ~/.codex (is Codex installed and used once?)")
    return files[-1]

def connect(write=False):
    path = db_path()
    if write:
        backups = os.path.join(HOME, ".config", "foreman", "backups")
        os.makedirs(backups, exist_ok=True)
        shutil.copy2(path, os.path.join(backups, "%s.%d" % (os.path.basename(path), int(time.time()))))
    return sqlite3.connect(path, timeout=10)

def rollout(thread):
    row = connect().execute("select rollout_path from threads where id=?", (thread,)).fetchone()
    if not row:
        sys.exit("foreman: Codex thread %s not found" % thread)
    return row[0]

def policy(repo):
    """Read-only everywhere, write access to the repo and temp dirs, no network."""
    return json.dumps({"type": "managed", "file_system": {"type": "restricted", "entries": [
        {"path": {"type": "special", "value": {"kind": "root"}}, "access": "read"},
        {"path": {"type": "path", "path": repo}, "access": "write"},
        {"path": {"type": "special", "value": {"kind": "slash_tmp"}}, "access": "write"},
        {"path": {"type": "special", "value": {"kind": "tmpdir"}}, "access": "write"}]}, "network": "restricted"})

def events(log):
    with open(log) as f:
        for line in f:
            try:
                yield json.loads(line)
            except ValueError:
                pass

def main():
    cmd, args = sys.argv[1], sys.argv[2:]
    if cmd == "log":
        print(rollout(args[0]))
    elif cmd == "effort":
        db = connect(True); db.execute("update threads set reasoning_effort=? where id=?", (args[1], args[0])); db.commit()
    elif cmd == "link":
        repo = os.path.realpath(args[0])
        db = connect()
        row = db.execute("select id, name from threads where cwd=? and archived=0 and originator='Codex Desktop' "
                         "and (name like 'Foreman%' or preview like 'Foreman%' or name like 'Claude%Codex%') order by created_at_ms desc limit 1", (repo,)).fetchone()
        if not row:
            sys.exit(1)
        db = connect(True)
        db.execute("update threads set sandbox_policy=?, approval_mode='never' where id=?", (policy(repo), row[0])); db.commit()
        print("%s|%s" % row)
    elif cmd == "done-count":
        print(sum(1 for e in events(args[0]) if e.get("payload", {}).get("type") == "task_complete"))
    elif cmd == "last-message":
        msgs = [e["payload"].get("last_agent_message") or "" for e in events(args[0]) if e.get("payload", {}).get("type") == "task_complete"]
        print(msgs[-1] if msgs else "")
    elif cmd == "usage":
        logs = sorted(glob.glob(os.path.join(CODEX, "sessions", "*", "*", "*", "*.jsonl")), key=os.path.getmtime)
        limits = None
        for log in reversed(logs[-5:]):
            for e in events(log):
                if e.get("payload", {}).get("type") == "token_count" and e["payload"].get("rate_limits"):
                    limits = e["payload"]["rate_limits"]
            if limits:
                break
        if not limits:
            sys.exit("foreman: no Codex usage data yet (run a Codex task first)")
        for key, label in (("primary", "5-hour"), ("secondary", "weekly")):
            w = limits.get(key) or {}
            when = datetime.datetime.fromtimestamp(w.get("resets_at", 0)).strftime("%a %H:%M")
            print("codex %s: %s%% used, resets %s" % (label, w.get("used_percent"), when))
    else:
        sys.exit("unknown command " + cmd)

main()
