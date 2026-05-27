# Claude Developer Guide

## `claudet` — 4-Pane Claude Workspace

Running `claudet` opens a single iTerm2 window split into a 2×2 grid, each pane launching Claude Code:

```
┌─────────────────────┬─────────────────────┐
│  opus-4-7           │  opus-4-7           │
│  (Opus-High-1)      │  (Opus-High-2)      │
├─────────────────────┼─────────────────────┤
│  sonnet-4-6         │  sonnet-4-6         │
│  (Sonnet-1)         │  (Sonnet-2)         │
└─────────────────────┴─────────────────────┘
```

On macOS it uses iTerm2 AppleScript. On Linux/WSL/tmux-only environments it falls back to tmux via `docs/claude/tmux-claudet.sh`.

### Changing models

Edit the `claudet()` function in `shell.zsh`. There are 4 `--model` flags, one per pane.

| Model | ID | Context | Best for |
|-------|----|---------|----------|
| Opus 4.7 | `claude-opus-4-7` | 200k | Architecture, hard reasoning, complex tasks |
| Sonnet 4.6 | `claude-sonnet-4-6` | 200k | Everyday coding, reviews, balanced cost/quality |
| Haiku 4.5 | `claude-haiku-4-5` | 200k | Fast lookups, simple edits, high-volume tasks |

**Mix models across panes:**

```zsh
# s1/s2 → opus for hard problems
write text "cd ... && claude --model claude-opus-4-7 --name Opus-1"
# s3/s4 → sonnet for routine tasks
write text "cd ... && claude --model claude-sonnet-4-6 --name Sonnet-1"
```

### tmux fallback

The fallback script is at `docs/claude/tmux-claudet.sh`. Override models with env vars:

```zsh
P1_MODEL=claude-opus-4-7 P3_MODEL=claude-haiku-4-5 claudet
```

---

## Status Line

The status line renders inside Claude Code's bottom bar:

```
opus-4.7  │  main +wt:my-branch  │  [████████████░░░░░░░░] 61% (122k/200k)
```

- **Model slug** — derived from the active model's display name
- **Git segment** — current branch; appends `+wt:<name>` when inside a worktree
- **Context bar** — 20-character block bar showing % of context window used, with token counts

### How it works

`statusline.sh` is invoked by Claude Code on every assistant turn (via `~/.claude/settings.json`). It reads a cache file written by the background daemon:

1. `SessionStart` hook → `statusline-daemon.sh start` — spawns a background loop refreshing cache every 2s
2. `Stop` hook → `statusline-daemon.sh stop` — kills the daemon when the session ends
3. `statusline.sh` — reads cache if fresh (≤3s old); falls back to computing inline if stale

Cache files live in `~/.claude/`:

| File | Contents |
|------|----------|
| `.statusline.cache` | Last computed status line string |
| `.statusline.input` | Last JSON payload received from Claude Code |
| `.statusline.pid` | Daemon PID |

---

## `/tokens` — Token Usage Tracker

Shows how many tokens the current context window has consumed and logs per-session usage.

```
/tokens         # current window + recent session history (last 10)
/tokens reset   # clear the session history log
```

### How tokens are calculated

Claude Code reports token counts — this tool does **not** re-tokenize. On every assistant turn it passes a JSON payload with a `context_window` block:

| Field | Meaning |
|-------|---------|
| `total_input_tokens` | Cumulative input tokens consumed in the current window |
| `total_output_tokens` | Cumulative output tokens produced in the current window |
| `context_window_size` | Max context for the active model (e.g. 200k for Opus 4.7) |
| `used_percentage` | Claude Code's own % used calculation |

### Storage

| File | Written by | Contents |
|------|------------|----------|
| `~/.claude/.statusline.input` | `statusline.sh` (every turn) | Last JSON payload — source for current window stats |
| `~/.claude/token-log.jsonl` | `token-tracker.sh` | One JSONL record per session event (`start`, `stop`) |

Each `stop` record:

```json
{"event":"stop","ts":"2026-05-26T17:40:00Z","cwd":"/path/to/proj","model":"opus-4.7","input_tokens":98234,"output_tokens":12044,"ctx_max":200000}
```

### Reset

| Goal | Command |
|------|---------|
| Reset current context window | `/clear` (built-in Claude Code command) |
| Clear session history log | `/tokens reset` |
| Clear cached current-window stats | `rm ~/.claude/.statusline.input` |
| Nuke everything | `rm ~/.claude/token-log.jsonl ~/.claude/.statusline.input` |

---

## `/smell` — Code Smell Review

Runs a 5-step analysis against your current git diff:

```
/smell              # diffs against origin/main by default
/smell my-branch    # diffs against a specific branch
```

| Catalog | What it checks |
|---------|---------------|
| **Clean Code** (Martin) | Naming, function shape, duplication, abstraction levels, magic numbers, Law of Demeter — 35 IDs |
| **Gang of Four** | Missing design patterns + 7 design smells (rigidity, fragility, opacity, etc.) |
| **Python-specific** | 35 runtime/security IDs — `PY.BARE-EXCEPT`, `PY.MUTABLE-DEFAULT`, `PY.BLOCKING-IN-ASYNC`, and more |

Every finding is assigned a severity (**BLOCKER → HIGH → MEDIUM → LOW → NIT**) with a one-sentence fix.

### Add a slash command

Drop a `.md` file into `.claude/commands/` and re-run `./install.sh`. It will be symlinked into `~/.claude/commands/` and available as `/<filename>` inside Claude Code.

---

## Locking Pane Titles in iTerm2

By default iTerm2 lets running processes overwrite the pane title. To keep model labels visible:

> iTerm2 → Settings → Profiles → Terminal → uncheck **"Allow title reporting"** and **"Terminal may set tab/session title"**
