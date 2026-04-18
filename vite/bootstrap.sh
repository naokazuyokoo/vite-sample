#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

STEP_NUMBER=0

print_separator() {
  echo "----------------------------------------------------------------"
}

print_step_result() {
  local message="$1"
  echo "[Result] ${message}"
  print_separator
  echo ""
}

confirm_yes_no() {
  local message="$1"
  local ans=""
  while true; do
    read -r -p "$message (y/n): " ans
    case "$ans" in
      y|Y) return 0 ;;
      n|N) return 1 ;;
      *) echo "Please enter y or n." ;;
    esac
  done
}

confirm_block() {
  local description="$1"
  local commands="$2"
  STEP_NUMBER=$((STEP_NUMBER + 1))
  echo ""
  print_separator
  printf '[Step %02d]\n' "$STEP_NUMBER"
  print_separator
  echo "[Description]"
  printf '%s\n' "$description"
  echo ""
  echo "[Commands]"
  printf '%s\n' "$commands"
  print_separator
  if confirm_yes_no "Proceed with this step?"; then
    echo "[Action] Run"
    print_separator
    return 0
  fi
  echo "[Action] Skip"
  print_separator
  echo "Skipped."
  echo ""
  return 1
}

load_brew_shellenv_if_available() {
  if command -v brew >/dev/null 2>&1; then
    return 0
  fi

  if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
    return 0
  fi

  if [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
    return 0
  fi

  return 1
}

append_line_if_missing() {
  local file_path="$1"
  local line="$2"

  touch "$file_path"
  if ! grep -Fqx "$line" "$file_path"; then
    echo "$line" >> "$file_path"
  fi
}

echo "Bootstrap start: ${SCRIPT_DIR}"

load_brew_shellenv_if_available || true

if ! command -v brew >/dev/null 2>&1; then
  if confirm_block \
    "Install Homebrew because 'brew' command is not available." \
    '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
echo '\''eval "$(/opt/homebrew/bin/brew shellenv)"'\'' >> ~/.zshrc
eval "$(/opt/homebrew/bin/brew shellenv)"'; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    if [ -x /opt/homebrew/bin/brew ]; then
      append_line_if_missing "$HOME/.zshrc" 'eval "$(/opt/homebrew/bin/brew shellenv)"'
      eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -x /usr/local/bin/brew ]; then
      append_line_if_missing "$HOME/.zshrc" 'eval "$(/usr/local/bin/brew shellenv)"'
      eval "$(/usr/local/bin/brew shellenv)"
    fi

    if ! command -v brew >/dev/null 2>&1; then
      echo "Homebrew installation appears to have failed. Please install manually and rerun."
      exit 1
    fi

    print_step_result "Homebrew installed."
  else
    echo "Homebrew is required. Exiting."
    exit 1
  fi
else
  echo "Homebrew is already installed."
fi

if ! brew list --formula fnm >/dev/null 2>&1; then
  if confirm_block \
    "Install fnm using Homebrew." \
    "brew install fnm"; then
    brew install fnm
    print_step_result "fnm installed."
  else
    echo "fnm is required. Exiting."
    exit 1
  fi
else
  echo "fnm is already installed."
fi

ZSHRC_FILE="$HOME/.zshrc"
FNM_ENV_LINE='eval "$(fnm env --use-on-cd --shell zsh)"'

if confirm_block \
  "Add fnm settings to ~/.zshrc if missing." \
  "echo '$FNM_ENV_LINE' >> ~/.zshrc"; then
  append_line_if_missing "$ZSHRC_FILE" "$FNM_ENV_LINE"
  print_step_result "~/.zshrc updated."
else
  echo "Skipped .zshrc update."
fi

if command -v fnm >/dev/null 2>&1; then
  eval "$(fnm env --shell bash)"

  if ! command -v node >/dev/null 2>&1; then
    if confirm_block \
      "Install latest LTS Node.js via fnm because 'node' command is not available." \
      "fnm install --lts
fnm default lts-latest
fnm use lts-latest"; then
      fnm install --lts
      fnm default lts-latest
      fnm use lts-latest
      print_step_result "Node.js LTS installed and activated."
    else
      echo "Node.js is required for npm commands. Exiting."
      exit 1
    fi
  else
    echo "Node.js is already available: $(node -v)"
  fi
else
  echo "fnm command not found after installation. Exiting."
  exit 1
fi

if confirm_block \
  "Install npm dependencies in this Vite directory." \
  "npm install"; then
  npm install
  print_step_result "npm install completed."
else
  echo "Skipped npm install."
fi

if confirm_block \
  "Start frontend development server." \
  "npm run dev"; then
  npm run dev
  print_step_result "npm run dev completed."
else
  echo "Skipped npm run dev."
fi

if confirm_block \
  "Reload ~/.zshrc for the current login shell (to make npm available after this script)." \
  "zsh -ic 'source ~/.zshrc'"; then
  if command -v zsh >/dev/null 2>&1; then
    # This reloads zsh config in a child zsh process only.
    zsh -ic 'source ~/.zshrc'
    print_step_result "~/.zshrc reloaded in child zsh. If npm is still unavailable in your current terminal, run: source ~/.zshrc"
  else
    echo "zsh is not available. Run this manually in your terminal: source ~/.zshrc"
    print_separator
    echo ""
  fi
else
  echo "Skipped ~/.zshrc reload."
fi

echo "Bootstrap finished."
