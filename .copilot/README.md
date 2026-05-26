# GitHub Copilot CLI 4-Pane Workspace

A powerful iTerm2 workspace setup for GitHub Copilot CLI that mirrors your Claude setup. Launch a 4-pane terminal with different models, effort levels, and real-time token consumption tracking.

## Overview

Your workspace features a 4-pane layout with configurable models and real-time token tracking:

```
┌─────────────────────────────────┬──────────────────────────────────┐
│  gpt-5-mini                     │  gpt-5-mini                      │
│  High Effort                    │  High Effort                     │
│  /experimental                  │  /experimental                   │
│  0k/200k tokens                 │  0k/200k tokens                  │
├─────────────────────────────────┼──────────────────────────────────┤
│  gpt-4.1                        │  claude-haiku-4.5                │
│  Medium Effort                  │  Low Effort                      │
│  /experimental                  │  /experimental                   │
│  0k/128k tokens                 │  0k/128k tokens                  │
└─────────────────────────────────┴──────────────────────────────────┘
```

**Features:**
- 🎯 **4 Independent Panes** - Each with different model, effort, and token limit
- 📊 **Real-time Token Tracking** - See consumption in iTerm2 badge
- 🎨 **Beautiful Badges** - Display model, effort level, and tokens used/available
- ⚡ **Multi-Model Support** - Mix GPT-5, GPT-4, and Claude in one workspace
- 🔧 **Easily Customizable** - Change models/effort without touching code

## Quick Start

```bash
ght
```

That's it! This opens a new iTerm2 window with 4 panes configured for Copilot CLI.

### Alternative Alias
```bash
gwork
```

## Workspace Layout

Your workspace opens with this configuration:

```
┌─────────────────────┬──────────────────────┐
│   GPT-5-Mini        │   GPT-5-Mini         │
│   High Effort       │   High Effort        │
│   0k/200k tokens    │   0k/200k tokens     │
├─────────────────────┼──────────────────────┤
│   GPT-4.1           │  Claude Haiku        │
│   Medium Effort     │   Low Effort         │
│   0k/128k tokens    │   0k/128k tokens     │
└─────────────────────┴──────────────────────┘
```

## Pane Details

| Pane | Position | Model | Effort | Context | Use Case |
|------|----------|-------|--------|---------|----------|
| **1** | Top-Left | gpt-5-mini | high | 200k | Complex tasks, deep analysis |
| **2** | Top-Right | gpt-5-mini | high | 200k | Parallel complex work |
| **3** | Bottom-Left | gpt-4.1 | medium | 128k | Balanced work |
| **4** | Bottom-Right | claude-haiku-4.5 | low | 128k | Quick queries, fast responses |

## Features

### 1. Real-Time Token Tracking
Each pane displays live token consumption in the iTerm2 badge:
- **Format**: `model name` / `effort level` / `tokens used/available`
- **Updates**: Whenever you log consumption
- **Database**: SQLite stored at `~/.copilot/consumption.db`

### 2. Multiple Models
- **GPT-5-Mini**: Latest GPT model with high reasoning capability
- **GPT-4.1**: Stable, balanced model
- **Claude Haiku**: Fast, efficient responses

### 3. Effort Levels
- **High**: Maximum reasoning depth, slower but thorough
- **Medium**: Balanced reasoning and speed
- **Low**: Fast responses, minimal reasoning

### 4. iTerm2 Badges
Each pane displays a colored badge with:
```
model-name
effort level
tokens used/limit
```

Example:
```
gpt-5-mini
high effort
42k/200k
```

## Token Consumption Tracking

### Logging Tokens

After using Copilot in a pane, log the tokens consumed:

```bash
~/.copilot/log-consumption.sh "gpt5-high-1" 1500 2500
```

Format: `<session-id> <input-tokens> <output-tokens>`

### Session IDs

