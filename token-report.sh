#!/usr/bin/env bash
# Display token usage: current context window + recent session history.
# Usage: token-report.sh [reset]

set -u

LOG_FILE="$HOME/.claude/token-log.jsonl"
INPUT_FILE="$HOME/.claude/.statusline.input"

fmt_k() {
  local n=${1:-0}
  if [ "$n" -ge 1000 ] 2>/dev/null; then
    awk -v n="$n" 'BEGIN { printf("%.1fk", n/1000) }'
  else
    printf '%d' "$n"
  fi
}

if [ "${1:-}" = "reset" ]; then
  if [ -f "$LOG_FILE" ]; then
    rm "$LOG_FILE"
    printf 'Token history cleared.\n'
    printf 'Tip: /clear resets the current context window.\n'
  else
    printf 'Nothing to clear (no token log exists).\n'
  fi
  exit 0
fi

# ── Current window ───────────────────────────────────────────────────────────
printf '## Current Window\n'
if [ -s "$INPUT_FILE" ]; then
  in_tok=$(jq  -r '.context_window.total_input_tokens  // 0' "$INPUT_FILE" 2>/dev/null || echo 0)
  out_tok=$(jq -r '.context_window.total_output_tokens // 0' "$INPUT_FILE" 2>/dev/null || echo 0)
  ctx_max=$(jq -r '.context_window.context_window_size // 200000' "$INPUT_FILE" 2>/dev/null || echo 200000)
  pct=$(jq     -r '.context_window.used_percentage     // 0' "$INPUT_FILE" 2>/dev/null || echo 0)
  total=$((in_tok + out_tok))
  pct_int=$(printf '%.0f' "${pct:-0}" 2>/dev/null || echo 0)
  printf '  Input:  %s tokens\n' "$(fmt_k "$in_tok")"
  printf '  Output: %s tokens\n' "$(fmt_k "$out_tok")"
  printf '  Total:  %s / %s  (%s%% used)\n' \
    "$(fmt_k "$total")" "$(fmt_k "$ctx_max")" "$pct_int"
  printf '\n  Use /clear to reset the current context window.\n'
else
  printf '  No data yet — appears after the first assistant turn.\n'
fi

# ── Session history ──────────────────────────────────────────────────────────
printf '\n## Session History  (last 10)\n'
if [ ! -s "$LOG_FILE" ]; then
  printf '  No sessions logged yet.\n'
  exit 0
fi

jq -rs '[.[] | select(.event == "stop")] | .[-10:] | reverse | .[] |
  [.ts, (.model // "claude"), .cwd,
   (.input_tokens  // 0 | tostring),
   (.output_tokens // 0 | tostring),
   (.ctx_max       // 200000 | tostring)] | @tsv
' "$LOG_FILE" 2>/dev/null | \
while IFS=$'\t' read -r ts model cwd in_tok out_tok ctx_max; do
  total=$((in_tok + out_tok))
  project=$(basename "$cwd")
  date_str=$(printf '%s' "$ts" | sed 's/T/ /' | sed 's/Z$//')
  model_short=$(printf '%.13s' "$model")
  printf '  %s  %-13s  %-18s  in:%-7s out:%-7s total:%s\n' \
    "$date_str" "$model_short" "$(printf '%-18.18s' "$project")" \
    "$(fmt_k "$in_tok")" "$(fmt_k "$out_tok")" "$(fmt_k "$total")"
done

total_sessions=$(jq -rs '[.[] | select(.event == "stop")] | length' "$LOG_FILE" 2>/dev/null || echo 0)
printf '\n  Logged sessions: %s  |  /tokens reset  to clear history\n' "$total_sessions"
