#!/usr/bin/env bash
set -euo pipefail

# OpenClaw Agent Template installer v4.0.0
# Deploys an OpenClaw AI agent from the brain/ template.
#
# Interactive:
#   curl -fsSL https://raw.githubusercontent.com/koompi/koompi-nimmit/master/install.sh | bash
#
# Non-interactive (CI/automation):
#   bash install.sh --non-interactive --name "Atlas" --org "Acme" --token "123:ABC..."

VERSION="4.0.0"
REPO="koompi/koompi-nimmit"
BRANCH="master"

# Install paths
OPENCLAW_DIR="$HOME/.openclaw"
BRAIN_DIR=""
CONFIG_FILE="$OPENCLAW_DIR/openclaw.json"
ENV_FILE=""

# Colors
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'
BLUE='\033[0;34m'; MAGENTA='\033[0;35m'; DIM='\033[2m'
BOLD='\033[1m'; NC='\033[0m'

info()  { echo -e "${CYAN}[INFO]${NC}  $*"; }
ok()    { echo -e "${GREEN}[ OK ]${NC}  $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
die()   { echo -e "${RED}[ERR]${NC}   $*" >&2; exit 1; }
step()  { echo -e "\n${BOLD}${CYAN}>>>>${NC} ${BOLD}$*${NC}"; }

# ─── Prompt helpers ────────────────────────────────────────────────────

# When piped from curl, stdin is the script. Reattach to terminal for prompts.
if [[ ! -t 0 ]] && [[ -e /dev/tty ]]; then
    exec 3</dev/tty  # open fd 3 from terminal
    HAS_TTY=true
elif [[ -t 0 ]]; then
    exec 3<&0         # fd 3 = stdin (already a terminal)
    HAS_TTY=true
else
    HAS_TTY=false
fi

# ask "prompt" "default" → sets REPLY
ask() {
    local prompt="$1" default="${2:-}"
    if [[ -n "$default" ]]; then
        echo -en "  ${BOLD}${prompt}${NC} ${DIM}[${default}]${NC}: " >&2
        read -r REPLY <&3
        REPLY="${REPLY:-$default}"
    else
        echo -en "  ${BOLD}${prompt}${NC}: " >&2
        read -r REPLY <&3
    fi
}

# ask_secret "prompt" → sets REPLY (input hidden)
ask_secret() {
    local prompt="$1"
    echo -en "  ${BOLD}${prompt}${NC}: " >&2
    read -rs REPLY <&3
    echo "" >&2
}

# ask_yn "prompt" "default y/n" → returns 0 for yes, 1 for no
ask_yn() {
    local prompt="$1" default="${2:-y}"
    local hint="Y/n"
    [[ "$default" == "n" ]] && hint="y/N"
    echo -en "  ${BOLD}${prompt}${NC} ${DIM}[${hint}]${NC}: " >&2
    read -r REPLY <&3
    REPLY="${REPLY:-$default}"
    [[ "$REPLY" =~ ^[Yy] ]]
}

# ask_choice "prompt" "opt1|opt2|opt3" "default" → sets REPLY
ask_choice() {
    local prompt="$1" options="$2" default="$3"
    echo -e "  ${BOLD}${prompt}${NC} ${DIM}(${options})${NC} ${DIM}[${default}]${NC}: " >&2
    read -r REPLY <&3
    REPLY="${REPLY:-$default}"
}

# ─── Variables ─────────────────────────────────────────────────────────

AGENT_NAME=""
ORG_NAME=""
SLUG=""
OWNER_NAME=""
OWNER_ID=""
BOT_TOKEN=""
GOOGLE_API_KEY=""
ZAI_API_KEY=""
COPILOT_TOKEN=""
CHANNEL="telegram"
TIMEZONE=""
LANGUAGE="en"
SKIP_DEPS=false
DIVISIONS=false
PRIMARY_MODEL="google/gemini-3.1-pro-preview"
NON_INTERACTIVE=false

# ─── Parse CLI flags (for non-interactive / CI) ───────────────────────

while [[ $# -gt 0 ]]; do
    case $1 in
        --name)             AGENT_NAME="$2"; shift 2 ;;
        --org)              ORG_NAME="$2"; shift 2 ;;
        --slug)             SLUG="$2"; shift 2 ;;
        --owner)            OWNER_NAME="$2"; shift 2 ;;
        --owner-id)         OWNER_ID="$2"; shift 2 ;;
        --token|--telegram-token) BOT_TOKEN="$2"; shift 2 ;;
        --google-key)       GOOGLE_API_KEY="$2"; shift 2 ;;
        --zai-key)          ZAI_API_KEY="$2"; shift 2 ;;
        --copilot-token)    COPILOT_TOKEN="$2"; shift 2 ;;
        --channel)          CHANNEL="$2"; shift 2 ;;
        --timezone)         TIMEZONE="$2"; shift 2 ;;
        --language)         LANGUAGE="$2"; shift 2 ;;
        --model)            PRIMARY_MODEL="$2"; shift 2 ;;
        --skip-deps)        SKIP_DEPS=true; shift ;;
        --divisions)        DIVISIONS=true; shift ;;
        --non-interactive)  NON_INTERACTIVE=true; shift ;;
        --uninstall)        uninstall; exit 0 ;;
        -h|--help)
            cat <<HELP
