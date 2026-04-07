#!/usr/bin/env bash
set -euo pipefail

# Nimmit Installer
# Usage: curl -fsSL https://nimmit.koompi.ai/install | bash

info()  { echo -e "\033[0;36m🦅\033[0m $1"; }
ok()    { echo -e "\033[0;32m✅\033[0m $1"; }
warn()  { echo -e "\033[1;33m⚠️\033[0m $1"; }
fail()  { echo -e "\033[0;31m❌\033[0m $1"; exit 1; }

[[ $EUID -eq 0 ]] && fail "Don't run as root."

AGENT="nimmit"
SKILL_BASE="https://nimmit.koompi.ai/skill-packs"

# ─── 1. Bun ───
info "Installing Bun..."
if command -v bun &>/dev/null; then
  ok "Bun $(bun --version)"
else
  curl -fsSL https://bun.sh/install | bash
  export BUN_INSTALL="$HOME/.bun" PATH="$HOME/.bun/bin:$PATH"
  ok "Bun installed"
fi

# ─── 2. OpenClaw ───
info "Installing OpenClaw..."
if command -v openclaw &>/dev/null; then
  ok "OpenClaw $(openclaw --version 2>/dev/null | head -1)"
else
  bun install -g openclaw 2>&1 | tail -1
  ok "OpenClaw installed"
fi

# ─── 3. Register agent (OpenClaw seeds its own brain templates) ───
info "Registering $AGENT agent..."
if openclaw agents list --json 2>/dev/null | grep -q "\"$AGENT\""; then
  ok "Agent '$AGENT' already registered"
else
  openclaw agents add --name "$AGENT" --non-interactive 2>/dev/null \
    && ok "Agent '$AGENT' registered" \
    || warn "Run manually: openclaw agents add --name $AGENT"
fi

WORKSPACE=$(openclaw agents show "$AGENT" --json 2>/dev/null | grep -oP '"workspace"\s*:\s*"\K[^"]+' || echo "$HOME/.openclaw/agents/$AGENT/workspace")

# ─── 4. Skill pack ───
echo ""
info "Select a skill pack (optional):"
echo "  1) 👔 Executive"
echo "  2) 🏫 Education"
echo "  3) 🏛️ Government"
echo "  4) 🏪 SME"
echo "  5) Skip"
echo ""
read -rp "Choose [1-5]: " PICK

case $PICK in
  1) SKILL="executive" ;; 2) SKILL="education" ;; 3) SKILL="government" ;; 4) SKILL="sme" ;; *) SKILL="" ;;
esac

if [[ -n "$SKILL" ]]; then
  DEST="$WORKSPACE/skills/nimmit-${SKILL}"
  mkdir -p "$DEST"
  curl -fsSL "$SKILL_BASE/$SKILL/SKILL.md" -o "$DEST/SKILL.md" \
    && ok "$SKILL skill pack installed" \
    || warn "Could not download skill pack"
fi

# ─── 5. Telegram ───
echo ""
read -rp "Telegram bot token (blank to skip): " TG_TOKEN
if [[ -n "$TG_TOKEN" ]]; then
  ENV_FILE="$HOME/.openclaw/.env"
  mkdir -p "$(dirname "$ENV_FILE")"
  if [[ -f "$ENV_FILE" ]] && grep -q "TELEGRAM_BOT_TOKEN" "$ENV_FILE"; then
    sed -i "s/TELEGRAM_BOT_TOKEN=.*/TELEGRAM_BOT_TOKEN=\"$TG_TOKEN\"/" "$ENV_FILE"
  else
    echo "TELEGRAM_BOT_TOKEN=\"$TG_TOKEN\"" >> "$ENV_FILE"
  fi
  chmod 600 "$ENV_FILE"
  openclaw config set channels.telegram.enabled true 2>/dev/null || true
  ok "Telegram configured"
fi

# ─── 6. systemd service ───
info "Setting up service..."
SERVICE="$HOME/.config/systemd/user/openclaw-gateway.service"
mkdir -p "$(dirname "$SERVICE")"
cat > "$SERVICE" << EOF
[Unit]
Description=OpenClaw Gateway ($AGENT)
After=network-online.target

[Service]
Type=simple
EnvironmentFile=$HOME/.openclaw/.env
ExecStart=$(which bun) run $(which openclaw) gateway
Restart=on-failure
RestartSec=10

[Install]
WantedBy=default.target
EOF
systemctl --user daemon-reload 2>/dev/null || true
systemctl --user enable openclaw-gateway 2>/dev/null || true
ok "Service configured"

# ─── Done ───
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "  \033[0;32m🦅 Nimmit is ready.\033[0m"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  Start: openclaw gateway --force"
echo "  Or:    systemctl --user start openclaw-gateway"
echo ""
