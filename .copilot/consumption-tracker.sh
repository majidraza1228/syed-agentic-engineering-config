#!/bin/bash
# Token consumption tracker for Copilot CLI panes
# Monitors usage from Copilot API logs and updates iTerm2 badges

TRACKER_DB="${HOME}/.copilot/consumption.db"
LOG_DIR="${HOME}/.copilot/logs"

# Initialize database if it doesn't exist
init_db() {
  sqlite3 "$TRACKER_DB" <<EOF
CREATE TABLE IF NOT EXISTS sessions (
  id TEXT PRIMARY KEY,
  model TEXT,
  pane TEXT,
  start_time INTEGER,
  tokens_used INTEGER DEFAULT 0,
  tokens_limit INTEGER
);

CREATE TABLE IF NOT EXISTS interactions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  session_id TEXT,
  input_tokens INTEGER,
  output_tokens INTEGER,
  timestamp INTEGER,
  FOREIGN KEY (session_id) REFERENCES sessions(id)
);
EOF
}

# Add tokens to a session
add_tokens() {
  local session_id=$1
  local input_tokens=$2
  local output_tokens=$3
  
  sqlite3 "$TRACKER_DB" <<EOF
INSERT INTO interactions (session_id, input_tokens, output_tokens, timestamp)
VALUES ('$session_id', $input_tokens, $output_tokens, $(date +%s));

UPDATE sessions SET tokens_used = tokens_used + $((input_tokens + output_tokens))
WHERE id = '$session_id';
EOF
}

# Get consumption for a session
get_consumption() {
  local session_id=$1
  sqlite3 "$TRACKER_DB" "SELECT tokens_used, tokens_limit FROM sessions WHERE id = '$session_id';"
}

# Create a new session
create_session() {
  local session_id=$1
  local model=$2
  local pane=$3
  local tokens_limit=$4
  
  sqlite3 "$TRACKER_DB" <<EOF
INSERT OR REPLACE INTO sessions (id, model, pane, start_time, tokens_limit, tokens_used)
VALUES ('$session_id', '$model', '$pane', $(date +%s), $tokens_limit, 0);
EOF
}

# Format tokens for display (convert to k if >= 1000)
format_tokens() {
  local tokens=$1
  if [ "$tokens" -ge 1000 ]; then
    echo "$((tokens / 1000))k"
  else
    echo "$tokens"
  fi
}

# Update iTerm2 badge with consumption
update_badge() {
  local session_id=$1
  local model=$2
  local effort=$3
  local tokens_limit=$4
  
  consumption=$(get_consumption "$session_id")
  if [ -z "$consumption" ]; then
    tokens_used=0
  else
    tokens_used=$(echo "$consumption" | cut -d'|' -f1)
  fi
  
  formatted_used=$(format_tokens "$tokens_used")
  formatted_limit=$(format_tokens "$tokens_limit")
  
  # Badge format: model\neffort\nused/limit
  badge_text="${model}\n${effort} effort\n${formatted_used}/${formatted_limit}"
  badge_b64=$(printf "%s" "$badge_text" | base64)
  
  printf '\033]1337;SetBadgeFormat=%s\a' "$badge_b64"
}

# Initialize
mkdir -p "$LOG_DIR"
init_db

# Export functions for use in other scripts
export -f add_tokens
export -f get_consumption
export -f create_session
export -f format_tokens
export -f update_badge
export TRACKER_DB
