#!/usr/bin/env bash
set -euo pipefail

# koompi-nimmit installer v3.0.0
# Deploys an OpenClaw AI agent from the brain/ template.
#
# Usage:
#   curl -fsSL https://install.koompi.ai | bash -s -- "AgentName" --org "Company" --token "BOT_TOKEN"
#   bash install.sh "Nimmit" --org "KOOMPI" --token "123456:ABC..."

VERSION="3.0.0"
REPO="koompi/koompi-nimmit"
BRANCH="master"

# Install paths
OPENCLAW_DIR="$HOME/.openclaw"
BRAIN_DIR=""  # set after SLUG is known
CONFIG_FILE="$OPENCLAW_DIR/openclaw.json"
ENV_FILE=""   # set after BRAIN_DIR

# Colors
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'
info()  { echo -e "${CYAN}[INFO]${NC}  $*"; }
ok()    { echo -e "${GREEN}[ OK ]${NC}  $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
die()   { echo -e "${RED}[ERR]${NC}   $*" >&2; exit 1; }
step()  { echo -e "\n${BOLD}${CYAN}>>>>${NC} ${BOLD}$*${NC}"; }

# ─── Args ──────────────────────────────────────────────────────────────

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
TIMEZONE="UTC"
LANGUAGE="en"
SKIP_DEPS=false
IS_MINI=false
DIVISIONS=false
PRIMARY_MODEL="google/gemini-3.1-pro-preview"

while [[ $# -gt 0 ]]; do
    case $1 in
        --name)           AGENT_NAME="$2"; shift 2 ;;
        --org)            ORG_NAME="$2"; shift 2 ;;
        --slug)           SLUG="$2"; shift 2 ;;
        --owner)          OWNER_NAME="$2"; shift 2 ;;
        --owner-id)       OWNER_ID="$2"; shift 2 ;;
        --token|--telegram-token) BOT_TOKEN="$2"; shift 2 ;;
        --google-key)     GOOGLE_API_KEY="$2"; shift 2 ;;
        --zai-key)        ZAI_API_KEY="$2"; shift 2 ;;
        --copilot-token)  COPILOT_TOKEN="$2"; shift 2 ;;
        --channel)        CHANNEL="$2"; shift 2 ;;
        --timezone)       TIMEZONE="$2"; shift 2 ;;
        --language)       LANGUAGE="$2"; shift 2 ;;
        --model)          PRIMARY_MODEL="$2"; shift 2 ;;
        --skip-deps)      SKIP_DEPS=true; shift ;;
        --mini)           IS_MINI=true; shift ;;
        --divisions)      DIVISIONS=true; shift ;;
        -h|--help)
            cat <<HELP
Usage: bash install.sh [OPTIONS] AGENT_NAME

Deploy a turnkey AI agent powered by OpenClaw.

Arguments:
  AGENT_NAME              Agent name (e.g. "Nimmit", "Atlas")

Options:
  --org NAME              Organization name (default: AGENT_NAME)
  --slug SLUG             URL-safe slug (default: derived from name)
  --owner NAME            Owner's display name
  --owner-id ID           Owner's Telegram user ID
  --token TOKEN           Telegram bot token (from @BotFather)
  --google-key KEY        Google AI API key (for Gemini models)
  --zai-key KEY           ZAI API key (optional fallback)
  --copilot-token TOKEN   GitHub Copilot token (optional)
  --channel CHANNEL       Primary channel: telegram|discord (default: telegram)
  --timezone TZ           Timezone (default: UTC)
  --language LANG         Language code (default: en)
  --model MODEL           Primary chat model (default: google/gemini-3.1-pro-preview)
  --skip-deps             Skip system dependency installation
  --mini                  Target is KOOMPI Mini (enables autologin)
  --divisions             Enable 4-division mode (build, product, growth, ops)
  -h, --help              Show this help

Examples:
  bash install.sh "Nimmit" --org "KOOMPI" --token "123:ABC..." --google-key "AIza..."
  bash install.sh "Atlas" --org "Acme" --token "123:ABC..." --model "zai/glm-5" --mini
  curl -fsSL https://install.koompi.ai | bash -s -- "Nimmit" --org "KOOMPI" --token "123:ABC..."

Architecture:
  Agent identity (brain files) is separate from the AI model.
  Models are swappable at runtime via /model command.
  See brain/ARCHITECTURE.md after install.
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

AGENT_NAME="${AGENT_NAME:-Nimmit}"
ORG_NAME="${ORG_NAME:-$AGENT_NAME}"
SLUG="${SLUG:-$(echo "$AGENT_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd '[:alnum:]-')}"
OWNER_NAME="${OWNER_NAME:-Owner}"
BRAIN_DIR="$OPENCLAW_DIR/$SLUG"
ENV_FILE="$BRAIN_DIR/.env"

