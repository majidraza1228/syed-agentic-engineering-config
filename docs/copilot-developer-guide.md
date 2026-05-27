# GitHub Copilot CLI — Developer Guide

This guide explains how developers can use GitHub Copilot CLI, change modes, track tokens and memory, work with Git worktrees, and plan future work. It is informed by the official Copilot CLI docs and expanded with developer-focused tips and examples.

---

## Quick start (developer)

- Install: `brew install copilot-cli` or use the install script: `curl -fsSL https://gh.io/copilot-install | bash`.
- Launch: `copilot` (in a repo or code folder).
- Authenticate: use `/login` interactive flow or set a fine-grained PAT in `GH_TOKEN`/`GITHUB_TOKEN` with the "Copilot Requests" permission.

## Core interactive model and commands

- Slash commands: start a line with `/` inside the CLI. Examples used below: `/model`, `/experimental`, `/memory`, `/usage`, `/context`, `/autopilot`, `/pr`, `/review`, `/delegate`.
- Mode keys and shortcuts:
  - Shift+Tab: cycle modes (default, autopilot, background/autonomous behaviors depending on the build).
  - ctrl+s: run command and preserve input
  - ctrl+c: cancel current operation
  - ctrl+c ctrl+c: exit
  - ctrl+t: toggle reasoning display
  - ctrl+x → b: move current task to background
  - ctrl+x → o: open most recent link

## Changing modes (how developers can change CLI behavior)

1. Flags at launch
   - `copilot --experimental` — enables experimental features for the session (persisted in CLI config).
   - `copilot --banner` — show splash banner.

2. In-session slash commands
   - `/experimental` — toggle experimental mode (persisted in the config).
   - `/autopilot` — toggle autopilot mode (encourages agent to continue until completion).
   - `/model` — choose which model to use (e.g., Claude Sonnet, GPT-5 variants).
   - `/streamer-mode` — toggle streamer mode (hides model preview names and quota details).
   - `/memory` — show memory status and enable/disable persistent memory across sessions.

3. Keyboard shortcuts and UI
   - Use Shift+Tab to cycle visual modes; use statusline items (configurable) to see current mode.

4. Persisting mode choices
   - Mode flags or slash commands set values in the user-level config (the CLI persists these settings so the next launch inherits them). Use repository-level instruction files or user config to standardize behaviour across dev machines.

## Token and usage tracking (how tokens/requests are tracked)

Important concepts:
- Premium requests vs tokens: Copilot CLI tracks "premium requests" (quota-based operations, e.g., some LLM calls) and the underlying model token usage (prompt + completion tokens). Both affect cost.
- Per-prompt accounting: each request consumes tokens for the prompt and the completion. Different models have different token accounting and limits.

Commands to inspect usage and token context:
- `/usage` — show session and account usage metrics (quota remaining, premium requests consumed).
- `/context` — visualize the session context window and token usage (how many tokens are currently in context).
- `/session` — view and manage sessions (session-level metadata and history).

Practical tips to reduce token usage:
- Use smaller models when high throughput and lower context fidelity are acceptable (`/model` to switch).
- Periodically ` /compact` or `/compact summarize` (if available) to compress long timelines into summaries so fewer context tokens are used.
- Use `/clear` or `/rewind` to remove unneeded conversation history from the session.
- Use `/share` to export research or summaries instead of keeping very long timelines live in the session.

Quota notes:
- Some features consume a monthly premium request quota (the docs note that each submitted prompt reduces the monthly premium requests count). Monitor with `/usage` and be conservative in automated loops.
- Streamer-mode may hide quota details by design; toggle it off if you need full transparency when debugging token usage.

## Memory (session and persistent memory)

- Purpose: memory enables the agent to remember user preferences, persistent instructions, or facts across sessions to produce a more personalized experience.
- Inspect and control memory with `/memory` — shows memory status, and surfaces enable/disable switches for persistent memory.
- Ephemeral vs persistent:
  - Ephemeral session memory exists only for the active session timeline and is cleared by `/clear` or when the session is closed.
  - Persistent memory is opt-in and stored between sessions if enabled; use `/memory` to turn it on/off.

Privacy and security guidance:
- Treat persistent memory as sensitive — it may contain private project facts. Disable persistent memory in CI or automated environments.
- Use fine-grained tokens (PATs) with the "Copilot Requests" permission; never commit PATs into source code.

## Worktrees and Git integration

Recommended workflows for using `git worktree` with Copilot CLI:

