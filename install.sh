#!/usr/bin/env bash
set -euo pipefail

# Nimmit — lightweight bootstrap installer
# Usage: curl -fsSL https://nimmit.koompi.ai/install | bash
#
# This script:
#   1. Ensures Node.js 22+ is available
#   2. Installs the 'nimmit' npm package globally
#   3. Runs 'nimmit onboard' for guided setup
#
# Security note: platform package installation uses sudo where needed.
# If you prefer not to pipe to shell, install Node.js 22+ manually then:
#   npm install -g @koompi/nimmit && nimmit onboard

info()  { echo -e "\033[0;36m[nimmit]\033[0m $1"; }
ok()    { echo -e "\033[0;32m[ok]\033[0m $1"; }
fail()  { echo -e "\033[0;31m[error]\033[0m $1"; exit 1; }

# ─── 1. Node.js 22+ ───
install_node() {
  if command -v node &>/dev/null; then
    NODE_VER=$(node -v | sed 's/v//' | cut -d. -f1)
    if (( NODE_VER >= 22 )); then
      ok "Node.js $(node -v)"
      return
    fi
    info "Node.js v$(node -v) found, but 22+ required."
  else
    info "Node.js not found."
  fi

  info "Installing Node.js 22..."

  if [[ "$(uname)" == "Darwin" ]]; then
    if command -v brew &>/dev/null; then
      brew install node@22 2>&1 | tail -1
    else
      fail "Install Node.js 22+: https://nodejs.org/"
    fi
  elif [[ -f /etc/debian_version ]]; then
    curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash - 2>/dev/null
    sudo apt-get install -y nodejs 2>/dev/null
  elif [[ -f /etc/fedora-release ]] || [[ -f /etc/redhat-release ]]; then
    curl -fsSL https://rpm.nodesource.com/setup_22.x | sudo -E bash - 2>/dev/null
    sudo dnf install -y nodejs 2>/dev/null || sudo yum install -y nodejs 2>/dev/null
  elif command -v pacman &>/dev/null; then
    sudo pacman -S --noconfirm nodejs npm 2>/dev/null
  else
    if ! command -v nvm &>/dev/null; then
      curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash
      export NVM_DIR="$HOME/.nvm"
      [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
    fi
    nvm install 22
  fi

  command -v node &>/dev/null || fail "Node.js installation failed. Install manually: https://nodejs.org/"

  NODE_VER=$(node -v | sed 's/v//' | cut -d. -f1)
  (( NODE_VER >= 22 )) || fail "Node.js 22+ required, got $(node -v)"
  ok "Node.js $(node -v)"
}

install_node

# ─── 2. npm check ───
command -v npm &>/dev/null || fail "npm not found. Install Node.js from https://nodejs.org/"

# ─── 3. Install nimmit ───
info "Installing nimmit..."
npm install -g @koompi/nimmit 2>&1 | tail -3
ok "nimmit installed"

# ─── 4. Run onboard ───
echo ""
info "Starting guided setup..."
echo ""
nimmit onboard