echo -e "\n${BOLD}${GREEN}  koompi-nimmit installer v${VERSION}${NC}"
echo -e "${BOLD}   Agent: ${AGENT_NAME} | Org: ${ORG_NAME} | Slug: ${SLUG}${NC}"
echo -e "${BOLD}   Model: ${PRIMARY_MODEL}${NC}"
[[ "$IS_MINI" == true ]] && echo -e "${BOLD}   Target: KOOMPI Mini${NC}"
echo ""

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
        warn "$BRAIN_DIR exists. Backing up..."
        mv "$BRAIN_DIR" "${BRAIN_DIR}.bak.$(date +%s)"
    fi

    # Clone repo to temp dir
    local TMPDIR
    TMPDIR=$(mktemp -d)
    info "Cloning template from ${REPO}..."
    git clone --single-branch --branch "$BRANCH" --depth 1 \
        "https://github.com/${REPO}.git" "$TMPDIR/repo" 2>/dev/null \
        || die "Failed to clone ${REPO}. Check network."

    local TEMPLATE="$TMPDIR/repo/brain"

    # Copy entire brain/ template as the brain directory
    cp -r "$TEMPLATE" "$BRAIN_DIR"
    ok "Brain template copied to $BRAIN_DIR"

    # Copy config templates, systemd, setup, skills alongside brain
    for dir in config systemd setup skills; do
        if [[ -d "$TMPDIR/repo/$dir" ]]; then
            cp -r "$TMPDIR/repo/$dir" "$BRAIN_DIR/_${dir}"
        fi
    done

    # Ensure memory subdirectories exist
    mkdir -p "$BRAIN_DIR"/memory/{semantic,procedural,decisions,episodic,failures,outcomes,working,research}
    mkdir -p "$BRAIN_DIR"/{projects,tasks,tools,users}

    # ─── Template substitution across all brain .md and .json files ───
    local AGENT_NAME_LOWER
    AGENT_NAME_LOWER=$(echo "$AGENT_NAME" | tr '[:upper:]' '[:lower:]')

    info "Applying template variables..."
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
    ok "Template variables applied"

    # ─── Generate openclaw.json ───
    if [[ -f "$BRAIN_DIR/_config/openclaw.template.json" ]]; then
        sed \
            -e "s|{{AGENT_NAME}}|${AGENT_NAME}|g" \
            -e "s|{{ORG_NAME}}|${ORG_NAME}|g" \
            -e "s|{{SLUG}}|${SLUG}|g" \
            -e "s|{{BRAIN_DIR}}|${BRAIN_DIR}|g" \
            -e "s|{{TELEGRAM_TOKEN}}|${BOT_TOKEN}|g" \
            "$BRAIN_DIR/_config/openclaw.template.json" > "$CONFIG_FILE"

        # Patch primary model into openclaw.json
        if command -v bun &>/dev/null; then
            bun -e "
                const c = JSON.parse(require('fs').readFileSync('${CONFIG_FILE}', 'utf8'));
                c.agents.defaults.model.primary = '${PRIMARY_MODEL}';
                require('fs').writeFileSync('${CONFIG_FILE}', JSON.stringify(c, null, 2));
            " 2>/dev/null || true
        fi
        ok "openclaw.json generated (primary: ${PRIMARY_MODEL})"
    else
        warn "openclaw.template.json not found, creating minimal config"
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
        for div in build product growth ops; do
            if [[ -f "$BRAIN_DIR/_config/divisions/$div/SOUL.md" ]]; then
                mkdir -p "$BRAIN_DIR/topics/$div/memory"
                cp "$BRAIN_DIR/_config/divisions/$div/SOUL.md" "$BRAIN_DIR/topics/$div/SOUL.md"
                sed -i \
                    -e "s|{{AGENT_NAME}}|${AGENT_NAME}|g" \
                    -e "s|{{ORG_NAME}}|${ORG_NAME}|g" \
                    "$BRAIN_DIR/topics/$div/SOUL.md"
            fi
        done
        ok "4 divisions configured: build, product, growth, ops"
    fi

    # ─── Claude Code config ───
    if [[ -d "$BRAIN_DIR/_config/claude-code" ]]; then
        mkdir -p "$HOME/.claude/rules"
        cp "$BRAIN_DIR/_config/claude-code/CLAUDE.md" "$HOME/.claude/CLAUDE.md" 2>/dev/null || true
        cp -r "$BRAIN_DIR/_config/claude-code/rules/"* "$HOME/.claude/rules/" 2>/dev/null || true
        ok "Claude Code config installed (~/.claude/)"
    fi

    # ─── Environment file ───
    cat > "$ENV_FILE" <<ENVFILE
# ${AGENT_NAME} secrets — NEVER commit this file
TELEGRAM_BOT_TOKEN=${BOT_TOKEN}
GOOGLE_API_KEY=${GOOGLE_API_KEY}
ZAI_API_KEY=${ZAI_API_KEY}
COPILOT_TOKEN=${COPILOT_TOKEN}
ENVFILE
    chmod 600 "$ENV_FILE"
    echo ".env" >> "$BRAIN_DIR/.gitignore" 2>/dev/null || true

    # Clean up temp config dirs
    rm -rf "$BRAIN_DIR"/_config "$BRAIN_DIR"/_systemd "$BRAIN_DIR"/_setup "$BRAIN_DIR"/_skills
    rm -rf "$TMPDIR"

    ok "Brain configured at $BRAIN_DIR"
}

