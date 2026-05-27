#!/usr/bin/env bash
set -eu

cwd="${1:-$PWD}"
branch="${2:-$(git -C "$cwd" rev-parse --abbrev-ref HEAD 2>/dev/null || git -C "$cwd" rev-parse --short HEAD 2>/dev/null || echo detached)}"
session_name="copilot-$(basename "$cwd")-$(date +%s)"

P1_MODEL="${P1_MODEL:-gpt-5-mini}"
P2_MODEL="${P2_MODEL:-gpt-5-mini}"
P3_MODEL="${P3_MODEL:-gpt-4.1}"
P4_MODEL="${P4_MODEL:-claude-haiku-4.5}"

P1_TOKENS="${P1_TOKENS:-200000}"
P3_TOKENS="${P3_TOKENS:-128000}"
P4_TOKENS="${P4_TOKENS:-128000}"

if ! command -v tmux >/dev/null 2>&1; then
  echo "tmux not found. Please install tmux to use tmux fallback." >&2
  exit 1
fi

# Start session detached
tmux new-session -d -s "$session_name" -c "$cwd"
# Layout: create 2x2
tmux split-window -h -t "$session_name:0" -c "$cwd"
tmux select-pane -t "$session_name:0.0"
tmux split-window -v -t "$session_name:0.0" -c "$cwd"
tmux select-pane -t "$session_name:0.1"
tmux split-window -v -t "$session_name:0.1" -c "$cwd"

# Rename window to include branch
tmux rename-window -t "$session_name:0" "copilot | $branch"

# send commands to panes; also set terminal title inside each pane
tmux send-keys -t "$session_name:0.0" "printf '\\033]0;${P1_MODEL} | high | 0/${P1_TOKENS}\\a' && cd \"$cwd\" && copilot --model ${P1_MODEL} --effort high --name GPT5-High-1" C-m
tmux send-keys -t "$session_name:0.1" "printf '\\033]0;${P2_MODEL} | high | 0/${P1_TOKENS}\\a' && cd \"$cwd\" && copilot --model ${P2_MODEL} --effort high --name GPT5-High-2" C-m
tmux send-keys -t "$session_name:0.2" "printf '\\033]0;${P3_MODEL} | medium | 0/${P3_TOKENS}\\a' && cd \"$cwd\" && copilot --model ${P3_MODEL} --effort medium --name GPT4-Medium" C-m
tmux send-keys -t "$session_name:0.3" "printf '\\033]0;${P4_MODEL} | low | 0/${P4_TOKENS}\\a' && cd \"$cwd\" && copilot --model ${P4_MODEL} --effort low --name Haiku-Low" C-m

# Attach
tmux attach -t "$session_name"
