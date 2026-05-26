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
            set name to "opus-4.7 | high"
            write text "claude --model claude-opus-4-7 --effort high --name High-1"
        end tell
        tell s2
            set name to "opus-4.7 | high"
            write text "claude --model claude-opus-4-7 --effort high --name High-2"
        end tell
        tell s3
            set name to "opus-4.7 | medium"
            write text "claude --model claude-opus-4-7 --effort medium --name Medium"
        end tell
        tell s4
            set name to "opus-4.7 | low"
            write text "claude --model claude-opus-4-7 --effort low --name Low"
        end tell
    end tell
end tell
EOF
}

alias cwork=t
