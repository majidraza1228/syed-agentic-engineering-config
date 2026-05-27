#!/usr/bin/env bash
set -eu
echo "Installing Copilot workspace dependencies: tmux, jq, sqlite3, git, gawk"

if command -v brew >/dev/null 2>&1; then
  brew install tmux jq sqlite3 git gawk || true
  exit 0
fi

if [ -f /etc/os-release ]; then
  . /etc/os-release
  case "$ID" in
    centos|rhel|fedora)
      sudo dnf install -y epel-release || true
      sudo dnf install -y tmux jq sqlite sqlite-devel git gawk || true
      ;;
    ubuntu|debian)
      sudo apt-get update
      sudo apt-get install -y tmux jq sqlite3 git gawk || true
      ;;
    *)
      echo "Unknown Linux distro ($ID). Please install tmux, jq, sqlite3, git, gawk manually."
      ;;
  esac
else
  echo "Unsupported OS. Please install tmux, jq, sqlite3, git, gawk manually."
fi
echo "Done."