Usage: bash install.sh [OPTIONS]

Deploy a turnkey AI agent powered by OpenClaw.
Runs interactively by default. Pass --non-interactive for CI.

Options:
  --name NAME             Agent name (e.g. "Nimmit")
  --org NAME              Organization name
  --owner NAME            Owner's display name
  --owner-id ID           Owner's Telegram user ID
  --token TOKEN           Telegram bot token
  --google-key KEY        Google AI API key (Gemini)
  --zai-key KEY           ZAI API key
  --copilot-token TOKEN   GitHub Copilot token
  --model MODEL           Primary chat model
  --channel CHANNEL       telegram|discord (default: telegram)
  --timezone TZ           Timezone (default: auto-detect)
  --language LANG         Language code (default: en)
  --skip-deps             Skip system packages
  --divisions             Enable all 9 divisions
  --non-interactive       Skip all prompts (use flags only)
  --uninstall             Remove installation
  -h, --help              Show this help
HELP
            exit 0 ;;
        -*)
            if [[ "$1" == *=* ]]; then
                key="${1%%=*}"; val="${1#*=}"
                shift; set -- "$key" "$val" "$@"
            else
                die "Unknown option: $1"
            fi
            ;;
        *)
            if [[ -z "$AGENT_NAME" ]]; then
                AGENT_NAME="$1"; shift
            else
                die "Unknown argument: $1"
            fi
            ;;
    esac
done

# ─── Auto-detect timezone ─────────────────────────────────────────────

detect_timezone() {
    if [[ -n "$TIMEZONE" ]]; then return; fi
    if [[ -f /etc/timezone ]]; then
        TIMEZONE=$(cat /etc/timezone)
    elif command -v timedatectl &>/dev/null; then
        TIMEZONE=$(timedatectl show --property=Timezone --value 2>/dev/null || echo "UTC")
    else
        TIMEZONE="UTC"
    fi
}

# ─── Interactive wizard ────────────────────────────────────────────────

