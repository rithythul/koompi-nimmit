#!/usr/bin/env bash
set -euo pipefail

# koompi-nimmit installer v0.1.0
# One-command setup on fresh Ubuntu 22.04+ VPS or KOOMPI Mini (Arch)
# Usage: bash install.sh "ClientName" --token "BOT_TOKEN" --zai-key "ZAI_KEY"

VERSION="2.1.0"
INSTALL_DIR="$HOME/.openclaw/nimmit"
BRAIN_DIR="$INSTALL_DIR"
CONFIG_FILE="$INSTALL_DIR/openclaw.json"
ENV_FILE="$INSTALL_DIR/.env"
REPO="rithythul/koompi-nimmit"
BRANCH="main"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'
info()  { echo -e "${CYAN}[INFO]${NC}  $*"; }
ok()    { echo -e "${GREEN}[ OK ]${NC}  $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
die()   { echo -e "${RED}[ERR]${NC}   $*" >&2; exit 1; }
step()  { echo -e "\n${BOLD}${CYAN}▸${NC} ${BOLD}$*${NC}"; }

# ─── Args ──────────────────────────────────────────────────────────────

AGENT_NAME=""
ORG_NAME=""
SLUG=""
BOT_TOKEN=""
ZAI_API_KEY=""
CLAUDE_CODE_TOKEN=""
CHANNEL="telegram"
SKIP_DEPS=false
IS_MINI=false
DIVISIONS=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --name) AGENT_NAME="$2"; shift 2 ;;
        --org) ORG_NAME="$2"; shift 2 ;;
        --slug) SLUG="$2"; shift 2 ;;
        --token|--telegram-token) BOT_TOKEN="$2"; shift 2 ;;
        --zai-key) ZAI_API_KEY="$2"; shift 2 ;;
        --claude-token) CLAUDE_CODE_TOKEN="$2"; shift 2 ;;
        --channel) CHANNEL="$2"; shift 2 ;;
        --skip-deps) SKIP_DEPS=true; shift ;;
        --mini) IS_MINI=true; shift ;;
        --divisions) DIVISIONS=true; shift ;;
        -h|--help)
            cat <<HELP
Usage: bash install.sh [OPTIONS] CLIENT_NAME

Install koompi-nimmit — a turnkey AI agent appliance.

Arguments:
  CLIENT_NAME              Agent name (e.g. "Nimmit")

Options:
  --org NAME               Organization name (default: CLIENT_NAME)
  --slug SLUG              URL-safe slug (default: derived from name)
  --token TOKEN            Telegram bot token (from @BotFather)
  --zai-key KEY            ZAI API key
  --claude-token TOKEN     Claude Code API key (optional)
  --channel CHANNEL        Primary channel: telegram|discord (default: telegram)
  --skip-deps              Skip system dependency installation
  --mini                   Target is KOOMPI Mini (enables autologin)
  --divisions             Enable 4-division mode (build, product, growth, ops)
  -h, --help               Show this help

Examples:
  bash install.sh "Nimmit" --token "123456:ABC..." --zai-key "zai_xxx"
  bash install.sh "Atlas" --org "Acme Corp" --token "123456:ABC..." --mini
HELP
            exit 0 ;;
        -*)
            # Support --flag=value syntax
            if [[ "$1" == *=* ]]; then
                key="${1%%=*}"; val="${1#*=}"
                shift
                set -- "$key" "$val" "$@"
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

if [[ -z "$BOT_TOKEN" ]]; then
    warn "No Telegram bot token. You'll need to configure it after install."
fi

echo -e "\n${BOLD}${GREEN}🦅 koompi-nimmit installer v${VERSION}${NC}"
echo -e "${BOLD}   Agent: ${AGENT_NAME} | Org: ${ORG_NAME}${NC}"
[[ "$IS_MINI" == true ]] && echo -e "${BOLD}   Target: KOOMPI Mini${NC}"
echo ""

# ─── Detect OS ─────────────────────────────────────────────────────────