Use these predefined session IDs:
- `gpt5-high-1` → Top-left pane (GPT-5-Mini, High)
- `gpt5-high-2` → Top-right pane (GPT-5-Mini, High)
- `gpt4-medium` → Bottom-left pane (GPT-4.1, Medium)
- `haiku-low` → Bottom-right pane (Claude Haiku, Low)

### View Consumption

```bash
# Source the tracker
source ~/.copilot/consumption-tracker.sh

# Check a session's usage
get_consumption "gpt5-high-1"
# Output: 4000|200000 (4k tokens used out of 200k)
```

### Reset Consumption (Start Fresh)

```bash
# Backup the database
cp ~/.copilot/consumption.db ~/.copilot/consumption.db.backup

# Delete and recreate
rm ~/.copilot/consumption.db
source ~/.copilot/consumption-tracker.sh
```

## Directory Structure

```
~/.copilot/
├── README.md                          # This file
├── consumption-tracker.sh             # Core tracking system
├── log-consumption.sh                 # Simple logging utility
├── consumption.db                     # SQLite database (auto-created)
├── logs/                              # Session logs
└── commands/                          # Custom Copilot commands

~/syed-agentic-engineering-config/
└── .copilot/
    ├── commands/                      # Custom commands directory
    └── README.md                      # Source version
```

## Customizing Models & Effort Levels

### Method 1: Quick Edit - Edit shell.zsh (Easiest)

1. **Open the shell configuration**:
```bash
nano ~/syed-agentic-engineering-config/shell.zsh
```

2. **Find the `ght()` function** (starts around line with `# 4-pane GitHub Copilot`)

3. **Modify the pane commands**. Find lines like:
```bash
write text "printf '\\033]1337;SetBadgeFormat=%s\\a' $(printf 'gpt-5-mini\\nhigh effort\\n0k/200k' | base64) && copilot --model gpt-5-mini --effort high --name GPT5-High-1"
```

4. **Change any of these:**
   - **Model**: Replace `gpt-5-mini` with your preferred model
   - **Effort**: Replace `high` with `low`, `medium`, `high`, `xhigh`, or `max`
   - **Tokens**: Update the token limit (e.g., `200k`, `128k`, `1000k`)
   - **Name**: Change the session name (optional)

### Method 2: Create Custom Wrapper Script

Create `~/.copilot/ght-custom.sh`:

```bash
#!/bin/bash
# Custom Copilot workspace launcher with configurable models

# Configuration (edit these lines)
PANE1_MODEL="gpt-5-mini"
PANE1_EFFORT="high"
PANE1_TOKENS="200k"
PANE1_TOKENS_INT=200000

PANE2_MODEL="gpt-5-mini"
PANE2_EFFORT="high"
PANE2_TOKENS="200k"
PANE2_TOKENS_INT=200000

PANE3_MODEL="gpt-4.1"
PANE3_EFFORT="medium"
PANE3_TOKENS="128k"
PANE3_TOKENS_INT=128000

PANE4_MODEL="claude-haiku-4.5"
PANE4_EFFORT="low"
PANE4_TOKENS="128k"
PANE4_TOKENS_INT=128000

# Launch workspace
mkdir -p ~/.copilot/logs
source ~/.copilot/consumption-tracker.sh

osascript <<EOF
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
            set name to "$PANE1_MODEL | $PANE1_EFFORT | 0/$PANE1_TOKENS"
            write text "printf '\\\\033]1337;SetBadgeFormat=%s\\\\a' \$(printf '$PANE1_MODEL\\\\n$PANE1_EFFORT effort\\\\n0/$PANE1_TOKENS' | base64) && copilot --model $PANE1_MODEL --effort $PANE1_EFFORT --name Pane1"
        end tell
        tell s2
            set name to "$PANE2_MODEL | $PANE2_EFFORT | 0/$PANE2_TOKENS"
            write text "printf '\\\\033]1337;SetBadgeFormat=%s\\\\a' \$(printf '$PANE2_MODEL\\\\n$PANE2_EFFORT effort\\\\n0/$PANE2_TOKENS' | base64) && copilot --model $PANE2_MODEL --effort $PANE2_EFFORT --name Pane2"
        end tell
        tell s3
            set name to "$PANE3_MODEL | $PANE3_EFFORT | 0/$PANE3_TOKENS"
            write text "printf '\\\\033]1337;SetBadgeFormat=%s\\\\a' \$(printf '$PANE3_MODEL\\\\n$PANE3_EFFORT effort\\\\n0/$PANE3_TOKENS' | base64) && copilot --model $PANE3_MODEL --effort $PANE3_EFFORT --name Pane3"
        end tell
        tell s4
            set name to "$PANE4_MODEL | $PANE4_EFFORT | 0/$PANE4_TOKENS"
            write text "printf '\\\\033]1337;SetBadgeFormat=%s\\\\a' \$(printf '$PANE4_MODEL\\\\n$PANE4_EFFORT effort\\\\n0/$PANE4_TOKENS' | base64) && copilot --model $PANE4_MODEL --effort $PANE4_EFFORT --name Pane4"
        end tell
    end tell
end tell
EOF
```