1. Create a worktree for a feature branch:

```bash
# add worktree and switch to it
git worktree add -b feature/ai-worktree ../worktree feature-branch
cd ../worktree
copilot
```

2. Run a Copilot session scoped to that worktree. Copilot operates on your current working directory; it uses repository-level instruction files (`.github/*`) and the workspace files it can access. If you need Copilot to access files in other directories, use `/add-dir` (manage allowed directories) or launch `copilot` in the target directory.

3. Review & PR flow:
- Use `/pr` and `/review` to create and review pull requests from inside the worktree session.
- Use `/delegate` to have Copilot prepare PRs automatically (prompt carefully and inspect changes before merging).

Permissions & allowed directories
- Use `/allow-all`, `/add-dir`, and `/list-dirs` to control which directories Copilot can access. This is important when working with multiple worktrees or a monorepo.

## Developer configuration and LSP

- LSP configuration locations:
  - User-level: `~/.copilot/lsp-config.json`
  - Repository-level: `.github/lsp.json`

- Instruction files that influence Copilot behavior:
  - `CLAUDE.md`, `GEMINI.md`, `AGENTS.md` (git root & cwd)
  - `.github/instructions/**/*.instructions.md`
  - `.github/copilot-instructions.md`
  - `$HOME/.copilot/copilot-instructions.md`
  - `COPILOT_CUSTOM_INSTRUCTIONS_DIRS` (env var pointing to extra directories)

- LSP servers must be installed separately. Example (TypeScript):

```bash
npm install -g typescript-language-server
```

- Use `/lsp` inside the CLI to view configured LSP servers and status.

## Debugging, telemetry and diagnostics

Helpful commands:
- `/env` — show loaded environment details and active instructions
- `/context` — visualize token usage and context window
- `/usage` — get quota/status metrics
- `/changelog summarize` — get an AI summary of changelog entries
- Use `copilot --experimental` and `/experimental` to test experimental diagnostics and features. Report failures with `/feedback`.

## Security and tokens

- Authentication: use the interactive `/login` or fine-grained PAT in `GH_TOKEN`/`GITHUB_TOKEN` (ensure "Copilot Requests" permission).
- Never store tokens in source control. Use environment variables or secrets stores.
- The CLI respects repo and user instructions; review `.github` instruction files and your `~/.copilot/*` files.

## Examples and recipes

- Start a session in a feature worktree and create a PR quickly:

```bash
# create worktree, start copilot, and create PR draft
git worktree add -b feat/x ../feat-x feat/x
cd ../feat-x
copilot --experimental
# inside copilot:
# /init
# ask: "Implement feature X" → preview edits
# /pr create --draft
```

- Reduce token usage for long research sessions:
  1. Periodically run `/compact` (or ask the agent: "Summarize the timeline and keep only the summary")
  2. Use `/share` to export results and `/clear` to continue with a clean session

## Future work and roadmap (developer-facing)

Areas that are natural next steps and good candidates for contributions or monitoring:

- Native multi-worktree UI and workspace management (first-class support for `git worktree`).
- Team-shared memory and policy-controlled memory stores for organizations (fine-grained access controls).
- Improved token visualization and cost breakdown per-turn and per-model.
- Offline/edge model support and local-only modes for highly sensitive codebases.
- Plugin marketplace and richer skill/agent developer APIs.
- Granular memory APIs for developers: programmatic read/write/TTL for stored facts.

## FAQs

Q: Where are settings persisted?
A: Settings changed via flags or slash commands are persisted to the CLI's config (user-level persistent settings). LSP config is stored in `~/.copilot/lsp-config.json`; repository-level LSP config lives in `.github/lsp.json`.

Q: How do I disable memory for a CI run?
A: Use the `/memory` command to disable persistent memory, or run `copilot --experimental` with memory-disabled configuration via environment variables or CI config. Also prefer ephemeral tokens and disable persistent settings in CI.

Q: How can I audit what Copilot can access?
A: Use `/list-dirs` and `/add-dir` to query and control access. Check instruction files in `.github/` and `$HOME/.copilot/`.

## Further reading and references

- Official docs: https://docs.github.com/copilot/how-tos/use-copilot-agents/use-copilot-cli
- Changelog: run `/changelog` inside the CLI

---

This document is a developer-focused companion to the official Copilot CLI docs. If you'd like this pushed to a different path, or split into separate reference pages (Modes, Token tracking, Memory), say so and the doc can be adjusted.