detect_os() {
    if [[ -f /etc/arch-release ]] || grep -qi "koompi" /etc/os-release 2>/dev/null; then
        OS="arch"
        PKG_INSTALL="sudo pacman -S --noconfirm --quiet"
        PKG_LIST="git chromium curl unzip base-devel"
        AUTOLOGIN_SVC="getty@tty1"
    elif [[ -f /etc/debian_version ]] || grep -qi ubuntu /etc/os-release 2>/dev/null; then
        OS="ubuntu"
        PKG_INSTALL="sudo DEBIAN_FRONTEND=noninteractive apt-get install -y"
        PKG_LIST="git chromium-browser curl unzip xvfb"
        AUTOLOGIN_SVC="getty@tty1"
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

    sudo mkdir -p /etc/apt/keyrings 2>/dev/null || true

    case "$OS" in
        ubuntu)
            # NodeSource for Node 22
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
            if ! command -v node &>/dev/null || [[ $(node -v | cut -d. -f1 | tr -d v) -lt 22 ]]; then
                info "Updating packages..."
                sudo pacman -Sy --noconfirm --quiet 2>/dev/null || true
            fi
            ;;
    esac

    info "Installing: ${PKG_LIST}"
    $PKG_INSTALL $PKG_LIST 2>&1 | tail -5

    # Verify chromium
    if command -v chromium-browser &>/dev/null; then
        CHROMIUM_BIN=$(command -v chromium-browser)
    elif command -v chromium &>/dev/null; then
        CHROMIUM_BIN=$(command -v chromium)
    elif command -v google-chrome &>/dev/null; then
        CHROMIUM_BIN=$(command -v google-chrome)
    else
        warn "Chromium not found after install. Browser features may not work."
    fi
    ok "System packages installed"
}

# ─── Node + Bun ───────────────────────────────────────────────────────

install_runtimes() {
    step "Installing Node.js 22 + Bun"

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
        ok "OpenClaw already installed"
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
            curl -sSL "https://storage.googleapis.com/supabase-cli-artifacts/supabase_2.latest_linux_amd64.deb" \
                -o /tmp/supabase.deb && sudo dpkg -i /tmp/supabase.deb && rm /tmp/supabase.deb
            ;;
        arch)
            bun install -g supabase 2>/dev/null || npm install -g supabase
            ;;
    esac
    ok "Supabase CLI installed"
}

# ─── Clone & configure ─────────────────────────────────────────────────

