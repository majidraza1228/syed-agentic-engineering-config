# Quick Start Guide - GitHub Copilot CLI Workspace

## 🚀 One-Command Setup

Ready to use? Just type:

```bash
ght
```

That's it! Your 4-pane Copilot workspace launches instantly.

---

## 📋 What Happens When You Type `ght`

1. ✅ Opens iTerm2 with 4 panes (2x2 layout)
2. ✅ Launches Copilot CLI in each pane with different settings
3. ✅ Displays badges showing model, effort level, and token usage
4. ✅ Initializes token consumption tracking

---

## 🎯 Your 4 Panes

```
┌──────────────┬──────────────┐
│ Pane 1       │ Pane 2       │
│ GPT-5-Mini   │ GPT-5-Mini   │
│ High Effort  │ High Effort  │
├──────────────┼──────────────┤
│ Pane 3       │ Pane 4       │
│ GPT-4.1      │ Claude Haiku │
│ Medium       │ Low          │
└──────────────┴──────────────┘
```

Each pane shows: **Model | Effort | Tokens Used/Available**

---

## 📊 Log Token Usage

After using Copilot in any pane:

```bash
~/.copilot/log-consumption.sh "gpt5-high-1" 1500 2500
```

- First argument: Session ID (gpt5-high-1, gpt5-high-2, gpt4-medium, haiku-low)
- Second argument: Input tokens
- Third argument: Output tokens

The badge will update to show your consumption!

---

## 🛠️ Change Models (5 Easy Methods)

### Method 1: Edit shell.zsh (Easiest)
```bash
nano ~/syed-agentic-engineering-config/shell.zsh
# Find the ght() function and change --model gpt-5-mini to your model
# Reload: source ~/.zshrc
# Use: ght
```

### Method 2: Create Custom Script
Copy our template and customize models/effort levels before launching.

### Method 3: Available Models
```
gpt-5-mini         (latest, recommended)
gpt-4.1            (stable)
claude-haiku-4.5   (fast)
```

### Method 4: Effort Levels
```
low    (fast)
medium (balanced)
high   (thorough)
max    (maximum reasoning)
```

### Method 5: Full Documentation
See "Customizing Models & Effort Levels" in README.md

---

## 📖 Full Documentation

```bash
cat ~/.copilot/README.md
```

---

## ✅ Verify Everything Works

```bash
bash ~/.copilot/verify-setup.sh
```

---

## 🎮 Commands & Aliases

| Command | What It Does |
|---------|-------------|
| `ght` | Open Copilot workspace |
| `gwork` | Alias for ght |
| `~/.copilot/log-consumption.sh` | Log token usage |
| `source ~/.copilot/consumption-tracker.sh` | Access tracking functions |

---

## 🆘 Troubleshooting

**Problem:** `ght: command not found`
```bash
source ~/.zshrc
ght
```

**Problem:** Only 1-2 panes open
- Check if iTerm2 is your default terminal
- Try again: `ght`

**Problem:** Badges not showing
- Clear and recreate: `rm ~/.copilot/consumption.db`
- Relaunch: `ght`

**Problem:** Want to use different models
- See "Change Models" section above
- Edit `~/syed-agentic-engineering-config/shell.zsh`
- Reload and relaunch

---

## 🎓 Examples

### Example 1: Quick Session
```bash
# Open workspace
ght

# Use Pane 1 for complex task
# Then log tokens
~/.copilot/log-consumption.sh "gpt5-high-1" 2000 3000

# Badge updates to show usage
```

### Example 2: Multiple Tasks
```bash
ght

# Pane 1 (high effort): Deep analysis
~/.copilot/log-consumption.sh "gpt5-high-1" 1500 2500

# Pane 2 (high effort): Another complex task
~/.copilot/log-consumption.sh "gpt5-high-2" 1000 2000

# Pane 3 (medium): Balanced work
~/.copilot/log-consumption.sh "gpt4-medium" 800 1500

# Pane 4 (low): Quick queries
~/.copilot/log-consumption.sh "haiku-low" 200 500
```

### Example 3: Switch to Different Models
```bash
# Edit shell.zsh
nano ~/syed-agentic-engineering-config/shell.zsh

# Find: --model gpt-5-mini
# Replace: --model claude-opus-4
# Save

# Reload
source ~/.zshrc

# Launch
ght
```

---

## 📁 File Locations

```
Configuration:
  ~/.copilot/README.md                    (full docs)
  ~/.copilot/QUICK-START.md              (this file)
  ~/.copilot/verify-setup.sh             (verification)
  ~/syed-agentic-engineering-config/shell.zsh (defines ght)

Tracking:
  ~/.copilot/consumption.db              (token database)
  ~/.copilot/consumption-tracker.sh      (tracking engine)
  ~/.copilot/log-consumption.sh          (logging utility)

Logs:
  ~/.copilot/logs/                       (session logs)
```

---

## 🎯 Next Steps

1. **Type**: `ght`
2. **Use**: Copilot in any pane
3. **Log**: `~/.copilot/log-consumption.sh "session-id" input output`
4. **Watch**: Badges update with consumption
5. **Customize**: Edit models/effort as needed (see README.md)

---

**That's all you need to know to get started!** 🎉

For advanced usage, customization, and troubleshooting:
```bash
cat ~/.copilot/README.md
```
