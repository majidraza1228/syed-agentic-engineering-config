ght() {
  # Initialize consumption tracking
  mkdir -p ~/.copilot/logs
  source ~/.copilot/consumption-tracker.sh
  local cwd="$PWD"
  local branch="$(git -C "$cwd" rev-parse --abbrev-ref HEAD 2>/dev/null || git -C "$cwd" rev-parse --short HEAD 2>/dev/null || echo detached)"
  osascript - "$cwd" "$branch" <<'EOF'
on run argv
  set cwd to item 1 of argv
  set branch to item 2 of argv
tell application "iTerm"
    set w to (create window with default profile)
    tell w
        set s1 to current session

        tell s1
            set s2 to (split vertically with default profile)
        end tell

        tell s1
            set s3 to (split horizontally with default profile)
        end tell

        tell s2
            set s4 to (split horizontally with default profile)
        end tell

        tell s1
            set name to branch & " | gpt-5-mini | high | 0/200k"
            write text "cd " & quoted form of cwd & " && printf '\\033]1337;SetBadgeFormat=%s\\a' $(printf 'gpt-5-mini\\nhigh effort\\n0k/200k' | base64) && copilot --model gpt-5-mini --effort high --name GPT5-High-1"
        end tell
        tell s2
            set name to branch & " | gpt-5-mini | high | 0/200k"
            write text "cd " & quoted form of cwd & " && printf '\\033]1337;SetBadgeFormat=%s\\a' $(printf 'gpt-5-mini\\nhigh effort\\n0k/200k' | base64) && copilot --model gpt-5-mini --effort high --name GPT5-High-2"
        end tell
        tell s3
            set name to branch & " | gpt-4.1 | medium | 0/128k"
            write text "cd " & quoted form of cwd & " && printf '\\033]1337;SetBadgeFormat=%s\\a' $(printf 'gpt-4.1\\nmedium effort\\n0k/128k' | base64) && copilot --model gpt-4.1 --effort medium --name GPT4-Medium"
        end tell
        tell s4
            set name to branch & " | claude-haiku-4.5 | low | 0/128k"
            write text "cd " & quoted form of cwd & " && printf '\\033]1337;SetBadgeFormat=%s\\a' $(printf 'claude-haiku-4.5\\nlow effort\\n0k/128k' | base64) && copilot --model claude-haiku-4.5 --effort low --name Haiku-Low"
        end tell
    end tell
end tell
end run
EOF
}