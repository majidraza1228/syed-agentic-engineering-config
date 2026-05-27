#!/usr/bin/env bash
# Launch one Codex pane and keep its terminal title/badge updated.

set -u

cwd="${1:-$PWD}"
model="${2:-gpt-5.5}"
effort="${3:-medium}"
name="${4:-Codex}"
ctx_max="${5:-272000}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STATUS="$SCRIPT_DIR/status.sh"

terminal_escape() {
  local line badge_b64
  line="$("$STATUS" "$cwd" "$model" "$effort" "$ctx_max" 2>/dev/null || printf '%s | %s | %s | 0/%s' "$(basename "$cwd")" "$model" "$effort" "$ctx_max")"
  printf '\033]0;%s\a' "$line"
  if command -v base64 >/dev/null 2>&1; then
    badge_b64=$(printf '%s' "$line" | base64 | tr -d '\n')
    printf '\033]1337;SetBadgeFormat=%s\a' "$badge_b64"
  fi
}

cd "$cwd" || exit 1
terminal_escape
(
  while true; do
    sleep 5
    terminal_escape
  done
) &
updater_pid=$!
trap 'kill "$updater_pid" 2>/dev/null || true' EXIT INT TERM

codex --model "$model" -c "model_reasoning_effort=\"$effort\"" --cd "$cwd"
status=$?
kill "$updater_pid" 2>/dev/null || true
exit "$status"
