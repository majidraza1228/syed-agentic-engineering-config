#!/usr/bin/env bash
# Idempotent installer for agentic-config:
#  - symlink ~/.tmux.conf -> repo's tmux.conf (backing up any existing file)
#  - append `source ~/src/agentic-config/shell.zsh` to ~/.zshrc (if missing)
#  - merge statusLine + hooks into ~/.claude/settings.json (preserving existing keys)
#  - symlink slash commands from .claude/commands/ into ~/.claude/commands/

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TMUX_SRC="$REPO/tmux.conf"
TMUX_DST="$HOME/.tmux.conf"
ZSHRC="$HOME/.zshrc"
SHELL_SRC="$REPO/shell.zsh"
SHELL_LINE="source \"$REPO/shell.zsh\"  # agentic-config"
SETTINGS="$HOME/.claude/settings.json"

ts() { date +%Y%m%d-%H%M%S; }

say()  { printf '\033[1;32m✓\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!\033[0m %s\n' "$*"; }

mkdir -p "$HOME/src"

# --- tmux symlink ---
if [ -L "$TMUX_DST" ] && [ "$(readlink "$TMUX_DST")" = "$TMUX_SRC" ]; then
  say "~/.tmux.conf already linked"
elif [ -e "$TMUX_DST" ]; then
  bak="${TMUX_DST}.bak.$(ts)"
  mv "$TMUX_DST" "$bak"
  warn "backed up existing ~/.tmux.conf -> $bak"
  ln -s "$TMUX_SRC" "$TMUX_DST"
  say "symlinked ~/.tmux.conf -> $TMUX_SRC"
else
  ln -s "$TMUX_SRC" "$TMUX_DST"
  say "symlinked ~/.tmux.conf -> $TMUX_SRC"
fi

# --- zshrc source line ---
if [ -f "$ZSHRC" ] && grep -Fq "$REPO/shell.zsh" "$ZSHRC"; then
  say "~/.zshrc already sources shell.zsh"
else
  {
    printf '\n# agentic-config (tmux/shell helpers)\n'
    printf '%s\n' "$SHELL_LINE"
  } >>"$ZSHRC"
  say "appended source line to ~/.zshrc"
fi

# --- chmod scripts ---
chmod +x "$REPO/statusline.sh" "$REPO/statusline-daemon.sh" "$REPO/token-tracker.sh" "$REPO/token-report.sh" "$REPO/install.sh" "$REPO/bin/clip"
if [ -d "$REPO/.codex" ]; then
  chmod +x "$REPO"/.codex/*.sh
fi

# --- claude settings.json merge ---
mkdir -p "$(dirname "$SETTINGS")"
if ! command -v jq >/dev/null 2>&1; then
  warn "jq not found; skipping settings.json merge. Install jq and re-run."
else
  if [ -f "$SETTINGS" ]; then
    cp "$SETTINGS" "${SETTINGS}.bak.$(ts)"
  else
    echo '{}' >"$SETTINGS"
  fi
  tmp=$(mktemp)
  jq \
    --arg sl         "$REPO/statusline.sh" \
    --arg start      "$REPO/statusline-daemon.sh start" \
    --arg stop       "$REPO/statusline-daemon.sh stop" \
    --arg tok_start  "$REPO/token-tracker.sh start" \
    --arg tok_stop   "$REPO/token-tracker.sh stop" \
    '
    .statusLine = { "type": "command", "command": $sl, "padding": 0 }
    | .hooks = ((.hooks // {})
        | .SessionStart = [{ "hooks": [
            { "type": "command", "command": $start },
            { "type": "command", "command": $tok_start }
          ] }]
        | .Stop = [{ "hooks": [
            { "type": "command", "command": $stop },
            { "type": "command", "command": $tok_stop }
          ] }])
    ' "$SETTINGS" >"$tmp"
  mv "$tmp" "$SETTINGS"
  say "merged statusLine + hooks into $SETTINGS"
fi

# --- slash commands ---
mkdir -p "$HOME/.claude/commands"
if [ -d "$REPO/.claude/commands" ]; then
  shopt -s nullglob
  for src in "$REPO"/.claude/commands/*.md; do
    name=$(basename "$src")
    dst="$HOME/.claude/commands/$name"
    if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
      say "~/.claude/commands/$name already linked"
    elif [ -e "$dst" ]; then
      mv "$dst" "${dst}.bak.$(ts)"
      ln -s "$src" "$dst"
      warn "backed up existing ~/.claude/commands/$name; relinked"
    else
      ln -s "$src" "$dst"
      say "symlinked ~/.claude/commands/$name -> $src"
    fi
  done
fi

cat <<EOF

Next steps:
  1. exec zsh                          # reload shell to pick up t/cwork + stty -ixon
  2. tmux source ~/.tmux.conf          # if tmux is already running
  3. t                                 # launch the 4-pane Claude workspace
  4. Open a new Claude Code session    # status bar + /smell command available
EOF
# Copilot helper: install dependencies (tmux, jq, sqlite3, git, gawk)
if [ "${1:-}" = "install-copilot-deps" ]; then
  echo "Running Copilot dependency installer..."
  bash "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/.copilot/install-deps.sh"
  exit 0
fi