# ─── Systemd services ──────────────────────────────────────────────────

setup_services() {
    step "Setting up systemd services"

    local SVC_DIR="$HOME/.config/systemd/user"
    mkdir -p "$SVC_DIR"

    local OPENCLAW_PATH
    OPENCLAW_PATH=$(command -v openclaw)
    local NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
    local NODE_BIN_DIR="$NVM_DIR/versions/node/$(node -v)/bin"
    local BUN_BIN_DIR="${BUN_INSTALL:-$HOME/.bun}/bin"
    local ENV_PATH="$NODE_BIN_DIR:$BUN_BIN_DIR:/usr/local/bin:/usr/bin:/bin"

    # Xvfb (headless display for browser)
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
        systemctl --user daemon-reload
        systemctl --user enable xvfb.service
        ok "xvfb.service enabled"
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
    systemctl --user daemon-reload
    systemctl --user enable openclaw.service
    ok "openclaw.service enabled"

    # Watchdog
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
    systemctl --user daemon-reload
    systemctl --user enable "${SLUG}-watchdog.timer"
    ok "${SLUG}-watchdog.timer enabled (every 5 min)"

    # Enable lingering so services survive logout
    loginctl enable-linger "$USER" 2>/dev/null || \
        warn "Could not enable lingering. Services may stop on logout."

    # KOOMPI Mini: autologin
    if [[ "$IS_MINI" == true ]]; then
        info "KOOMPI Mini: configuring autologin on tty1..."
        sudo mkdir -p /etc/systemd/system/getty@tty1.service.d/
        cat <<SUDOCONF | sudo tee /etc/systemd/system/getty@tty1.service.d/override.conf > /dev/null
[Service]
ExecStart=
ExecStart=-/sbin/agetty -a ${USER} --noclear %I \$TERM
SUDOCONF
        sudo systemctl daemon-reload
        ok "Autologin configured for ${USER} on tty1"
    fi
}

# ─── Start ─────────────────────────────────────────────────────────────

start_services() {
    step "Starting services"

    systemctl --user start xvfb.service 2>/dev/null || true
    sleep 1
    export DISPLAY=:99

    systemctl --user start openclaw.service
    sleep 3

    if systemctl --user is-active openclaw.service &>/dev/null; then
        ok "OpenClaw gateway is running"
    else
        warn "OpenClaw gateway failed to start. Check: journalctl --user -u openclaw -n 20"
    fi

    systemctl --user start "${SLUG}-watchdog.timer" 2>/dev/null || true
    ok "Watchdog timer started"
}

# ─── Git init ──────────────────────────────────────────────────────────

init_repo() {
    step "Initializing git repo"
    cd "$BRAIN_DIR"
    git init -q 2>/dev/null || true
    git add -A
    git commit -q -m "feat: ${AGENT_NAME} for ${ORG_NAME} — installed by koompi-nimmit v${VERSION}" 2>/dev/null || true
    ok "Brain committed to local git"
}

# ─── Done ──────────────────────────────────────────────────────────────

finalize() {
    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}  ${AGENT_NAME} is ready for ${ORG_NAME}${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    info "Brain:      $BRAIN_DIR"
    info "Config:     $CONFIG_FILE"
    info "Secrets:    $ENV_FILE"
    info "Channel:    ${CHANNEL}"
    info "Model:      ${PRIMARY_MODEL} (swappable at runtime)"
    info "Architecture: $BRAIN_DIR/ARCHITECTURE.md"
    echo ""

    if [[ -z "$BOT_TOKEN" ]]; then
        warn "No Telegram bot token provided."
        warn "  1. Create a bot with @BotFather"
        warn "  2. Add token to: $ENV_FILE"
        warn "  3. Restart: systemctl --user restart openclaw"
        echo ""
    fi

    if [[ -z "$GOOGLE_API_KEY" && -z "$ZAI_API_KEY" && -z "$COPILOT_TOKEN" ]]; then
        warn "No AI model API key provided. Add at least one to: $ENV_FILE"
        warn "  Supported: GOOGLE_API_KEY, ZAI_API_KEY, COPILOT_TOKEN"
        echo ""
    fi

    info "Commands:"
    echo -e "  ${CYAN}systemctl --user status openclaw${NC}         # Check status"
    echo -e "  ${CYAN}journalctl --user -u openclaw -f${NC}          # View logs"
    echo -e "  ${CYAN}systemctl --user restart openclaw${NC}         # Restart"
    echo -e "  ${CYAN}cat $BRAIN_DIR/ARCHITECTURE.md${NC}  # How it works"
    echo -e "  ${CYAN}nano $CONFIG_FILE${NC}               # Edit config"
    echo -e "  ${CYAN}nano $ENV_FILE${NC}                            # Edit secrets"
    echo ""
}

# ─── Run ───────────────────────────────────��───────────────────────────

main() {
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