setup_brain() {
    step "Setting up ${AGENT_NAME}'s brain"

    if [[ -d "$INSTALL_DIR" ]]; then
        warn "$INSTALL_DIR exists. Backing up..."
        mv "$INSTALL_DIR" "${INSTALL_DIR}.bak.$(date +%s)"
    fi

    mkdir -p "$INSTALL_DIR"/{config,systemd,setup,brain,mcp}

    # Clone repo to get templates
    local TMPDIR
    TMPDIR=$(mktemp -d)
    info "Cloning templates..."
    git clone --single-branch --branch "$BRANCH" --depth 1 \
        "https://github.com/${REPO}.git" "$TMPDIR/koompi-nimmit" 2>/dev/null || true

    if [[ -d "$TMPDIR/koompi-nimmit/config" ]]; then
        cp -r "$TMPDIR/koompi-nimmit/config/"* "$INSTALL_DIR/config/" 2>/dev/null
        cp -r "$TMPDIR/koompi-nimmit/systemd/"* "$INSTALL_DIR/systemd/" 2>/dev/null
        cp -r "$TMPDIR/koompi-nimmit/setup/"* "$INSTALL_DIR/setup/" 2>/dev/null
        cp -r "$TMPDIR/koompi-nimmit/skills/"* "$INSTALL_DIR/skills/" 2>/dev/null
    fi
    rm -rf "$TMPDIR"

    # Create brain directory structure
    mkdir -p "$BRAIN_DIR"/{memory/{semantic,procedural,decisions,episodic,failures,outcomes,working},projects,agents,tasks,tools}

    # Generate openclaw.json from template
    local TEMPLATE="$INSTALL_DIR/config/openclaw.template.json"
    if [[ -f "$TEMPLATE" ]]; then
        sed \
            -e "s|{{AGENT_NAME}}|${AGENT_NAME}|g" \
            -e "s|{{ORG_NAME}}|${ORG_NAME}|g" \
            -e "s|{{SLUG}}|${SLUG}|g" \
            -e "s|{{BRAIN_DIR}}|${BRAIN_DIR}|g" \
            -e "s|{{INSTALL_DIR}}|${INSTALL_DIR}|g" \
            "$TEMPLATE" > "$CONFIG_FILE"
        ok "openclaw.json generated"
    else
        warn "Template not found, creating minimal config"
        cat > "$CONFIG_FILE" <<MINIMAL
{
  "agents": {
    "defaults": { "model": { "primary": "zai/glm-5-turbo" } },
    "list": [{ "id": "main", "default": true, "workspace": "${BRAIN_DIR}" }]
  },
  "channels": {
    "telegram": { "enabled": $([ "$CHANNEL" = "telegram" ] && echo "true" || echo "false"), "botToken": "", "allowFrom": [] }
  },
  "gateway": { "port": 18789, "mode": "local", "bind": "loopback" }
}
MINIMAL
    fi

    # Claude Code config
    if [[ -d "$INSTALL_DIR/config/claude-code" ]]; then
        mkdir -p "$HOME/.claude/rules"
        cp "$INSTALL_DIR/config/claude-code/CLAUDE.md" "$HOME/.claude/CLAUDE.md" 2>/dev/null
        cp -r "$INSTALL_DIR/config/claude-code/rules/"* "$HOME/.claude/rules/" 2>/dev/null
        if [[ -f "$INSTALL_DIR/config/claude-code/settings.json" ]]; then
            cp "$INSTALL_DIR/config/claude-code/settings.json" "$HOME/.claude/settings.json" 2>/dev/null
        fi
        ok "Claude Code config installed (~/.claude/)"
    fi

    # Generate brain files from templates
    for tmpl in "$INSTALL_DIR"/config/*.template.md; do
        [[ -f "$tmpl" ]] || continue
        local base dest
        base=$(basename "$tmpl" .template.md)
        # Map: soul → SOUL.md, tools → TOOLS.md, standards → STANDARDS.md
        case "$base" in
            soul) dest="$BRAIN_DIR/SOUL.md" ;;
            tools) dest="$BRAIN_DIR/TOOLS.md" ;;
            standards) dest="$BRAIN_DIR/STANDARDS.md" ;;
            *) dest="$BRAIN_DIR/${base^^}.md" ;;
        esac
        sed -e "s/{{AGENT_NAME}}/${AGENT_NAME}/g" \
            -e "s/{{ORG_NAME}}/${ORG_NAME}/g" \
            -e "s/{{SLUG}}/${SLUG}/g" \
            "$tmpl" > "$dest"
    done

    # IDENTITY.md
    cat > "$BRAIN_DIR/IDENTITY.md" <<IDENTITY
# IDENTITY.md

- **Name:** ${AGENT_NAME}
- **What we are:** ${ORG_NAME}'s AI team
- **Installed:** $(date -Iseconds)
- **Channel:** ${CHANNEL}
- **Model:** zai/glm-5-turbo

_This file is yours to evolve._
IDENTITY

    # AGENTS.md — use division template if --divisions, else minimal
    if [[ "$DIVISIONS" == true && -f "$INSTALL_DIR/config/AGENTS.template.md" ]]; then
        sed -e "s/{{AGENT_NAME}}/${AGENT_NAME}/g" \
            -e "s/{{ORG_NAME}}/${ORG_NAME}/g" \
            -e "s/{{BRAIN_DIR}}/${BRAIN_DIR}/g" \
            "$INSTALL_DIR/config/AGENTS.template.md" > "$BRAIN_DIR/AGENTS.md"
        ok "AGENTS.md generated (division mode)"

        # Copy division SOUL.md files
        mkdir -p "$BRAIN_DIR/topics"
        for div in build product growth ops; do
            if [[ -f "$INSTALL_DIR/config/divisions/$div/SOUL.md" ]]; then
                mkdir -p "$BRAIN_DIR/topics/$div"
                sed -e "s/{{AGENT_NAME}}/${AGENT_NAME}/g" \
                    -e "s/{{ORG_NAME}}/${ORG_NAME}/g" \
                    "$INSTALL_DIR/config/divisions/$div/SOUL.md" > "$BRAIN_DIR/topics/$div/SOUL.md"
            fi
        done
        ok "4 divisions configured: build, product, growth, ops"
        info "Create topics/threads for #build, #product, #growth, #ops in your messaging app"
        info "Update AGENTS.md thread IDs after creating the topics"
    else
        cat > "$BRAIN_DIR/AGENTS.md" <<AGENTS
# AGENTS.md — ${AGENT_NAME}

## Who We Are

We are **${AGENT_NAME}** — ${ORG_NAME}'s AI team.

## Workspace Rules

- Brain files: ${BRAIN_DIR}/ (same dir)
- Code projects: ~/workspace/<project-name>/
- Secrets: ~/.secrets/ (never in brain files)
- CLI binaries: ~/.local/bin/

## Session Startup

1. Read SOUL.md + TOOLS.md + STANDARDS.md
2. Read IDENTITY.md
3. Check task queue

## Coding

- Default: Copilot sub-agents for coding
- Claude Code (ACP): only for complex multi-file tasks
- Always TypeScript strict. Never plain JS.
AGENTS
        ok "AGENTS.md generated (single mode)"
    fi

    # MEMORY.md (minimal index)
    cat > "$BRAIN_DIR/MEMORY.md" <<MEMORY
# MEMORY.md — ${AGENT_NAME} Memory Index

## Memory Architecture

\`\`\`
memory/
├── semantic/      # What things are
├── procedural/    # How to do things
├── decisions/     # Why we decided
├── episodic/      # What happened, when
├── failures/      # What failed
├── outcomes/      # Task outcomes
└── working/       # Current context
\`\`\`

## Quick Reference

- **Org:** ${ORG_NAME}
- **Model:** zai/glm-5-turbo
- **Coding:** Copilot default, Claude Code for complex
MEMORY

    # Environment file for secrets
    cat > "$ENV_FILE" <<ENVFILE
# koompi-nimmit secrets — NEVER commit this file
TELEGRAM_BOT_TOKEN=${BOT_TOKEN}
ZAI_API_KEY=${ZAI_API_KEY}
CLAUDE_CODE_TOKEN=${CLAUDE_CODE_TOKEN:-}
ENVFILE
    chmod 600 "$ENV_FILE"

    ok "Brain configured"
}

# ─── Systemd services ──────────────────────────────────────────────────

setup_services() {
    step "Setting up systemd services"

    local SVC_DIR="$HOME/.config/systemd/user"
    mkdir -p "$SVC_DIR"

    # Get absolute paths
    local NODE_PATH BUN_PATH OPENCLAW_PATH CHROMIUM_BIN
    NODE_PATH=$(command -v node)
    BUN_PATH=$(command -v bun)
    OPENCLAW_PATH=$(command -v openclaw)
    CHROMIUM_BIN=$(command -v chromium-browser || command -v chromium || command -v google-chrome || echo "/usr/bin/chromium")
    local NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
    local NODE_BIN_DIR="$NVM_DIR/versions/node/$(node -v)/bin"
    local BUN_BIN_DIR="${BUN_INSTALL:-$HOME/.bun}/bin"
    local ENV_PATH="$NODE_BIN_DIR:$BUN_BIN_DIR:/usr/local/bin:/usr/bin:/bin"

    # ─── Xvfb ───
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

    # ─── OpenClaw Gateway ───
    cat > "$SVC_DIR/openclaw.service" <<EOF
[Unit]
Description=OpenClaw AI Gateway — ${AGENT_NAME}
After=network.target xvfb.service
Wants=xvfb.service

[Service]
Type=simple
WorkingDirectory=${INSTALL_DIR}
Environment=DISPLAY=:99
Environment=PATH=${ENV_PATH}
Environment=NIMMIT_HOME=${INSTALL_DIR}
EnvironmentFile=${ENV_FILE}
ExecStart=${OPENCLAW_PATH} gateway start --foreground
Restart=always
RestartSec=5
RestartPreventExitStatus=SIGKILL

[Install]
WantedBy=default.target
EOF
    systemctl --user daemon-reload
    systemctl --user enable openclaw.service
    ok "openclaw.service enabled"

    # ─── Watchdog ───
    cat > "$SVC_DIR/nimmit-watchdog.service" <<EOF
[Unit]
Description=${AGENT_NAME} Watchdog — Health Monitor
After=openclaw.service

[Service]
Type=oneshot
WorkingDirectory=${INSTALL_DIR}
Environment=PATH=${ENV_PATH}
ExecStart=${OPENCLAW_PATH} healthcheck --fail-on-error
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=default.target
EOF

    cat > "$SVC_DIR/nimmit-watchdog.timer" <<EOF
[Unit]
Description=${AGENT_NAME} Watchdog — 5 Minute Health Check

[Timer]
OnBootSec=3min
OnUnitActiveSec=5min

[Install]
WantedBy=timers.target
EOF
    systemctl --user daemon-reload
    systemctl --user enable nimmit-watchdog.timer
    ok "nimmit-watchdog.timer enabled (every 5 min)"

    # ─── Enable lingering ───
    loginctl enable-linger "$USER" 2>/dev/null || \
        warn "Could not enable lingering. Services may stop on logout."
    ok "Lingering enabled"

    # ─── KOOMPI Mini: autologin ───
    if [[ "$IS_MINI" == true ]]; then
        info "KOOMPI Mini detected: configuring autologin on tty1..."
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

# ─── Start services ────────────────────────────────────────────────────

start_services() {
    step "Starting services"

    systemctl --user start xvfb.service 2>/dev/null || true
    sleep 1

    # Set DISPLAY for current session
    export DISPLAY=:99

    systemctl --user start openclaw.service
    sleep 2

    if systemctl --user is-active openclaw.service &>/dev/null; then
        ok "OpenClaw gateway is running"
    else
        warn "OpenClaw gateway failed to start. Check: journalctl --user -u openclaw -n 20"
    fi

    systemctl --user start nimmit-watchdog.timer 2>/dev/null || true
    ok "Watchdog timer started"
}

# ─── Finalize ──────────────────────────────────────────────────────────

finalize() {
    cd "$INSTALL_DIR"
    git init -q 2>/dev/null
    git add -A
    git commit -q -m "${AGENT_NAME} for ${ORG_NAME} — installed by koompi-nimmit v${VERSION}" 2>/dev/null || true

    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}  🦅 ${AGENT_NAME} is ready for ${ORG_NAME}${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    info "Brain:    $BRAIN_DIR"
    info "Config:   $CONFIG_FILE"
    info "Env:      $ENV_FILE"
    info "Channel:  ${CHANNEL}"
    info "Model:    zai/glm-5-turbo"
    echo ""

    if [[ -z "$BOT_TOKEN" ]]; then
        warn "No Telegram bot token provided."
        warn "1. Create a bot with @BotFather"
        warn "2. Edit: nano ${CONFIG_FILE}"
        warn "3. Set channels.telegram.botToken"
        warn "4. Restart: systemctl --user restart openclaw"
        echo ""
    fi

    if [[ -z "$ZAI_API_KEY" ]]; then
        warn "No ZAI API key. Set it in ${ENV_FILE} as ZAI_API_KEY"
        echo ""
    fi

    info "Useful commands:"
    echo -e "  ${CYAN}systemctl --user status openclaw${NC}        # Check status"
    echo -e "  ${CYAN}journalctl --user -u openclaw -f${NC}         # View logs"
    echo -e "  ${CYAN}systemctl --user restart openclaw${NC}        # Restart"
    echo -e "  ${CYAN}nano ${CONFIG_FILE}${NC}                      # Edit config"
    echo -e "  ${CYAN}nano ${ENV_FILE}${NC}                         # Edit secrets"
    echo ""
}

# ─── Run ───────────────────────────────────────────────────────────────

main() {
    detect_os
    install_deps
    install_runtimes
    install_openclaw
    install_supabase
    setup_brain
    setup_services
    start_services
    finalize
}

main
