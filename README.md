# OpenClaw Agent Template

> Set up your own AI team in 5 minutes. A complete template for deploying autonomous AI agents across all business functions.

## What this is

A production-ready template for creating AI agents that run on OpenClaw. Each agent has:
- A **brain** with personality, memory, and specialized skills
- **9 departments** covering all business functions
- **Autonomous operation** via systemd services
- **Swappable AI models** — Gemini, Claude, GPT, GLM, or others
- **Multiple channels** — Telegram, Discord, or API

## What you get

| Component | Description |
|-----------|-------------|
| **Brain template** | `brain/` — Identity, soul, memory structure, agent specializations |
| **Config templates** | `config/` — OpenClaw config, model settings, division souls |
| **Skills** | `skills/` — Pre-built skills for web apps, auth, payments |
| **App templates** | `templates/` — Next.js + Supabase starter |
| **One-line install** | `install.sh` — Interactive setup wizard |

## Quick start

```bash
curl -fsSL https://raw.githubusercontent.com/koompi/koompi-nimmit/master/install.sh | bash
```

The installer will:
1. Ask for your agent name, company, and contact info
2. Set up Telegram bot and AI model credentials
3. Install OpenClaw runtime
4. Deploy your agent brain
5. Start background services

### Non-interactive (for CI/automation)

```bash
bash install.sh --non-interactive \
  --name "Atlas" \
  --org "Acme Corp" \
  --owner "Jane Doe" \
  --owner-id "123456789" \
  --token "123:ABC..." \
  --google-key "AIza..."
```

## Post-install quick start

### 1. Start chatting
Send a message to your Telegram bot:
```
/build a todo app with next.js
```

### 2. Check status
```bash
# Is the agent running?
systemctl --user status openclaw

# View live logs
journalctl --user -u openclaw -f
```

### 3. Change models (on the fly)
In chat:
```
/model opus
```
Switches between Claude, Gemini, GPT-4, etc.

## Departments

Your AI agent operates across 9 departments, each with its own SOUL (personality and focus):

| Department | Focus |
|-----------|-------|
| **Build** | Engineering, code, infrastructure |
| **Product** | Strategy, research, roadmap |
| **Content** | Writing, video, design |
| **Growth** | SEO, analytics, paid acquisition |
| **Revenue** | Sales, partnerships, pricing |
| **Distribution** | Channels, partnerships, delivery |
| **Client Success** | Onboarding, support, retention |
| **Intelligence** | Competitive intel, market analysis |
| **Ops** | Process, project management |

## Tech stack

| Component | Technology |
|-----------|-----------|
| Runtime | OpenClaw |
| Webapp framework | Next.js 16+ (via templates) |
| Database/Auth/Storage | Supabase (via templates) |
| Primary model | Configurable (default: Gemini 3.1 Pro) |
| Model routing | OpenClaw — swappable at runtime via /model |
| Coding model | Claude Code + Copilot sub-agents |
| Primary channel | Telegram |
| Language | TypeScript strict |
| Package manager | Bun (never npm) |

## Requirements

- Linux (Ubuntu 22.04+ or Arch-based)
- 2GB RAM minimum, 4GB recommended
- Telegram bot token (create with @BotFather)
- At least one AI model API key (Google, GitHub Copilot, or ZAI/GLM)

## Structure

```
koompi-nimmit/
├── install.sh               # One-command setup
├── brain/                   # AI team brain template
│   ├── SOUL.md              # Core personality and rules
│   ├── IDENTITY.md          # Who you are
│   ├── AGENTS.md            # Department routing and startup
│   ├── TOOLS.md             # Capabilities and model config
│   ├── MEMORY.md            # Memory system docs
│   ├── topics/              # Department-specific souls (9 divisions)
│   │   ├── build/
│   │   ├── product/
│   │   ├── content/
│   │   ├── growth/
│   │   ├── revenue/
│   │   ├── distribution/
│   │   ├── client-success/
│   │   ├── intelligence/
│   │   └── ops/
│   ├── agents/              # Specialist agent definitions
│   │   ├── ROUTING.md       # Task routing rules
│   │   └── ROSTER.md        # Agent roster
│   └── memory/              # Memory directory structure
│       ├── daily/
│       ├── semantic/
│       ├── procedural/
│       ├── decisions/
│       ├── failures/
│       ├── episodic/
│       ├── outcomes/
│       ├── research/
│       └── working/
├── config/                  # Configuration templates
│   ├── openclaw.template.json
│   ├── models.json
│   ├── divisions/           # Division SOUL templates
│   └── claude-code/         # Claude Code settings
├── skills/                  # Pre-built skills
├── templates/               # App templates
├── systemd/                 # Service files
└── README.md
```


## Troubleshooting

| Issue | Solution |
|-------|----------|
| Bot doesn't respond | 1. Check service: `systemctl --user status openclaw`<br>2. Check logs: `journalctl --user -u openclaw -n 50`<br>3. Verify bot token in `~/.openclaw/<slug>/.env` |
| "Permission denied" errors | Run: `loginctl enable-linger $USER` then reboot |
| Node not found after install | Restart shell or run: `source ~/.bashrc` (nvm needs PATH update) |
| Port 18789 already in use | Something else is using the gateway port. Check: `lsof -i :18789` |
| Agent forgets context | Check disk space: `df -h ~/.openclaw/`. Memory fills up over time. |
| Model returns errors | Verify API keys in `.env` file. Try `/model <different-model>` in chat. |
| Services stop on logout | Run: `sudo loginctl enable-linger $USER` |

### Get help
- Check logs: `journalctl --user -u openclaw -b`
- Open an issue: https://github.com/koompi/koompi-nimmit/issues
- OpenClaw docs: https://github.com/koompi/openclaw

## Upgrading

Your agent auto-updates OpenClaw every 6 hours via `openclaw-update.timer`.

### Manual upgrade
```bash
bun install -g openclaw
systemctl --user restart openclaw
```

### Upgrade brain template
```bash
cd ~/.openclaw/<slug>
git pull origin master
systemctl --user restart openclaw
```

## License

Apache License 2.0 — see [LICENSE](LICENSE)

## Acknowledgments

Built on [OpenClaw](https://github.com/koompi/openclaw) — the open-source AI agent runtime.
