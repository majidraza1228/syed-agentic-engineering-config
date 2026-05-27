#!/usr/bin/env bash
set -eu

cwd="${1:-$PWD}"
branch="${2:-$(git -C "$cwd" rev-parse --abbrev-ref HEAD 2>/dev/null || git -C "$cwd" rev-parse --short HEAD 2>/dev/null || echo detached)}"
session_name="claude-$(basename "$cwd")-$(date +%s)"

P1_MODEL="${P1_MODEL:-claude-opus-4-7}"
P2_MODEL="${P2_MODEL:-claude-opus-4-7}"
P3_MODEL="${P3_MODEL:-claude-sonnet-4-6}"
P4_MODEL="${P4_MODEL:-claude-sonnet-4-6}"

if ! command -v tmux >/dev/null 2>&1; then
  echo "tmux not found. Please install tmux to use tmux fallback." >&2
  exit 1
fi

tmux new-session -d -s "$session_name" -c "$cwd"
tmux split-window -h -t "$session_name:0" -c "$cwd"
tmux select-pane -t "$session_name:0.0"
tmux split-window -v -t "$session_name:0.0" -c "$cwd"
tmux select-pane -t "$session_name:0.1"
tmux split-window -v -t "$session_name:0.1" -c "$cwd"

tmux rename-window -t "$session_name:0" "claude | $branch"

tmux send-keys -t "$session_name:0.0" "printf '\\033]0;${P1_MODEL} | 0/200k\\a' && cd \"$cwd\" && claude --model ${P1_MODEL} --name Opus-High-1" C-m
tmux send-keys -t "$session_name:0.1" "printf '\\033]0;${P2_MODEL} | 0/200k\\a' && cd \"$cwd\" && claude --model ${P2_MODEL} --name Opus-High-2" C-m
tmux send-keys -t "$session_name:0.2" "printf '\\033]0;${P3_MODEL} | 0/200k\\a' && cd \"$cwd\" && claude --model ${P3_MODEL} --name Sonnet-1" C-m
tmux send-keys -t "$session_name:0.3" "printf '\\033]0;${P4_MODEL} | 0/200k\\a' && cd \"$cwd\" && claude --model ${P4_MODEL} --name Sonnet-2" C-m

tmux attach -t "$session_name"
