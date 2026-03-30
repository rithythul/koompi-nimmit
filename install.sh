#!/usr/bin/env bash
set -euo pipefail

# koompi-nimmit installer
# One-command setup on fresh Ubuntu VPS or KOOMPI Mini
# Installs: node 22, bun, openclaw, chromium, xvfb, supabase CLI, git
# Sets up systemd services

REPO="rithythul/koompi-nimmit"
BRANCH="main"
INSTALL_DIR="$HOME/.nimmit"
BRAIN_DIR="$INSTALL_DIR/brain"
CONFIG_FILE="$INSTALL_DIR/openclaw.json"
VERSION="0.1.0"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

info()  { echo -e "${CYAN}[INFO]${NC}  $*"; }
ok()    { echo -e "${GREEN}[ OK ]${NC}  $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
die()   { echo -e "${RED}[ERR]${NC}   $*" >&2; exit 1; }
step()  { echo -e "\n${BOLD}${CYAN}▸${NC} ${BOLD}$*${NC}"; }

# ─── Args ──────────────────────────────────────────────────────────────

AGENT_NAME="Nimmit"
ORG_NAME=""
SLUG=""
BOT_TOKEN=""
CHANNEL="telegram"
SKIP_DEPS=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -n|--name) AGENT_NAME="$2"; shift 2 ;;
        -o|--org)  ORG_NAME="$2"; shift 2 ;;
        -s|--slug) SLUG="$2"; shift 2 ;;
        -t|--token) BOT_TOKEN="$2"; shift 2 ;;
        -c|--channel) CHANNEL="$2"; shift 2 ;;
        --skip-deps) SKIP_DEPS=true; shift ;;
        -h|--help)
            echo "Usage: $(basename "$0") [OPTIONS]"
            echo ""
            echo "Install koompi-nimmit — a turnkey AI agent appliance."
            echo ""
            echo "Options:"
            echo "  -n, --name NAME       Agent name (default: Nimmit)"
            echo "  -o, --org NAME        Organization name (required)"
            echo "  -s, --slug SLUG       URL-safe slug (default: derived from org)"
            echo "  -t, --token TOKEN     Telegram bot token"
            echo "  -c, --channel CHANNEL Primary channel: telegram|discord (default: telegram)"
            echo "  --skip-deps           Skip system dependency installation"
            echo "  -h, --help            Show this help"
            echo ""
            echo "Examples:"
            echo "  $(basename "$0") --name \"Atlas\" --org \"Acme Corp\" --token \"123456:ABC...\""
            exit 0 ;;
        *) die "Unknown option: $1" ;;
    esac
done

if [[ -z "$ORG_NAME" ]]; then
    die "Organization name required. Use --org \"Your Company\""
fi

SLUG="${SLUG:-$(echo "$ORG_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd '[:alnum:]-')}"
ALLOWED_IDS="[]"  # Client adds their Telegram user IDs after install

echo -e "\n${BOLD}${GREEN}🦅 koompi-nimmit installer v${VERSION}${NC}"
echo -e "${BOLD}   Agent: ${AGENT_NAME} | Org: ${ORG_NAME}${NC}\n"

# ─── Detect OS ─────────────────────────────────────────────────────────

detect_os() {
    if [[ -f /etc/arch-release ]] || grep -qi "koompi" /etc/os-release 2>/dev/null; then
        OS="arch"
        PKG_INSTALL="sudo pacman -S --noconfirm"
        PKG_LIST="git chromium curl unzip"
    elif [[ -f /etc/debian_version ]] || grep -qi ubuntu /etc/os-release 2>/dev/null; then
        OS="ubuntu"
        PKG_INSTALL="sudo DEBIAN_FRONTEND=noninteractive apt-get install -y"
        PKG_LIST="git chromium-browser curl unzip xvfb"
    else
        die "Unsupported OS. Requires Ubuntu 22.04+ or KOOMPI OS (Arch)."
    fi
    ok "Detected: ${OS}"
}

# ─── System dependencies ───────────────────────────────────────────────

