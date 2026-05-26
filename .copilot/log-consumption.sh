#!/bin/bash
# Log token consumption for a Copilot session
# Usage: log-consumption.sh <session-id> <input-tokens> <output-tokens>

source ~/.copilot/consumption-tracker.sh

session_id=$1
input_tokens=$2
output_tokens=$3

if [ -z "$session_id" ] || [ -z "$input_tokens" ] || [ -z "$output_tokens" ]; then
  echo "Usage: log-consumption.sh <session-id> <input-tokens> <output-tokens>"
  exit 1
fi

add_tokens "$session_id" "$input_tokens" "$output_tokens"
echo "Logged: $session_id - Input: $input_tokens, Output: $output_tokens"