interactive_setup() {
    echo ""
    echo -e "${BOLD}${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}${MAGENTA}  OpenClaw Agent Template — Installer v${VERSION}${NC}"
    echo -e "${BOLD}${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "  ${DIM}This will set up an AI agent on this machine.${NC}"
    echo -e "  ${DIM}It installs Node.js, Bun, OpenClaw, and configures your agent brain.${NC}"
    echo -e "  ${DIM}Press Ctrl+C at any time to cancel.${NC}"
    echo ""

    # ── Step 1: Agent identity ──
    echo -e "${BOLD}${BLUE}  Step 1/5: Agent Identity${NC}"
    echo -e "  ${DIM}Choose a name and company for your AI agent.${NC}"
    echo ""

    ask "Agent name" "${AGENT_NAME:-Nimmit}"
    AGENT_NAME="$REPLY"

    ask "Company / Organization" "${ORG_NAME:-$AGENT_NAME}"
    ORG_NAME="$REPLY"

    SLUG="${SLUG:-$(echo "$AGENT_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd '[:alnum:]-')}"

    echo ""

    # ── Step 2: Owner ──
    echo -e "${BOLD}${BLUE}  Step 2/5: Owner${NC}"
    echo -e "  ${DIM}Who owns this agent? This is used for access control.${NC}"
    echo ""

    ask "Your name" "${OWNER_NAME:-}"
    OWNER_NAME="$REPLY"

    ask "Your Telegram user ID" "${OWNER_ID:-}"
    OWNER_ID="$REPLY"
    if [[ -z "$OWNER_ID" ]]; then
        echo -e "  ${DIM}Tip: Send /start to @userinfobot on Telegram to get your ID.${NC}"
        ask "Your Telegram user ID"
        OWNER_ID="$REPLY"
    fi

    detect_timezone
    ask "Timezone" "$TIMEZONE"
    TIMEZONE="$REPLY"

    ask "Language" "${LANGUAGE:-en}"
    LANGUAGE="$REPLY"

    echo ""

    # ── Step 3: Telegram bot ──
    echo -e "${BOLD}${BLUE}  Step 3/5: Telegram Bot${NC}"
    echo -e "  ${DIM}Your agent needs a Telegram bot to communicate.${NC}"
    echo -e "  ${DIM}Create one at https://t.me/BotFather if you don't have one.${NC}"
    echo ""

    if [[ -z "$BOT_TOKEN" ]]; then
        ask_secret "Bot token (from @BotFather, hidden)"
        BOT_TOKEN="$REPLY"
    else
        echo -e "  ${DIM}Bot token: provided via flag${NC}"
    fi

    if [[ -z "$BOT_TOKEN" ]]; then
        warn "No bot token. You can add it later to the .env file."
    fi

    echo ""

    # ── Step 4: AI models ──
    echo -e "${BOLD}${BLUE}  Step 4/5: AI Models${NC}"
    echo -e "  ${DIM}Your agent needs at least one AI model API key.${NC}"
    echo -e "  ${DIM}Models are swappable — you can change them anytime after install.${NC}"
    echo ""
    echo -e "  ${DIM}Available providers:${NC}"
    echo -e "    ${CYAN}1${NC}  Google Gemini  ${DIM}— recommended, get key at https://aistudio.google.com/apikey${NC}"
    echo -e "    ${CYAN}2${NC}  GitHub Copilot ${DIM}— if you have a Copilot subscription${NC}"
    echo -e "    ${CYAN}3${NC}  ZAI (GLM)      ${DIM}— alternative provider${NC}"
    echo ""

    if [[ -z "$GOOGLE_API_KEY" ]]; then
        ask_secret "Google AI API key (recommended, or press Enter to skip)"
        GOOGLE_API_KEY="$REPLY"
    fi

    if [[ -z "$COPILOT_TOKEN" ]]; then
        ask_secret "GitHub Copilot token (or press Enter to skip)"
        COPILOT_TOKEN="$REPLY"
    fi

    if [[ -z "$ZAI_API_KEY" ]]; then
        ask_secret "ZAI API key (or press Enter to skip)"
        ZAI_API_KEY="$REPLY"
    fi

    if [[ -z "$GOOGLE_API_KEY" && -z "$COPILOT_TOKEN" && -z "$ZAI_API_KEY" ]]; then
        echo ""
        warn "No API keys provided. Your agent won't be able to respond until you add one."
        warn "You can add keys later: nano ~/.openclaw/${SLUG}/.env"
    fi

    # Set primary model based on what keys are available
    if [[ -n "$GOOGLE_API_KEY" ]]; then
        PRIMARY_MODEL="google/gemini-3.1-pro-preview"
    elif [[ -n "$COPILOT_TOKEN" ]]; then
        PRIMARY_MODEL="github-copilot/claude-sonnet-4.6"
    elif [[ -n "$ZAI_API_KEY" ]]; then
        PRIMARY_MODEL="zai/glm-5"
    fi

    echo ""

    # ── Step 5: Options ──
    echo -e "${BOLD}${BLUE}  Step 5/5: Options${NC}"
    echo ""

    if ask_yn "Enable all 9 departments?" "n"; then
        DIVISIONS=true
    fi

    echo ""

    # ── Confirm ──
    echo -e "${BOLD}${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}  Review your setup:${NC}"
    echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "  Agent:       ${BOLD}${AGENT_NAME}${NC}"
    echo -e "  Company:     ${BOLD}${ORG_NAME}${NC}"
    echo -e "  Owner:       ${BOLD}${OWNER_NAME}${NC} (ID: ${OWNER_ID:-not set})"
    echo -e "  Timezone:    ${BOLD}${TIMEZONE}${NC}"
    echo -e "  Model:       ${BOLD}${PRIMARY_MODEL}${NC}"
    echo -e "  Bot token:   ${BOLD}$([ -n "$BOT_TOKEN" ] && echo "set" || echo "not set")${NC}"
    echo -e "  Google key:  ${BOLD}$([ -n "$GOOGLE_API_KEY" ] && echo "set" || echo "not set")${NC}"
    echo -e "  Copilot:     ${BOLD}$([ -n "$COPILOT_TOKEN" ] && echo "set" || echo "not set")${NC}"
    echo -e "  ZAI key:     ${BOLD}$([ -n "$ZAI_API_KEY" ] && echo "set" || echo "not set")${NC}"
    echo -e "  Divisions:   ${BOLD}$([ "$DIVISIONS" == true ] && echo "yes (9)" || echo "no")${NC}"
    echo -e "  Install to:  ${BOLD}~/.openclaw/${SLUG}/${NC}"
    echo ""

    if ! ask_yn "Proceed with installation?" "y"; then
        echo -e "\n  ${DIM}Installation cancelled.${NC}\n"
        exit 0
    fi

    echo ""
}

# ─── Detect OS ─────────────────────────────────────────────────────────