install_deps() {
    step "Installing system dependencies"

    if [[ "$SKIP_DEPS" == true ]]; then
        warn "Skipping dependency installation (--skip-deps)"
        return
    fi

    # Check sudo
    if ! command -v sudo &>/dev/null; then
        die "sudo not found. Install it or run with --skip-deps."
    fi

    sudo mkdir -p /etc/apt/keyrings 2>/dev/null || true

    case "$OS" in
        ubuntu)
            # Add NodeSource repo for Node 22
            if ! command -v node &>/dev/null || [[ $(node --version | cut -d. -f1) -lt 22 ]]; then
                info "Installing Node.js 22..."
                curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg 2>/dev/null
                echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_22.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list > /dev/null
                sudo apt-get update -qq
            fi
            ;;
        arch)
            # Arch usually has current packages
            if ! command -v node &>/dev/null || [[ $(node --version | cut -d. -f1) -lt 22 ]]; then
                info "Updating system packages..."
                sudo pacman -Sy --noconfirm --quiet 2>/dev/null
            fi
            ;;
    esac

    $PKG_INSTALL $PKG_LIST 2>&1 | tail -3
    ok "System packages installed"
}

# ─── Node / Bun ────────────────────────────────────────────────────────

install_node() {
    step "Installing Node.js 22"

    if command -v node &>/dev/null && [[ $(node --version | cut -d. -f1) -ge 22 ]]; then
        ok "Node $(node --version) already installed"
        return
    fi

    # Fallback: use nvm
    if [[ -z "${NVM_DIR:-}" ]]; then
        export NVM_DIR="$HOME/.nvm"
    fi

    if [[ -s "$NVM_DIR/nvm.sh" ]]; then
        source "$NVM_DIR/nvm.sh"
    else
        info "Installing nvm..."
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
        source "$NVM_DIR/nvm.sh"
    fi

    nvm install 22
    nvm alias default 22
    nvm use default
    ok "Node $(node --version) installed"
}

install_bun() {
    step "Installing Bun"

    if command -v bun &>/dev/null; then
        ok "Bun $(bun --version) already installed"
        return
    fi

    curl -fsSL https://bun.sh/install | bash
    export BUN_INSTALL="$HOME/.bun"
    export PATH="$BUN_INSTALL/bin:$PATH"
    ok "Bun $(bun --version) installed"
}

# ─── OpenClaw ──────────────────────────────────────────────────────────

install_openclaw() {
    step "Installing OpenClaw"

    if command -v openclaw &>/dev/null; then
        ok "OpenClaw $(openclaw --version 2>/dev/null || echo 'installed') already installed"
        return
    fi

    bun install -g openclaw
    ok "OpenClaw installed"
}

# ─── Supabase CLI ──────────────────────────────────────────────────────

install_supabase() {
    step "Installing Supabase CLI"

    if command -v supabase &>/dev/null; then
        ok "Supabase CLI already installed"
        return
    fi

    case "$OS" in
        ubuntu)
            sudo snap install supabase 2>/dev/null || {
                curl -sSL https://storage.googleapis.com/supabase-cli-artifacts/supabase_2.latest_linux_amd64.deb -o /tmp/supabase.deb
                sudo dpkg -i /tmp/supabase.deb
                rm /tmp/supabase.deb
            }
            ;;
        arch)
            # Install via npm as fallback
            bun install -g supabase 2>/dev/null || npm install -g supabase
            ;;
    esac
    ok "Supabase CLI installed"
}

# ─── Chromium / Xvfb ───────────────────────────────────────────────────

install_browser() {
    step "Setting up headless browser"

    if command -v chromium &>/dev/null || command -v chromium-browser &>/dev/null || command -v google-chrome &>/dev/null; then
        ok "Chromium already installed"
    elif ! $SKIP_DEPS; then
        warn "Chromium not found. Run without --skip-deps or install manually."
    fi

    # Xvfb for headless rendering on servers without display
    if ! command -v Xvfb &>/dev/null && [[ "$OS" == "ubuntu" ]]; then
        sudo apt-get install -y xvfb 2>/dev/null
    fi
    ok "Browser environment ready"
}

# ─── Clone & configure ─────────────────────────────────────────────────

