# agentic-config shell pieces
# Source of truth: ~/src/agentic-config/shell.zsh
# Sourced from ~/.zshrc by install.sh

# Prevent Ctrl-S / Ctrl-Q from freezing the terminal
stty -ixon 2>/dev/null

# 4-pane Claude workspace in one iTerm2 window
#   top-left  (s1): opus-4.7 | high
#   top-right (s2): opus-4.7 | high
#   bot-left  (s3): opus-4.7 | medium
#   bot-right (s4): opus-4.7 | low
t() {
  osascript <<'EOF'
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
            set name to "opus-4.7 | high | 200k ctx"
            write text "printf '\\033]1337;SetBadgeFormat=%s\\a' $(printf 'opus-4.7\\nhigh effort\\n200k ctx' | base64) && claude --model claude-opus-4-7 --effort high --name High-1"
        end tell
        tell s2
            set name to "opus-4.7 | high | 200k ctx"
            write text "printf '\\033]1337;SetBadgeFormat=%s\\a' $(printf 'opus-4.7\\nhigh effort\\n200k ctx' | base64) && claude --model claude-opus-4-7 --effort high --name High-2"
        end tell
        tell s3
            set name to "opus-4.7 | medium | 200k ctx"
            write text "printf '\\033]1337;SetBadgeFormat=%s\\a' $(printf 'opus-4.7\\nmedium effort\\n200k ctx' | base64) && claude --model claude-opus-4-7 --effort medium --name Medium"
        end tell
        tell s4
            set name to "opus-4.7 | low | 200k ctx"
            write text "printf '\\033]1337;SetBadgeFormat=%s\\a' $(printf 'opus-4.7\\nlow effort\\n200k ctx' | base64) && claude --model claude-opus-4-7 --effort low --name Low"
        end tell
    end tell
end tell
EOF
}

# 4-pane GitHub Copilot workspace in one iTerm2 window with token tracking
#   top-left  (s1): gpt-5-mini | high | 200k ctx
#   top-right (s2): gpt-5-mini | high | 200k ctx
#   bot-left  (s3): gpt-4.1 | medium | 128k ctx
#   bot-right (s4): claude-haiku-4.5 | low | 128k ctx
ght() {
  # Initialize consumption tracking
  mkdir -p ~/.copilot/logs
  source ~/.copilot/consumption-tracker.sh
  
  osascript <<'EOF'
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
            set name to "gpt-5-mini | high | 0/200k"
            write text "printf '\\033]1337;SetBadgeFormat=%s\\a' $(printf 'gpt-5-mini\\nhigh effort\\n0k/200k' | base64) && copilot --model gpt-5-mini --effort high --name GPT5-High-1"
        end tell
        tell s2
            set name to "gpt-5-mini | high | 0/200k"
            write text "printf '\\033]1337;SetBadgeFormat=%s\\a' $(printf 'gpt-5-mini\\nhigh effort\\n0k/200k' | base64) && copilot --model gpt-5-mini --effort high --name GPT5-High-2"
        end tell
        tell s3
            set name to "gpt-4.1 | medium | 0/128k"
            write text "printf '\\033]1337;SetBadgeFormat=%s\\a' $(printf 'gpt-4.1\\nmedium effort\\n0k/128k' | base64) && copilot --model gpt-4.1 --effort medium --name GPT4-Medium"
        end tell
        tell s4
            set name to "claude-haiku-4.5 | low | 0/128k"
            write text "printf '\\033]1337;SetBadgeFormat=%s\\a' $(printf 'claude-haiku-4.5\\nlow effort\\n0k/128k' | base64) && copilot --model claude-haiku-4.5 --effort low --name Haiku-Low"
        end tell
    end tell
end tell
EOF
}

alias cwork=t
alias gwork=ght
