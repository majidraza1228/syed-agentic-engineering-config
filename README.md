# syed-agentic-engineering-config

Shell config and workspace helpers for agentic engineering workflows on macOS (iTerm2 + tmux).

![4-pane workspace](assets/workspace.png)

---

## Requirements

- macOS with [iTerm2](https://iterm2.com)
- [Claude Code CLI](https://claude.ai/code) (`claude` on your PATH)
- `jq` — `brew install jq`
- tmux (optional, fallback for non-macOS) — `brew install tmux`

---

## Install

```sh
git clone https://github.com/majidraza1228/syed-agentic-engineering-config.git ~/syed-agentic-engineering-config
ln -s ~/syed-agentic-engineering-config ~/src/agentic-config
cd ~/syed-agentic-engineering-config
./install.sh && exec zsh
```

---

## Workspace Commands

### Claude — `claudet`

Opens a 2×2 iTerm2 window with 4 Claude Code panes (Opus 4.7 × 2, Sonnet 4.6 × 2).

→ Full guide: [`docs/claude-developer-guide.md`](docs/claude-developer-guide.md)

### GitHub Copilot — `ght`

Opens a 2×2 iTerm2 window with 4 Copilot panes (gpt-5-mini × 2, gpt-4.1, haiku).

→ Full guide: [`docs/copilot-developer-guide.md`](docs/copilot-developer-guide.md)

### Codex — `codext` / `codex4`

Opens a 2×2 iTerm2 window with 4 Codex panes (gpt-5.5 xhigh, gpt-5.4 high, gpt-5.4-mini medium, gpt-5.3-codex low).

→ Full guide: [`docs/codex-developer-guide.md`](docs/codex-developer-guide.md)

---

## What's Inside

| File | Purpose |
|------|---------|
| `install.sh` | One-shot idempotent installer |
| `shell.zsh` | `claudet`, `ght`, `codext` commands + shell helpers |
| `statusline.sh` | Claude Code status line (model · branch · context bar) |
| `statusline-daemon.sh` | Background daemon refreshing status line cache every 2s |
| `tmux.conf` | tmux config with vi keys, mouse support, smart copy-to-clipboard |
| `bin/clip` | Cross-platform clipboard shim (`pbcopy` / `wl-copy` / `xclip` / `xsel`) |
| `docs/claude/tmux-claudet.sh` | tmux fallback for `claudet` |
| `docs/claude-developer-guide.md` | Claude workspace developer guide |
| `docs/copilot-developer-guide.md` | Copilot workspace developer guide |
| `docs/codex-developer-guide.md` | Codex workspace developer guide |
| `.claude/commands/smell.md` | `/smell` slash command — code smell review |

---

## tmux Config

`tmux.conf` is a minimal vi-keyed config focused on copy-paste ergonomics:

| Feature | Detail |
|---------|--------|
| Mouse support | `set -g mouse on` — scroll, click to select pane, drag to select text |
| Copy on drag | Mouse drag in copy mode → clipboard via `bin/clip` |
| Double-click | Selects and copies the word under cursor |
| Triple-click | Selects and copies the entire line |
| History | 50,000 lines scrollback |

---

## Uninstall

```sh
sed -i '' '/agentic-config\/shell.zsh/d' ~/.zshrc
rm ~/.tmux.conf
jq 'del(.statusLine, .hooks)' ~/.claude/settings.json > /tmp/s.json && mv /tmp/s.json ~/.claude/settings.json
```
