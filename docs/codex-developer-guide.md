# Codex CLI - Developer Guide

This guide explains how developers can use the repo's Codex workspace helpers: launch a 4-pane Codex layout, choose models and reasoning effort, read token usage, customize defaults, and troubleshoot local setup.

It is focused on this config repository's `codext` wrapper, not a complete reference for every Codex CLI feature.

---

## Quick Start

From any project directory:

```zsh
codext
```

`codext` opens a 2x2 Codex workspace for the current directory.

On macOS with iTerm2, it creates a new iTerm2 window. On Linux, WSL, CentOS 9, or shells without iTerm2 automation, it falls back to tmux when tmux is installed.

The same command is also available as:

```zsh
codex4
```

## Requirements

- Codex CLI available as `codex` on `PATH`
- This repository installed and sourced through `shell.zsh`
- macOS + iTerm2 for the native split-pane layout, or `tmux` for the fallback layout
- `git` for branch-aware pane titles
- `sqlite3` for best-effort token usage from `~/.codex/logs_2.sqlite`

Optional but useful:

- `base64` for iTerm2 badge updates
- `AGENTIC_CONFIG_HOME` when this repo is not installed at the default path

## Install or Refresh

Clone and install the config:

```sh
git clone https://github.com/majidraza1228/syed-agentic-engineering-config.git ~/syed-agentic-engineering-config
ln -s ~/syed-agentic-engineering-config ~/src/agentic-config
cd ~/syed-agentic-engineering-config
./install.sh
exec zsh
```

The installer makes the `.codex/*.sh` scripts executable when the `.codex/` directory exists. It also makes `shell.zsh` available through your `~/.zshrc`, which exposes `codext` and `codex4`.

If you install this repo somewhere else, set:

```zsh
export AGENTIC_CONFIG_HOME="$HOME/path/to/syed-agentic-engineering-config"
```

## New Machine Setup Checklist

Use this checklist when a developer brings this repo to a new machine.

1. Install machine prerequisites:

```sh
brew install jq tmux sqlite3 git
```

On Linux or WSL, install the same tools with the system package manager.

2. Install Codex CLI and authenticate it:

```sh
command -v codex
codex
```

If `command -v codex` prints nothing, install Codex CLI using the team's approved method first. When `codex` opens for the first time, complete its login or API key flow. Do not put API keys in this repository.

3. Clone this config repo:

```sh
git clone https://github.com/majidraza1228/syed-agentic-engineering-config.git ~/syed-agentic-engineering-config
mkdir -p ~/src
ln -s ~/syed-agentic-engineering-config ~/src/agentic-config
cd ~/syed-agentic-engineering-config
```

4. Run the installer and reload the shell:

```sh
./install.sh
exec zsh
```

5. Verify shell commands are available:

```zsh
type codext
type codex4
```

6. Verify the Codex pane scripts:

```sh
bash -n .codex/run-pane.sh .codex/status.sh .codex/tmux-codext.sh
```

7. Open a project and start the Codex workspace:

```zsh
cd ~/path/to/project
codext
```

8. Confirm expected behavior:

- Four Codex panes open.
- Each pane starts in the project directory.
- Pane titles show `branch | model | effort | used/max tokens`.
- Token usage starts at `0/272k` until Codex writes usage data.

If the repo is installed somewhere other than `~/src/agentic-config`, add this to the developer's shell profile:

```zsh
export AGENTIC_CONFIG_HOME="$HOME/path/to/syed-agentic-engineering-config"
```

## What `codext` Opens

`codext` starts four Codex sessions against the same current working directory:

| Pane | Default model | Reasoning effort | Suggested use |
|------|---------------|------------------|---------------|
| 1 | `gpt-5.5` | `xhigh` | architecture, hard debugging, complex design |
| 2 | `gpt-5.4` | `high` | implementation, reviews, multi-file changes |
| 3 | `gpt-5.4-mini` | `medium` | routine coding, focused edits, exploration |
| 4 | `gpt-5.3-codex` | `low` | quick lookups, grep-style tasks, simple fixes |

Each pane is launched through:

```sh
codex --model "$model" -c "model_reasoning_effort=\"$effort\"" --cd "$cwd"
```

The working directory is passed explicitly with `--cd`, so each pane starts in the project where you ran `codext`.

## Pane Titles and Token Footer

Each pane title/footer follows this format:

