#!/usr/bin/env bash
# Copilot statusLine: model | git branch (+worktree) | context bar
# Reads cache written by statusline-daemon.sh for a ~2s refresh cadence;
# computes inline as fallback if the cache is stale or missing.

set -u

INPUT="$(cat)"
CACHE_DIR="$HOME/.copilot"
CACHE_FILE="$CACHE_DIR/.statusline.cache"
INPUT_FILE="$CACHE_DIR/.statusline.input"
STALE_AFTER=3   # seconds

compute_line() {
  local input="$1"
  local model_name cwd used ctx_max
  model_name=$(printf '%s' "$input" | jq -r '.model.display_name // "copilot"')
  cwd=$(printf '%s'        "$input" | jq -r '.workspace.current_dir // .cwd // empty')
  # Authoritative context-window data (if present).
  local pct_pre
  ctx_max=$(printf '%s'    "$input" | jq -r '.context_window.context_window_size // 200000')
  used=$(printf '%s'       "$input" | jq -r '(.context_window.total_input_tokens // 0) + (.context_window.total_output_tokens // 0)')
  pct_pre=$(printf '%s'    "$input" | jq -r '.context_window.used_percentage // empty')

  # --- model slug: strip "Copilot " prefix and any "(...)" suffix, lowercase, space->dash ---
  local slug
  slug=$(printf '%s' "$model_name" | awk '
    {
      n = $0
      sub(/[[:space:]]*\([^)]*\)[[:space:]]*$/, "", n)   # drop trailing (...)
      sub(/^[Cc]opilot[[:space:]]+/, "", n)
      n = tolower(n)
      gsub(/[[:space:]]+/, "-", n)
      print n
    }')

  # --- git segment ---
  local git_seg=""
  if [ -n "$cwd" ] && git -C "$cwd" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    local branch gd cd_path
    branch=$(git -C "$cwd" branch --show-current 2>/dev/null)
    [ -z "$branch" ] && branch=$(git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
    gd=$(git -C "$cwd" rev-parse --git-dir 2>/dev/null)
    cd_path=$(git -C "$cwd" rev-parse --git-common-dir 2>/dev/null)
    case "$gd" in /*) ;; *) gd="$cwd/$gd";; esac
    case "$cd_path" in /*) ;; *) cd_path="$cwd/$cd_path";; esac
    git_seg="$branch"
    if [ "$gd" != "$cd_path" ]; then
      local wt
      wt=$(basename "$gd")
      git_seg="$branch +wt:$wt"
    fi
  fi

  # --- context bar / percent ---
  [ "$ctx_max" -le 0 ] && ctx_max=200000
  local pct
  if [ -n "$pct_pre" ]; then
    pct=$(awk -v p="$pct_pre" 'BEGIN { printf("%d", p + 0.5) }')
  else
    pct=$(( used * 100 / ctx_max ))
  fi
  [ $pct -gt 100 ] && pct=100
  [ $pct -lt 0 ] && pct=0
  local filled=$(( pct * 20 / 100 ))
  [ $filled -gt 20 ] && filled=20
  local empty=$(( 20 - filled ))
  local bar=""
  local i
  for ((i=0; i<filled; i++)); do bar="${bar}█"; done
  for ((i=0; i<empty;  i++)); do bar="${bar}░"; done

  fmt_k() {
    local n=$1
    if [ $n -ge 1000 ]; then
      awk -v n="$n" 'BEGIN { printf("%.0fk", n/1000) }'
    else
      printf '%d' "$n"
    fi
  }
  local used_s max_s
  used_s=$(fmt_k "$used")
  max_s=$(fmt_k "$ctx_max")

  if [ -n "$git_seg" ]; then
    printf '%s | %s | %d%% (%s/%s)\n' "$model_name" "$git_seg" "$pct" "$used_s" "$max_s"
  else
    printf '%s | %d%% (%s/%s)\n' "$model_name" "$pct" "$used_s" "$max_s"
  fi
}

file_mtime() {
  stat -c %Y "$1" 2>/dev/null || stat -f %m "$1" 2>/dev/null || echo 0
}

# Stash latest stdin FIRST so the daemon always has current input, and so
# cache freshness can be measured against this file's mtime.
mkdir -p "$CACHE_DIR"
if [ ! -f "$INPUT_FILE" ] || [ "$INPUT" != "$(cat "$INPUT_FILE" 2>/dev/null)" ]; then
  printf '%s' "$INPUT" >"$INPUT_FILE" 2>/dev/null || true
fi

# Prefer fresh cache if available AND newer than the latest input we've seen.
if [ -f "$CACHE_FILE" ] && [ -s "$CACHE_FILE" ]; then
  cache_mtime=$(file_mtime "$CACHE_FILE")
  input_mtime=$(file_mtime "$INPUT_FILE")
  now=$(date +%s)
  age=$(( now - cache_mtime ))
  if [ $age -le $STALE_AFTER ] && [ "$cache_mtime" -ge "$input_mtime" ]; then
    cat "$CACHE_FILE"
    exit 0
  fi
fi

# Fallback: compute inline (also seeds the cache for the daemon)
line=$(compute_line "$INPUT")
printf '%s\n' "$line" | tee "$CACHE_FILE" >/dev/null
printf '%s\n' "$line"