detect_os() {
    if [[ -f /etc/arch-release ]] || grep -qi "koompi" /etc/os-release 2>/dev/null; then
        OS="arch"
        PKG_INSTALL="sudo pacman -S --noconfirm --quiet"
        PKG_LIST="git chromium curl unzip base-devel"
    elif [[ -f /etc/debian_version ]] || grep -qi ubuntu /etc/os-release 2>/dev/null; then
        OS="ubuntu"
        PKG_INSTALL="sudo DEBIAN_FRONTEND=noninteractive apt-get install -y"
        PKG_LIST="git chromium-browser curl unzip xvfb"
    else
        die "Unsupported OS. Requires Ubuntu 22.04+ or KOOMPI OS (Arch-based)."
    fi
    ok "Detected: ${OS} ($(uname -m))"
}

# ─── System dependencies ───────────────────────────────────────────────

install_deps() {
    step "Installing system dependencies"

    if [[ "$SKIP_DEPS" == true ]]; then
        warn "Skipping (--skip-deps)"
        return
    fi

    case "$OS" in
        ubuntu)
            sudo mkdir -p /etc/apt/keyrings 2>/dev/null || true
            if ! command -v node &>/dev/null || [[ $(node -v | cut -d. -f1 | tr -d v) -lt 22 ]]; then
                info "Adding Node.js 22 repository..."
                curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | \
                    sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg 2>/dev/null
                echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_22.x nodistro main" | \
                    sudo tee /etc/apt/sources.list.d/nodesource.list > /dev/null
                sudo apt-get update -qq
            fi
            ;;
        arch)
            sudo pacman -Sy --noconfirm --quiet 2>/dev/null || true
            ;;
    esac

    info "Installing: ${PKG_LIST}"
    $PKG_INSTALL $PKG_LIST 2>&1 | tail -5
    ok "System packages installed"
}

# ─── Runtimes ──────────────────────────────────────────────────────────

install_runtimes() {
    step "Installing Node.js + Bun"

    # Node via nvm
    if command -v node &>/dev/null && [[ $(node -v | cut -d. -f1 | tr -d v) -ge 22 ]]; then
        ok "Node $(node -v) already installed"
    else
        export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
        if [[ -s "$NVM_DIR/nvm.sh" ]]; then
            source "$NVM_DIR/nvm.sh"
        else
            info "Installing nvm..."
            curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
            source "$NVM_DIR/nvm.sh"
        fi
        nvm install 22 && nvm alias default 22 && nvm use default
        ok "Node $(node -v) installed"
    fi

    # Bun
    if command -v bun &>/dev/null; then
        ok "Bun $(bun --version) already installed"
    else
        curl -fsSL https://bun.sh/install | bash
        export BUN_INSTALL="${BUN_INSTALL:-$HOME/.bun}"
        export PATH="$BUN_INSTALL/bin:$PATH"
        ok "Bun $(bun --version) installed"
    fi
}

# ─── OpenClaw ──────────────────────────────────────────────────────────

install_openclaw() {
    step "Installing OpenClaw"

    if command -v openclaw &>/dev/null; then
        ok "OpenClaw already installed ($(openclaw --version 2>/dev/null || echo 'unknown'))"
        return
    fi

    bun install -g openclaw
    ok "OpenClaw installed"
}

# ─── Clone template & build brain ──────────────────────────────────────