```text
branch | model | effort | used/max tokens
```

Example:

```text
main | gpt-5.5 | xhigh | 84k/272k
```

The title is refreshed every five seconds by `.codex/run-pane.sh`.

Token usage is best-effort:

1. `.codex/status.sh` first reads `~/.codex/logs_2.sqlite` when `sqlite3` is installed.
2. If SQLite is unavailable or has no matching entry, it falls back to `~/.codex/log/codex-tui.log`.
3. It extracts the latest `total_usage_tokens` value for the pane's model.
4. If no token data is available yet, it shows `0/272k`.

This is display-only. It does not change how Codex tracks tokens internally.

## Change Models or Reasoning Effort

For the tmux fallback, override pane defaults with environment variables:

```zsh
P1_MODEL=gpt-5.5 P1_EFFORT=high codext
P3_MODEL=gpt-5.4-mini P3_EFFORT=low codext
P4_MODEL=gpt-5.3-codex P4_TOKENS=128000 codext
```

Available variables:

| Variable | Purpose |
|----------|---------|
| `P1_MODEL` - `P4_MODEL` | Model for each pane |
| `P1_EFFORT` - `P4_EFFORT` | Reasoning effort for each pane |
| `P1_TOKENS` - `P4_TOKENS` | Displayed max context value for each pane |

For the macOS iTerm2 path, defaults are currently hardcoded in `shell.zsh`. Change the four `write text` lines inside `codext()` if you want persistent iTerm2 defaults.

## Suggested Developer Workflow

Use the panes as separate agents with different jobs:

1. Pane 1: ask for design options, risk review, or root-cause analysis.
2. Pane 2: implement the selected change.
3. Pane 3: run quick file searches, inspect examples, or update tests.
4. Pane 4: keep a lightweight scratch session for commands, summaries, and sanity checks.

Keep edits scoped to one pane at a time when possible. If multiple panes edit the same files, check `git diff` before accepting the next change so one session does not overwrite work from another.

Recommended loop:

```sh
git status --short
git diff
# run the relevant tests or linters
git add path/to/changed-file
git commit -m "Describe the completed change"
```

## Working With Git Worktrees

`codext` uses the directory where you run it. That makes it work naturally with `git worktree`:

```sh
git worktree add -b feat/new-agent ../new-agent
cd ../new-agent
codext
```

The pane footer shows the current branch or detached commit for that worktree.

## Script Reference

| File | Purpose |
|------|---------|
| `shell.zsh` | Defines `codext` and `codex4` |
| `.codex/run-pane.sh` | Starts one Codex pane and refreshes terminal title/badge |
| `.codex/status.sh` | Builds the branch/model/effort/token footer |
| `.codex/tmux-codext.sh` | Creates the 2x2 tmux fallback layout |
| `install.sh` | Makes `.codex/*.sh` executable and exposes `shell.zsh` |

## Troubleshooting

### `codext: command not found`

Reload your shell:

```zsh
exec zsh
```

If it still fails, confirm `~/.zshrc` sources this repo's `shell.zsh`.

### `Could not find agentic-config .codex scripts`

`codext` could not locate the repo's `.codex/` directory. Either run from this repository, install it at `~/src/agentic-config`, or set:

```zsh
export AGENTIC_CONFIG_HOME="$HOME/path/to/syed-agentic-engineering-config"
```

### `tmux not found`

Install tmux for non-iTerm2 environments:

```sh
brew install tmux
```

On Linux, use your system package manager.

### Pane token usage always shows `0/272k`

This usually means Codex has not written a matching usage line yet, or `sqlite3` is not installed. Confirm these files exist:

```sh
ls ~/.codex/logs_2.sqlite
ls ~/.codex/log/codex-tui.log
```

Then continue the Codex session for at least one assistant turn. The footer updates every five seconds.

### iTerm2 pane titles are overwritten

In iTerm2, disable title reporting:

```text
iTerm2 -> Settings -> Profiles -> Terminal
```

Uncheck:

- Allow title reporting
- Terminal may set tab/session title

## Safety Notes

- Do not commit secrets, API keys, Codex logs, or local `~/.codex` state.
- Treat persistent instructions and local agent memory as project-sensitive.
- Review `git diff` before committing, especially when several Codex panes have been active.
- Prefer small, focused prompts per pane to keep context and edits easier to audit.
