#!/bin/bash
# Verify GitHub Copilot CLI workspace setup

echo "🔍 GitHub Copilot CLI Setup Verification"
echo "=========================================="
echo ""

# Check 1: Required files
echo "✓ Checking required files..."
files=(
  "~/.copilot/consumption-tracker.sh"
  "~/.copilot/log-consumption.sh"
  "~/.copilot/README.md"
  "~/.zshrc"
)

for file in "${files[@]}"; do
  expanded_file="${file/#\~/$HOME}"
  if [ -f "$expanded_file" ]; then
    echo "  ✅ $file"
  else
    echo "  ❌ $file (MISSING)"
  fi
done

echo ""

# Check 2: Database
echo "✓ Checking database..."
if [ -f ~/.copilot/consumption.db ]; then
  echo "  ✅ Database exists: ~/.copilot/consumption.db"
  echo "  📊 Tables:"
  sqlite3 ~/.copilot/consumption.db ".tables" | sed 's/^/     /'
else
  echo "  ⚠️  Database not created yet (will be created on first use)"
fi

echo ""

# Check 3: Shell configuration
echo "✓ Checking shell configuration..."
if grep -q "source.*shell.zsh" ~/.zshrc; then
  echo "  ✅ shell.zsh is sourced in ~/.zshrc"
else
  echo "  ⚠️  shell.zsh may not be sourced"
fi

if grep -q "^ght()" ~/syed-agentic-engineering-config/shell.zsh; then
  echo "  ✅ ght() function defined in shell.zsh"
else
  echo "  ❌ ght() function not found"
fi

if grep -q "^alias gwork=ght" ~/syed-agentic-engineering-config/shell.zsh; then
  echo "  ✅ gwork alias defined"
else
  echo "  ⚠️  gwork alias not found"
fi

echo ""

# Check 4: Copilot CLI
echo "✓ Checking Copilot CLI..."
if command -v copilot &> /dev/null; then
  echo "  ✅ Copilot CLI installed"
  copilot --version 2>/dev/null | sed 's/^/     Version: /'
else
  echo "  ❌ Copilot CLI not found in PATH"
fi

echo ""

# Check 5: Dependencies
echo "✓ Checking dependencies..."
if command -v osascript &> /dev/null; then
  echo "  ✅ osascript (iTunes scripting) available"
else
  echo "  ❌ osascript not found (macOS only)"
fi

if command -v sqlite3 &> /dev/null; then
  echo "  ✅ sqlite3 available"
else
  echo "  ❌ sqlite3 not found"
fi

if command -v base64 &> /dev/null; then
  echo "  ✅ base64 available"
else
  echo "  ⚠️  base64 not found"
fi

echo ""

# Check 6: iTerm2
echo "✓ Checking iTerm2..."
if [ -d "/Applications/iTerm.app" ]; then
  echo "  ✅ iTerm2 installed"
else
  echo "  ❌ iTerm2 not found at /Applications/iTerm.app"
fi

echo ""
echo "=========================================="
echo "Setup Verification Complete!"
echo ""
echo "To start using:"
echo "  zsh"
echo "  ght"
echo ""
echo "For help, see:"
echo "  cat ~/.copilot/README.md"