setup_brain() {
    step "Setting up ${AGENT_NAME}'s brain"

    if [[ -d "$INSTALL_DIR" ]]; then
        warn "$INSTALL_DIR exists. Backing up..."
        mv "$INSTALL_DIR" "${INSTALL_DIR}.bak.$(date +%s)"
    fi

    mkdir -p "$INSTALL_DIR"

    # Clone the repo to get templates
    local TMPDIR
    TMPDIR=$(mktemp -d)
    git clone --single-branch --branch "$BRANCH" --depth 1 "https://github.com/${REPO}.git" "$TMPDIR/koompi-nimmit" 2>/dev/null

    if [[ -d "$TMPDIR/koompi-nimmit/config" ]]; then
        # Copy config templates
        cp -r "$TMPDIR/koompi-nimmit/config/"* "$INSTALL_DIR/config/" 2>/dev/null || mkdir -p "$INSTALL_DIR/config"
        # Copy skills
        mkdir -p "$INSTALL_DIR/skills"
        cp -r "$TMPDIR/koompi-nimmit/skills/"* "$INSTALL_DIR/skills/" 2>/dev/null
        # Copy systemd files
        mkdir -p "$INSTALL_DIR/systemd"
        cp -r "$TMPDIR/koompi-nimmit/systemd/"* "$INSTALL_DIR/systemd/" 2>/dev/null
    fi

    rm -rf "$TMPDIR"

    # Create brain directory (workspace)
    mkdir -p "$BRAIN_DIR"/{memory/{semantic,procedural,decisions,episodic,failures,outcomes,working},projects,agents,tasks,tools}

    # Generate openclaw.json from template
    local TEMPLATE
    TEMPLATE="${INSTALL_DIR}/config/openclaw.template.json"
    if [[ -f "$TEMPLATE" ]]; then
        sed \
            -e "s/{{AGENT_NAME}}/${AGENT_NAME}/g" \
            -e "s/{{ORG_NAME}}/${ORG_NAME}/g" \
            -e "s/{{SLUG}}/${SLUG}/g" \
            -e "s/{{BOT_TOKEN}}/${BOT_TOKEN}/g" \
            -e "s/{{ALLOWED_IDS}}/${ALLOWED_IDS}/g" \
            -e "s/{{CHANNEL_TELEGRAM}}/$([ "$CHANNEL" = "telegram" ] && echo "true" || echo "false")/g" \
            -e "s/{{CHANNEL_DISCORD}}/$([ "$CHANNEL" = "discord" ] && echo "true" || echo "false")/g" \
            "$TEMPLATE" > "$CONFIG_FILE"
        ok "openclaw.json generated"
    else
        warn "Template not found, creating minimal config"
        generate_minimal_config
    fi

    # Generate brain files from templates
    for template_file in "$INSTALL_DIR"/config/*.template.md; do
        [[ -f "$template_file" ]] || continue
        local basename dest
        basename=$(basename "$template_file" .template.md)
        # SOUL.template.md → SOUL.md, tools.template.md → TOOLS.md, etc.
        dest="$BRAIN_DIR/${basename^^}.md"
        sed \
            -e "s/{{AGENT_NAME}}/${AGENT_NAME}/g" \
            -e "s/{{ORG_NAME}}/${ORG_NAME}/g" \
            -e "s/{{SLUG}}/${SLUG}/g" \
            "$template_file" > "$dest"
    done

    # IDENTITY.md is special — always generate fresh
    cat > "$BRAIN_DIR/IDENTITY.md" <<IDENTITY
# IDENTITY.md

- **Name:** ${AGENT_NAME}
- **What we are:** ${ORG_NAME}'s AI team
- **Installed:** $(date -Iseconds)
- **Channel:** ${CHANNEL}
- **Model:** zai/glm-5-turbo

_This file is yours to evolve._
IDENTITY

    ok "Brain files generated"
}

generate_minimal_config() {
    mkdir -p "$(dirname "$CONFIG_FILE")"
    cat > "$CONFIG_FILE" <<MINIMAL
{
  "agents": {
    "defaults": {
      "model": { "primary": "zai/glm-5-turbo" }
    },
    "list": [{
      "id": "main",
      "default": true,
      "workspace": "${BRAIN_DIR}",
      "identity": { "name": "${AGENT_NAME}", "emoji": "🦅" }
    }]
  },
  "tools": { "profile": "full" },
  "channels": {
    "telegram": {
      "enabled": $([ "$CHANNEL" = "telegram" ] && echo "true" || echo "false"),
      "botToken": "${BOT_TOKEN}",
      "allowFrom": ${ALLOWED_IDS},
      "groupPolicy": "allowlist"
    }
  },
  "gateway": {
    "port": 18789,
    "mode": "local",
    "bind": "loopback"
  }
}
MINIMAL
}

# ─── Systemd services ──────────────────────────────────────────────────

setup_services() {
    step "Setting up systemd services"

    local USER_HOME
    USER_HOME=$(eval echo "~$USER")

    # Create systemd user directory
    mkdir -p "$USER_HOME/.config/systemd/user"

    # Determine node and bun paths
    local NODE_PATH BUN_PATH OPENCLAW_PATH
    NODE_PATH=$(command -v node)
    BUN_PATH=$(command -v bun)
    OPENCLAW_PATH=$(command -v openclaw || echo "$BUN_PATH")
    export PATH="${NVM_DIR:-$HOME/.nvm}/versions/node/$(node --version)/bin:$BUN_INSTALL/bin:$PATH"

    # Xvfb service (for headless browser on servers)
    if command -v Xvfb &>/dev/null; then
        cat > "$USER_HOME/.config/systemd/user/xvfb.service" <<XVFB
[Unit]
Description=Xvfb virtual display for headless browser
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/Xvfb :99 -screen 0 1280x1024x24 -nolisten tcp
Restart=always
RestartSec=5

[Install]
WantedBy=default.target
XVFB
        systemctl --user daemon-reload
        systemctl --user enable xvfb.service
        ok "xvfb.service enabled"
    fi

    # OpenClaw gateway service
    local OPENCLAW_BIN
    OPENCLAW_BIN=$(command -v openclaw)
    local ENV_PATH="${NVM_DIR:-$HOME/.nvm}/versions/node/$(node --version)/bin"

    cat > "$USER_HOME/.config/systemd/user/openclaw.service" <<OPENCLAW_SVC
[Unit]
Description=OpenClaw AI Gateway — ${AGENT_NAME}
After=network.target xvfb.service
Wants=xvfb.service

[Service]
Type=simple
WorkingDirectory=${INSTALL_DIR}
Environment=DISPLAY=:99
Environment=PATH=${ENV_PATH}:${BUN_INSTALL}/bin:/usr/local/bin:/usr/bin:/bin
Environment=NIMMIT_HOME=${INSTALL_DIR}
ExecStart=${OPENCLAW_BIN} gateway start --foreground
Restart=always
RestartSec=5
RestartPreventExitStatus=SIGKILL

[Install]
WantedBy=default.target
OPENCLAW_SVC

    systemctl --user daemon-reload
    systemctl --user enable openclaw.service
    ok "openclaw.service enabled"

    # Enable lingering so services run without login
    loginctl enable-linger "$USER" 2>/dev/null || warn "Could not enable lingering (services may stop on logout)"
    ok "Lingering enabled"
}

# ─── Finalize ──────────────────────────────────────────────────────────

finalize() {
    # Init git repo
    cd "$INSTALL_DIR"
    git init -q
    git add -A
    git commit -q -m "${AGENT_NAME} for ${ORG_NAME} — installed by koompi-nimmit v${VERSION}"

    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}  🦅 ${AGENT_NAME} is ready for ${ORG_NAME}${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    info "Brain:    $BRAIN_DIR"
    info "Config:   $CONFIG_FILE"
    info "Channel:  ${CHANNEL}"
    info "Model:    zai/glm-5-turbo"
    echo ""

    if [[ -z "$BOT_TOKEN" ]]; then
        warn "No Telegram bot token provided."
        warn "1. Create a bot with @BotFather"
        warn "2. Edit: nano ${CONFIG_FILE}"
        warn "3. Add your Telegram user ID to allowFrom"
        warn "4. Restart: openclaw gateway restart"
        echo ""
    fi

    info "Start ${AGENT_NAME}:"
    echo -e "  ${CYAN}openclaw gateway start${NC}"
    echo ""
    info "Or start as a service (auto-restart on crash):"
    echo -e "  ${CYAN}systemctl --user start openclaw${NC}"
    echo ""
    info "View logs:"
    echo -e "  ${CYAN}journalctl --user -u openclaw -f${NC}"
    echo ""
}

# ─── Run ───────────────────────────────────────────────────────────────

main() {
    detect_os
    install_deps
    install_node
    install_bun
    install_openclaw
    install_supabase
    install_browser
    setup_brain
    setup_services
    finalize
}

main
