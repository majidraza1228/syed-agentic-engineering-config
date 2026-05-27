#!/usr/bin/env bash
set -eu

cwd="${1:-$PWD}"
branch="${2:-$(git -C "$cwd" rev-parse --abbrev-ref HEAD 2>/dev/null || git -C "$cwd" rev-parse --short HEAD 2>/dev/null || echo detached)}"
session_name="codex-$(basename "$cwd")-$(date +%s)"
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
runner="$script_dir/run-pane.sh"

P1_MODEL="${P1_MODEL:-gpt-5.5}"
P2_MODEL="${P2_MODEL:-gpt-5.4}"
P3_MODEL="${P3_MODEL:-gpt-5.4-mini}"
P4_MODEL="${P4_MODEL:-gpt-5.3-codex}"

P1_EFFORT="${P1_EFFORT:-xhigh}"
P2_EFFORT="${P2_EFFORT:-high}"
P3_EFFORT="${P3_EFFORT:-medium}"
P4_EFFORT="${P4_EFFORT:-low}"

P1_TOKENS="${P1_TOKENS:-272000}"
P2_TOKENS="${P2_TOKENS:-272000}"
P3_TOKENS="${P3_TOKENS:-272000}"
P4_TOKENS="${P4_TOKENS:-272000}"

if ! command -v tmux >/dev/null 2>&1; then
  echo "tmux not found. Install tmux to use codext on zsh, WSL, or CentOS." >&2
  exit 1
fi

tmux new-session -d -s "$session_name" -c "$cwd"
tmux split-window -h -t "$session_name:0" -c "$cwd"
tmux select-pane -t "$session_name:0.0"
tmux split-window -v -t "$session_name:0.0" -c "$cwd"
tmux select-pane -t "$session_name:0.1"
tmux split-window -v -t "$session_name:0.1" -c "$cwd"

tmux rename-window -t "$session_name:0" "codex | $branch"
tmux set-option -t "$session_name" status on
tmux set-option -t "$session_name" status-left " codex | $branch "
tmux set-option -t "$session_name" status-right "#{pane_title} "
tmux set-option -t "$session_name" pane-border-status bottom
tmux set-option -t "$session_name" pane-border-format " #{pane_title} "

tmux send-keys -t "$session_name:0.0" "bash \"$runner\" \"$cwd\" \"$P1_MODEL\" \"$P1_EFFORT\" \"Codex-XHigh\" \"$P1_TOKENS\"" C-m
tmux send-keys -t "$session_name:0.1" "bash \"$runner\" \"$cwd\" \"$P2_MODEL\" \"$P2_EFFORT\" \"Codex-High\" \"$P2_TOKENS\"" C-m
tmux send-keys -t "$session_name:0.2" "bash \"$runner\" \"$cwd\" \"$P3_MODEL\" \"$P3_EFFORT\" \"Codex-Medium\" \"$P3_TOKENS\"" C-m
tmux send-keys -t "$session_name:0.3" "bash \"$runner\" \"$cwd\" \"$P4_MODEL\" \"$P4_EFFORT\" \"Codex-Low\" \"$P4_TOKENS\"" C-m

tmux attach -t "$session_name"