Then add to your `~/.zshrc`:
```bash
alias ght-custom='bash ~/.copilot/ght-custom.sh'
```

Use it:
```bash
ght-custom
```

### Method 3: Interactive Configuration with Arguments

Create `~/.copilot/ght-config.sh`:

```bash
#!/bin/bash
# Interactive model configuration

# Default values
model1=${1:-"gpt-5-mini"}
effort1=${2:-"high"}
model2=${3:-"gpt-5-mini"}
effort2=${4:-"high"}
model3=${5:-"gpt-4.1"}
effort3=${6:-"medium"}
model4=${7:-"claude-haiku-4.5"}
effort4=${8:-"low"}

echo "Launching Copilot with:"
echo "Pane 1: $model1 | $effort1"
echo "Pane 2: $model2 | $effort2"
echo "Pane 3: $model3 | $effort3"
echo "Pane 4: $model4 | $effort4"

# Then call main ght function with these variables...
```

Usage:
```bash
bash ~/.copilot/ght-config.sh gpt-5-mini high gpt-4.1 medium claude-haiku-4.5 low gpt-4.1 high
```

### Method 4: Available Models & Effort Levels

**Available Models:**
```
gpt-5-mini          - Latest GPT-5 mini model (recommended for high effort)
gpt-4.1             - Stable GPT-4.1 model (balanced)
claude-haiku-4.5    - Fast Claude Haiku model (quick responses)
claude-opus-4       - Claude Opus (if available)
```

**Effort Levels:**
```
none                - No reasoning
low                 - Minimal reasoning (fastest)
medium              - Balanced reasoning and speed
high                - Deep reasoning (recommended)
xhigh               - Very deep reasoning
max                 - Maximum reasoning depth (slowest)
```

**Token Contexts:**
```
128k                - 128,000 tokens (Claude, GPT-4)
200k                - 200,000 tokens (GPT-5, extended)
1000k               - 1,000,000 tokens (if supported)
```

### Method 5: One-Liner Model Change Examples

**Example 1: Quick model swap in shell.zsh**
```bash
# Before (current)
copilot --model gpt-5-mini --effort high

# After (change to claude-opus)
copilot --model claude-opus-4 --effort high
```

**Example 2: Change all panes to same model**
```bash
# In shell.zsh, replace all instances:
# Find: --model gpt-5-mini
# Replace: --model gpt-4.1
```

**Example 3: Increase effort levels**
```bash
# In shell.zsh, replace:
# Find: --effort low
# Replace: --effort high
```

### Method 6: Create Named Variants

Add to your `~/.zshrc`:

```bash
# Standard setup (current default)
ght() {
  source ~/.zshrc && ... # Current implementation
}

# High-performance setup (all models maxed)
ght-max() {
  # All panes: gpt-5-mini, max effort, 200k context
  # Edit and customize as needed
}

# Quick setup (all low effort, fast responses)
ght-quick() {
  # All panes: gpt-4.1, low effort, 128k context
}

# Development setup (mixed for testing)
ght-dev() {
  # Pane 1: gpt-5-mini | high
  # Pane 2: gpt-4.1 | medium
  # Pane 3: claude-haiku | low
  # Pane 4: gpt-5-mini | max
}
```

