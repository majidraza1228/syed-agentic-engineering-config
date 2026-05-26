#!/usr/bin/env bash
# Logs per-session token usage to ~/.claude/token-log.jsonl.
# Invoked by Claude Code hooks: SessionStart (start) and Stop (stop).

set -u

LOG_FILE="$HOME/.claude/token-log.jsonl"
INPUT_FILE="$HOME/.claude/.statusline.input"

mkdir -p "$(dirname "$LOG_FILE")"

# Drain stdin to avoid blocking the hook pipe.
cat >/dev/null 2>&1 || true

ts=$(date -u +%Y-%m-%dT%H:%M:%SZ)

jq_from() { printf '%s' "$1" | jq -r "$2 // empty" 2>/dev/null; }

case "${1:-}" in
  start)
    jq -nc \
      --arg ts  "$ts" \
      --arg cwd "$PWD" \
      '{event:"start",ts:$ts,cwd:$cwd}' >>"$LOG_FILE"
    ;;

  stop)
    input='{}'
    [ -s "$INPUT_FILE" ] && input=$(cat "$INPUT_FILE")
    cwd=$(jq_from "$input" '.workspace.current_dir // .cwd')
    model=$(jq_from "$input" '.model.display_name')
    in_tok=$(jq_from "$input" '.context_window.total_input_tokens')
    out_tok=$(jq_from "$input" '.context_window.total_output_tokens')
    ctx_max=$(jq_from "$input" '.context_window.context_window_size')
    [ -z "$cwd" ]    && cwd="$PWD"
    [ -z "$model" ]  && model="claude"
    [ -z "$in_tok" ] && in_tok=0
    [ -z "$out_tok" ] && out_tok=0
    [ -z "$ctx_max" ] && ctx_max=200000
    jq -nc \
      --arg    ts      "$ts" \
      --arg    cwd     "$cwd" \
      --arg    model   "$model" \
      --argjson in_tok  "$in_tok" \
      --argjson out_tok "$out_tok" \
      --argjson ctx_max "$ctx_max" \
      '{event:"stop",ts:$ts,cwd:$cwd,model:$model,input_tokens:$in_tok,output_tokens:$out_tok,ctx_max:$ctx_max}' \
      >>"$LOG_FILE"
    ;;
esac

exit 0
