#!/usr/bin/env bash
# Best-effort Codex pane footer: branch | model | effort | token usage.

set -u

cwd="${1:-$PWD}"
model="${2:-codex}"
effort="${3:-medium}"
ctx_max="${4:-272000}"
log_file="${CODEX_TUI_LOG:-$HOME/.codex/log/codex-tui.log}"
sqlite_log="${CODEX_SQLITE_LOG:-$HOME/.codex/logs_2.sqlite}"

fmt_k() {
  local n=${1:-0}
  if [ "$n" -ge 1000 ] 2>/dev/null; then
    awk -v n="$n" 'BEGIN { printf("%.0fk", n / 1000) }'
  else
    printf '%d' "$n"
  fi
}

branch="detached"
if git -C "$cwd" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  branch=$(git -C "$cwd" branch --show-current 2>/dev/null)
  [ -z "$branch" ] && branch=$(git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
fi

used=0
if command -v sqlite3 >/dev/null 2>&1 && [ -r "$sqlite_log" ]; then
  used=$(
    sqlite3 "$sqlite_log" \
      "select feedback_log_body from logs where feedback_log_body like '%post sampling token usage%' and feedback_log_body like '%model=$model}%' order by ts desc, ts_nanos desc limit 1;" 2>/dev/null |
    awk '
      match($0, /total_usage_tokens=[0-9]+/) {
        value = substr($0, RSTART + 19, RLENGTH - 19)
      }
      END {
        if (value == "") value = 0
        print value
      }
    '
  )
fi
if [ "${used:-0}" = 0 ] && [ -r "$log_file" ]; then
  used=$(
    awk -v model="$model" '
      $0 !~ /^[+-]/ && $0 ~ "turn\\{[^}]*model=" model "[^}]*\\}:run_turn: post sampling token usage" {
        if (match($0, /total_usage_tokens=[0-9]+/)) {
          value = substr($0, RSTART + 19, RLENGTH - 19)
        }
      }
      END {
        if (value == "") value = 0
        print value
      }
    ' "$log_file" 2>/dev/null
  )
fi
[ -z "$used" ] && used=0

printf '%s | %s | %s | %s/%s\n' "$branch" "$model" "$effort" "$(fmt_k "$used")" "$(fmt_k "$ctx_max")"