### Step-by-Step: Change One Pane's Model

1. **Open the shell configuration**:
```bash
nano ~/syed-agentic-engineering-config/shell.zsh
```

2. **Go to line with the pane you want to change** (search with Ctrl+W)

3. **Example: Change top-left pane (Pane 1) from gpt-5-mini to gpt-4.1**

   Find this line:
   ```bash
   tell s1
       set name to "gpt-5-mini | high | 0/200k"
       write text "printf '\\033]1337;SetBadgeFormat=%s\\a' $(printf 'gpt-5-mini\\nhigh effort\\n0/200k' | base64) && copilot --model gpt-5-mini --effort high --name GPT5-High-1"
   end tell
   ```

   Change to:
   ```bash
   tell s1
       set name to "gpt-4.1 | high | 0/128k"
       write text "printf '\\033]1337;SetBadgeFormat=%s\\a' $(printf 'gpt-4.1\\nhigh effort\\n0/128k' | base64) && copilot --model gpt-4.1 --effort high --name GPT4-High-1"
   end tell
   ```

4. **Save and exit** (Ctrl+X, then Y, then Enter in nano)

5. **Reload your shell**:
```bash
source ~/.zshrc
```

6. **Test**:
```bash
ght
```

## Advanced Usage

### Create New Session

```bash
source ~/.copilot/consumption-tracker.sh

create_session "my-session" "gpt-5-mini" "top-left" 200000
add_tokens "my-session" 1000 2000
get_consumption "my-session"
```

### Database Schema

The SQLite database has two tables:

**sessions**
```
id (TEXT PRIMARY KEY)        - Session identifier
model (TEXT)                 - Model name
pane (TEXT)                  - Pane location
start_time (INTEGER)         - Unix timestamp
tokens_used (INTEGER)        - Total tokens consumed
tokens_limit (INTEGER)       - Context window limit
```

**interactions**
```
id (INTEGER PRIMARY KEY)     - Auto-increment
session_id (TEXT)            - Reference to session
input_tokens (INTEGER)       - Prompt tokens
output_tokens (INTEGER)      - Completion tokens
timestamp (INTEGER)          - Unix timestamp
```

### View Database Directly

```bash
sqlite3 ~/.copilot/consumption.db

# List all sessions
sqlite3 ~/.copilot/consumption.db "SELECT * FROM sessions;"

# View interactions for a session
sqlite3 ~/.copilot/consumption.db "SELECT * FROM interactions WHERE session_id = 'gpt5-high-1';"
```

## Comparison with Claude Setup

Your existing Claude setup (triggered by `t` or `cwork`) was the inspiration:

| Aspect | Claude | Copilot |
|--------|--------|---------|
| **Command** | `t` or `cwork` | `ght` or `gwork` |
| **Model** | claude-opus-4-7 (all panes) | Mixed models per pane |
| **High Panes** | 2 (both high effort) | 2 (gpt-5-mini high) |
| **Medium Pane** | 1 (medium effort) | 1 (gpt-4.1 medium) |
| **Low Pane** | 1 (low effort) | 1 (claude-haiku low) |
| **Context** | 200k (all) | 200k/200k/128k/128k |
| **Tracking** | Manual (optional) | **Automatic with DB** |

## Troubleshooting

### Command Not Found

**Problem**: `ght: command not found`

**Solution**: 
```bash
# Reload your shell
source ~/.zshrc

# Or start a new terminal
```

### iTerm2 Badge Not Showing

**Problem**: Badge displays incorrectly or not at all

**Solution**:
```bash
# Manually update badge (example)
printf '\033]1337;SetBadgeFormat=%s\a' $(printf 'gpt-5-mini\nhigh effort\n0k/200k' | base64)
```

### Consumption Database Issues