setup_brain() {
    step "Setting up ${AGENT_NAME}'s brain"

    if [[ -d "$BRAIN_DIR" ]]; then
        local BACKUP="${BRAIN_DIR}.bak.$(date +%s)"
        warn "$BRAIN_DIR exists. Backing up to ${BACKUP}..."
        cp -a "$BRAIN_DIR" "$BACKUP" || die "Failed to backup existing brain. Check permissions."
        rm -rf "$BRAIN_DIR"
        ok "Existing brain backed up"
    fi

    # Ensure parent directory exists
    mkdir -p "$(dirname "$BRAIN_DIR")"

    # Clone repo to temp dir
    local TMPDIR
    TMPDIR=$(mktemp -d)
    info "Downloading template..."
    git clone --single-branch --branch "$BRANCH" --depth 1 \
        "https://github.com/${REPO}.git" "$TMPDIR/repo" 2>/dev/null \
        || die "Failed to download template. Check your network."

    local TEMPLATE="$TMPDIR/repo/brain"

    # Copy entire brain/ template as the brain directory
    cp -r "$TEMPLATE" "$BRAIN_DIR"
    ok "Brain template installed"

    # Copy config templates alongside brain
    for dir in config systemd setup skills; do
        if [[ -d "$TMPDIR/repo/$dir" ]]; then
            cp -r "$TMPDIR/repo/$dir" "$BRAIN_DIR/_${dir}"
        fi
    done

    # Ensure memory subdirectories exist
    mkdir -p "$BRAIN_DIR"/memory/{semantic,procedural,decisions,episodic,failures,outcomes,working,research}
    mkdir -p "$BRAIN_DIR"/{projects,tasks,tools,users}

    # ─── Template substitution ───
    local AGENT_NAME_LOWER
    AGENT_NAME_LOWER=$(echo "$AGENT_NAME" | tr '[:upper:]' '[:lower:]')

    info "Personalizing brain files..."
    find "$BRAIN_DIR" -type f \( -name "*.md" -o -name "*.json" -o -name "*.json.example" \) | while read -r file; do
        sed -i \
            -e "s|{{AGENT_NAME}}|${AGENT_NAME}|g" \
            -e "s|{{AGENT_NAME_LOWER}}|${AGENT_NAME_LOWER}|g" \
            -e "s|{{COMPANY}}|${ORG_NAME}|g" \
            -e "s|{{ORG_NAME}}|${ORG_NAME}|g" \
            -e "s|{{OWNER_NAME}}|${OWNER_NAME}|g" \
            -e "s|{{OWNER_ID}}|${OWNER_ID}|g" \
            -e "s|{{BOT_USERNAME}}|${SLUG}_bot|g" \
            -e "s|{{SLUG}}|${SLUG}|g" \
            -e "s|{{TIMEZONE}}|${TIMEZONE}|g" \
            -e "s|{{LANGUAGE}}|${LANGUAGE}|g" \
            -e "s|{{BRAIN_DIR}}|${BRAIN_DIR}|g" \
            -e "s|{{INSTALL_DIR}}|${BRAIN_DIR}|g" \
            "$file"
    done
    ok "Brain personalized for ${AGENT_NAME}"

    # ─── Generate openclaw.json ───
    if [[ -f "$BRAIN_DIR/_config/openclaw.template.json" ]]; then
        sed \
            -e "s|{{AGENT_NAME}}|${AGENT_NAME}|g" \
            -e "s|{{ORG_NAME}}|${ORG_NAME}|g" \
            -e "s|{{SLUG}}|${SLUG}|g" \
            -e "s|{{BRAIN_DIR}}|${BRAIN_DIR}|g" \
            -e "s|{{TELEGRAM_TOKEN}}|${BOT_TOKEN}|g" \
            "$BRAIN_DIR/_config/openclaw.template.json" > "$CONFIG_FILE"

        # Patch primary model + owner ID
        if command -v bun &>/dev/null; then
            bun -e "
                const fs = require('fs');
                const c = JSON.parse(fs.readFileSync('${CONFIG_FILE}', 'utf8'));
                c.agents.defaults.model.primary = '${PRIMARY_MODEL}';
                if ('${OWNER_ID}') {
                    c.channels.telegram.allowFrom = ['${OWNER_ID}'];
                    c.commands = c.commands || {};
                    c.commands.ownerAllowFrom = ['${OWNER_ID}'];
                }
                fs.writeFileSync('${CONFIG_FILE}', JSON.stringify(c, null, 2));
            " 2>/dev/null || true
        fi
        ok "Config generated (model: ${PRIMARY_MODEL})"
    else
        warn "Template not found, creating minimal config"
        cat > "$CONFIG_FILE" <<MINIMAL
{
  "agents": {
    "defaults": {
      "model": {
        "primary": "${PRIMARY_MODEL}",
        "fallbacks": ["google/gemini-3-flash-preview"]
      },
      "heartbeat": { "every": "30m", "target": "last" }
    },
    "list": [{
      "id": "main",
      "default": true,
      "workspace": "${BRAIN_DIR}",
      "identity": { "name": "${AGENT_NAME}", "emoji": "🧠" },
      "subagents": { "allowAgents": ["*"] }
    }]
  },
  "channels": {
    "telegram": {
      "enabled": true,
      "dmPolicy": "allowlist",
      "botToken": { "source": "env", "provider": "default", "id": "TELEGRAM_BOT_TOKEN" },
      "allowFrom": [${OWNER_ID:+\"$OWNER_ID\"}],
      "groupPolicy": "allowlist",
      "streaming": "partial"
    }
  },
  "gateway": { "port": 18789, "mode": "local", "bind": "loopback" },
  "plugins": {
    "allow": ["acpx", "lossless-claw", "telegram"],
    "entries": {
      "acpx": { "enabled": true, "config": { "permissionMode": "approve-all" } },
      "lossless-claw": { "enabled": true }
    }
  }
}
MINIMAL
    fi

    # ─── Division templates ───
    if [[ "$DIVISIONS" == true && -d "$BRAIN_DIR/_config/divisions" ]]; then
        mkdir -p "$BRAIN_DIR/topics"
        for div in build product content growth revenue distribution client-success intelligence ops; do
            if [[ -f "$BRAIN_DIR/_config/divisions/$div/SOUL.md" ]]; then
                mkdir -p "$BRAIN_DIR/topics/$div/memory"
                cp "$BRAIN_DIR/_config/divisions/$div/SOUL.md" "$BRAIN_DIR/topics/$div/SOUL.md"
                sed -i \
                    -e "s|{{AGENT_NAME}}|${AGENT_NAME}|g" \
                    -e "s|{{ORG_NAME}}|${ORG_NAME}|g" \
                    "$BRAIN_DIR/topics/$div/SOUL.md"
            fi
        done
        ok "9 divisions configured: build, product, content, growth, revenue, distribution, client-success, intelligence, ops"
    fi

    # ─── Claude Code config ───
    if [[ -d "$BRAIN_DIR/_config/claude-code" ]]; then
        mkdir -p "$HOME/.claude/rules"
        cp "$BRAIN_DIR/_config/claude-code/CLAUDE.md" "$HOME/.claude/CLAUDE.md" 2>/dev/null || true
        cp -r "$BRAIN_DIR/_config/claude-code/rules/"* "$HOME/.claude/rules/" 2>/dev/null || true
        ok "Claude Code config installed"
    fi

    # ─── Environment file ───
    cat > "$ENV_FILE" <<ENVFILE
# ${AGENT_NAME} for ${ORG_NAME} — secrets
# NEVER commit this file. chmod 600.
TELEGRAM_BOT_TOKEN=${BOT_TOKEN}
GOOGLE_API_KEY=${GOOGLE_API_KEY}
ZAI_API_KEY=${ZAI_API_KEY}
COPILOT_TOKEN=${COPILOT_TOKEN}
ENVFILE
    chmod 600 "$ENV_FILE"
    echo ".env" >> "$BRAIN_DIR/.gitignore" 2>/dev/null || true

    # Clean up temp dirs
    rm -rf "$BRAIN_DIR"/_config "$BRAIN_DIR"/_systemd "$BRAIN_DIR"/_setup "$BRAIN_DIR"/_skills
    rm -rf "$TMPDIR"

    ok "Brain ready at $BRAIN_DIR"
}

# ─── Systemd services ──────────────────────────────────────────────────

setup_services() {
    step "Setting up background services"

    local SVC_DIR="$HOME/.config/systemd/user"
    mkdir -p "$SVC_DIR"

    local OPENCLAW_PATH
    OPENCLAW_PATH=$(command -v openclaw)
    local NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
    local NODE_BIN_DIR="$NVM_DIR/versions/node/$(node -v)/bin"
    local BUN_BIN_DIR="${BUN_INSTALL:-$HOME/.bun}/bin"
    local ENV_PATH="$NODE_BIN_DIR:$BUN_BIN_DIR:/usr/local/bin:/usr/bin:/bin"

    # Xvfb
    if command -v Xvfb &>/dev/null; then
        cat > "$SVC_DIR/xvfb.service" <<EOF
[Unit]
Description=Xvfb — Virtual Display for Headless Browser
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/Xvfb :99 -screen 0 1280x1024x24 -nolisten tcp
Restart=always
RestartSec=5

[Install]
WantedBy=default.target
EOF
        ok "xvfb.service created"
    fi

    # OpenClaw Gateway
    cat > "$SVC_DIR/openclaw.service" <<EOF
[Unit]
Description=OpenClaw AI Gateway — ${AGENT_NAME}
After=network.target xvfb.service
Wants=xvfb.service

[Service]
Type=simple
WorkingDirectory=${BRAIN_DIR}
Environment=DISPLAY=:99
Environment=PATH=${ENV_PATH}
EnvironmentFile=${ENV_FILE}
ExecStart=${OPENCLAW_PATH} gateway start --foreground
Restart=always
RestartSec=5

[Install]
WantedBy=default.target
EOF
    ok "openclaw.service created"

    # Auto-Update (every 6h)
    cat > "$SVC_DIR/openclaw-update.service" <<EOF
[Unit]
Description=OpenClaw Auto-Update
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
Environment=PATH=${ENV_PATH}
ExecStart=/bin/bash -c '\
  BEFORE=\$(bun pm ls -g 2>/dev/null | grep openclaw | head -1); \
  bun install -g openclaw 2>/dev/null; \
  AFTER=\$(bun pm ls -g 2>/dev/null | grep openclaw | head -1); \
  if [ "\$BEFORE" != "\$AFTER" ]; then \
    echo "OpenClaw updated: \$BEFORE -> \$AFTER"; \
    systemctl --user restart openclaw.service; \
  else \
    echo "OpenClaw up to date: \$BEFORE"; \
  fi'
StandardOutput=journal
StandardError=journal
EOF

    cat > "$SVC_DIR/openclaw-update.timer" <<EOF
[Unit]
Description=OpenClaw Auto-Update — Every 6 Hours

[Timer]
OnBootSec=10min
OnUnitActiveSec=6h
Persistent=true

[Install]
WantedBy=timers.target
EOF
    ok "openclaw-update.timer created (every 6h)"

    # Watchdog (every 5min)
    cat > "$SVC_DIR/${SLUG}-watchdog.service" <<EOF
[Unit]
Description=${AGENT_NAME} Watchdog — Health Monitor
After=openclaw.service

[Service]
Type=oneshot
WorkingDirectory=${BRAIN_DIR}
Environment=PATH=${ENV_PATH}
ExecStart=${OPENCLAW_PATH} healthcheck --fail-on-error

[Install]
WantedBy=default.target
EOF

    cat > "$SVC_DIR/${SLUG}-watchdog.timer" <<EOF
[Unit]
Description=${AGENT_NAME} Watchdog — 5 Minute Health Check

[Timer]
OnBootSec=3min
OnUnitActiveSec=5min

[Install]
WantedBy=timers.target
EOF
    ok "${SLUG}-watchdog.timer created (every 5min)"

    # Enable all
    systemctl --user daemon-reload
    systemctl --user enable xvfb.service 2>/dev/null || true
    systemctl --user enable openclaw.service
    systemctl --user enable openclaw-update.timer
    systemctl --user enable "${SLUG}-watchdog.timer"

    # Lingering
    loginctl enable-linger "$USER" 2>/dev/null || \
        warn "Could not enable lingering. Services may stop on logout."

    ok "All services enabled"
}

# ─── Start ─────────────────────────────────────────────────────────────

start_services() {
    step "Starting ${AGENT_NAME}"

    systemctl --user start xvfb.service 2>/dev/null || true
    sleep 1
    export DISPLAY=:99

    systemctl --user start openclaw.service
    sleep 3

    if systemctl --user is-active openclaw.service &>/dev/null; then
        ok "${AGENT_NAME} is running!"
    else
        warn "Gateway failed to start. Check: journalctl --user -u openclaw -n 20"
    fi

    systemctl --user start "${SLUG}-watchdog.timer" 2>/dev/null || true
    systemctl --user start openclaw-update.timer 2>/dev/null || true
}

# ─── Git init ──────────────────────────────────────────────────────────

init_repo() {
    cd "$BRAIN_DIR"
    git init -q 2>/dev/null || true
    git add -A
    git commit -q -m "feat: ${AGENT_NAME} for ${ORG_NAME} — OpenClaw Agent Template v${VERSION}" 2>/dev/null || true
}

# ─── Done ──────────────────────────────────────────────────────────────

finalize() {
    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}${NC}"
    echo -e "${GREEN}  ${AGENT_NAME} is alive!${NC}"
    echo -e "${GREEN}${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "  ${BOLD}Brain${NC}       $BRAIN_DIR/"
    echo -e "  ${BOLD}Config${NC}      $CONFIG_FILE"
    echo -e "  ${BOLD}Secrets${NC}     $ENV_FILE"
    echo -e "  ${BOLD}Model${NC}       ${PRIMARY_MODEL} ${DIM}(swappable via /model)${NC}"
    echo -e "  ${BOLD}Auto-update${NC} every 6 hours ${DIM}(openclaw-update.timer)${NC}"
    echo ""

    if [[ -n "$BOT_TOKEN" ]]; then
        echo -e "  ${GREEN}Open Telegram and message your bot. ${AGENT_NAME} is listening.${NC}"
    else
        echo -e "  ${YELLOW}Next step: add your Telegram bot token:${NC}"
        echo -e "    ${CYAN}nano ${ENV_FILE}${NC}"
        echo -e "    ${CYAN}systemctl --user restart openclaw${NC}"
    fi

    echo ""
    echo -e "  ${DIM}Useful commands:${NC}"
    echo -e "    ${CYAN}systemctl --user status openclaw${NC}         ${DIM}# Status${NC}"
    echo -e "    ${CYAN}journalctl --user -u openclaw -f${NC}          ${DIM}# Logs${NC}"
    echo -e "    ${CYAN}systemctl --user restart openclaw${NC}         ${DIM}# Restart${NC}"
    echo -e "    ${CYAN}cat ${BRAIN_DIR}/ARCHITECTURE.md${NC}  ${DIM}# How it works${NC}"
    echo ""
    echo -e "  ${DIM}Learn more: https://github.com/koompi/koompi-nimmit${NC}"
    echo ""
}

# ─── Uninstall ────────────────────────────────────────────────────────────

uninstall() {
    echo -e "${BOLD}${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}${RED}  Uninstall OpenClaw Agent${NC}"
    echo -e "${BOLD}${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${YELLOW}This will:${NC}"
    echo -e "  • Stop and disable all systemd services"
    echo -e "  • Remove OpenClaw configuration"
    echo -e "  • Delete the brain directory (~/.openclaw/<slug>/)"
    echo -e "  • Keep your .env file (for backup) unless you confirm deletion"
    echo ""

    if ! ask_yn "Continue with uninstall?" "n"; then
        echo -e "\n  ${DIM}Uninstall cancelled.${NC}\n"
        exit 0
    fi

    echo ""

    # Detect existing installations
    local FOUND=false
    local DIR="$HOME/.openclaw"
    if [[ -d "$DIR" ]]; then
        echo -e "${CYAN}Found installations:${NC}"
        for d in "$DIR"/*/; do
            if [[ -d "$d" ]]; then
                local slug=$(basename "$d")
                echo -e "  • ${BOLD}$slug${NC} ($d)"
                FOUND=true
            fi
        done
    fi

    if [[ "$FOUND" == false ]]; then
        warn "No OpenClaw agent installations found."
        exit 0
    fi

    echo ""
    ask "Enter slug to uninstall (or 'all')" ""
    local SLUG="$REPLY"
    [[ "$SLUG" == "all" ]] && SLUG="*"

    echo ""
    step "Stopping services"

    # Stop and disable services for each slug
    for brain_dir in $DIR/$SLUG; do
        if [[ ! -d "$brain_dir" ]]; then continue; fi

        local name=$(basename "$brain_dir")

        systemctl --user stop "${name}-watchdog.timer" 2>/dev/null || true
        systemctl --user disable "${name}-watchdog.timer" 2>/dev/null || true
        systemctl --user stop openclaw-update.timer 2>/dev/null || true
        systemctl --user disable openclaw-update.timer 2>/dev/null || true
        systemctl --user stop openclaw.service 2>/dev/null || true
        systemctl --user disable openclaw.service 2>/dev/null || true
        systemctl --user stop xvfb.service 2>/dev/null || true
        systemctl --user disable xvfb.service 2>/dev/null || true

        ok "Stopped services for $name"
    done

    systemctl --user daemon-reload
    echo ""

    step "Removing service files"

    local SVC_DIR="$HOME/.config/systemd/user"
    rm -f "$SVC_DIR/xvfb.service"
    rm -f "$SVC_DIR/openclaw.service"
    rm -f "$SVC_DIR/openclaw-update.service"
    rm -f "$SVC_DIR/openclaw-update.timer"
    for brain_dir in $DIR/$SLUG; do
        if [[ -d "$brain_dir" ]]; then
            local name=$(basename "$brain_dir")
            rm -f "$SVC_DIR/${name}-watchdog.service"
            rm -f "$SVC_DIR/${name}-watchdog.timer"
        fi
    done

    ok "Service files removed"
    echo ""

    step "Removing brain directories"

    for brain_dir in $DIR/$SLUG; do
        if [[ ! -d "$brain_dir" ]]; then continue; fi

        local name=$(basename "$brain_dir")
        local env_file="$brain_dir/.env"

        # Backup .env if it contains secrets
        if [[ -f "$env_file" ]]; then
            local backup="${env_file}.backup.$(date +%s)"
            cp "$env_file" "$backup"
            ok "Backed up .env to $backup"
        fi

        rm -rf "$brain_dir"
        ok "Removed $name"
    done

    echo ""

    # Ask about removing OpenClaw itself
    if ask_yn "Also remove OpenClaw globally?" "n"; then
        step "Removing OpenClaw"
        bun pm rm -g openclaw 2>/dev/null || true
        ok "OpenClaw removed"
    fi

    echo ""

    # Ask about removing config
    if ask_yn "Remove global config at ~/.openclaw/?" "n"; then
        rm -rf "$HOME/.openclaw"
        ok "Global config removed"
    fi

    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}  Uninstall complete${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "  ${DIM}Note: .env backup files were preserved.${NC}"
    echo -e "  ${DIM}To remove them: rm ~/.openclaw/*/.env.backup.*${NC}"
    echo ""
}

# ─── Main ──────────────────────────────────────────────────────────────

main() {
    # Interactive wizard (unless --non-interactive or no terminal available)
    if [[ "$NON_INTERACTIVE" == false && "$HAS_TTY" == true ]]; then
        interactive_setup
    fi

    # Set defaults for anything not provided
    AGENT_NAME="${AGENT_NAME:-Nimmit}"
    ORG_NAME="${ORG_NAME:-$AGENT_NAME}"
    SLUG="${SLUG:-$(echo "$AGENT_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd '[:alnum:]-')}"
    OWNER_NAME="${OWNER_NAME:-Owner}"
    detect_timezone
    BRAIN_DIR="$OPENCLAW_DIR/$SLUG"
    ENV_FILE="$BRAIN_DIR/.env"

    echo -e "\n${BOLD}${GREEN}  Installing ${AGENT_NAME} for ${ORG_NAME}...${NC}\n"

    detect_os
    install_deps
    install_runtimes
    install_openclaw
    setup_brain
    setup_services
    start_services
    init_repo
    finalize
}

main