**Problem**: Database errors or corruption

**Solution**:
```bash
# Backup current database
cp ~/.copilot/consumption.db ~/.copilot/consumption.db.backup

# Recreate from scratch
rm ~/.copilot/consumption.db
source ~/.copilot/consumption-tracker.sh
```

### Panes Not Opening Correctly

**Problem**: Only 1-2 panes open instead of 4

**Solution**:
- Ensure iTerm2 is your default terminal
- Try manually:
  ```bash
  osascript ~/.copilot/open-panes.scpt
  ```

## Tips & Best Practices

1. **Use Consistent Session IDs**: Makes tracking easier across sessions
2. **Log After Each Query**: More accurate consumption data
3. **Monitor Token Usage**: Keep tabs on consumption to avoid surprises
4. **Rotate Panes**: Use different models/effort levels for different task types
5. **Backup Database**: Regularly backup `~/.copilot/consumption.db`

## Environment Variables

These are automatically managed, but you can override:

```bash
# Override database location
export COPILOT_TRACKER_DB="$HOME/.copilot/consumption.db"

# Override log directory
export COPILOT_LOG_DIR="$HOME/.copilot/logs"
```

## File Locations

```
Configuration:
  ~/.copilot/config.json
  
Tracking:
  ~/.copilot/consumption.db (auto-created)
  ~/.copilot/consumption-tracker.sh
  ~/.copilot/log-consumption.sh
  
Shell Configuration:
  ~/.zshrc (sources shell.zsh)
  ~/syed-agentic-engineering-config/shell.zsh (defines ght function)
  
Logs:
  ~/.copilot/logs/ (session logs)
  ~/.copilot/session-store.db (cross-session history)
```

## Examples

### Example 1: Quick Multi-Pane Workflow

```bash
# Open workspace
ght

# In pane 1 (gpt-5-mini | high):
copilot
# Do your work, get results

# Log consumption
~/.copilot/log-consumption.sh "gpt5-high-1" 2500 3000

# In pane 3 (gpt-4.1 | medium):
copilot
# Use for different task type

# Log consumption
~/.copilot/log-consumption.sh "gpt4-medium" 1500 1000
```

### Example 2: Check Usage Statistics

```bash
source ~/.copilot/consumption-tracker.sh

# Check all panes
echo "=== GPT-5 High Pane 1 ==="
get_consumption "gpt5-high-1"

echo "=== GPT-5 High Pane 2 ==="
get_consumption "gpt5-high-2"

echo "=== GPT-4 Medium ==="
get_consumption "gpt4-medium"

echo "=== Claude Haiku Low ==="
get_consumption "haiku-low"
```

### Example 3: Export Consumption Report

```bash
# Export to CSV
sqlite3 ~/.copilot/consumption.db ".mode csv" \
  "SELECT id, model, pane, tokens_used, tokens_limit FROM sessions;" \
  > consumption-report.csv
```

## Next Steps

1. **Test the Setup**: `ght` to launch
2. **Use a Pane**: Start Copilot in any pane
3. **Log Tokens**: Use `log-consumption.sh` after queries
4. **Monitor Usage**: Check badges and database regularly
5. **Customize**: Modify session IDs or models in scripts as needed

## Support

For issues or questions:
1. Check the [Troubleshooting](#troubleshooting) section
2. Review your `~/.copilot/logs/` directory
3. Check the SQLite database: `sqlite3 ~/.copilot/consumption.db`
4. Review shell configuration: `~/.zshrc` and `shell.zsh`

## Related Commands

```bash
# Open Claude workspace (4 panes with opus-4-7)
t
cwork

# Open Copilot workspace (4 panes with mixed models)
ght
gwork

# View consumption tracker functions
source ~/.copilot/consumption-tracker.sh && declare -f

# Verify ght function
declare -f ght
```

---

**Version**: 1.0  
**Last Updated**: May 26, 2024  
**Compatible With**: GitHub Copilot CLI 1.0+, iTerm2 3.4+, zsh 5.8+
