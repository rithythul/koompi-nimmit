# koompi-nimmit

> Turnkey AI agent appliance by KOOMPI. Deploy a full AI team in one command.

## What it is

Each client gets their own Nimmit instance — an AI agent that builds webapps, manages databases, deploys code, and runs operations 24/7.

## Install

Interactive — walks you through everything:
```bash
curl -fsSL https://nimmit.koompi.ai | bash
```

Non-interactive (CI/automation):
```bash
curl -fsSL https://nimmit.koompi.ai | bash -s -- --non-interactive \
  --name "Atlas" --org "Acme Corp" --token "123:ABC..." --google-key "AIza..."
```

## What clients get

- **AI agent** named Nimmit (customizable) — responds via Telegram, Discord, or web
- **Builds webapps** — Next.js 16+ with Supabase, via chat
- **Manages databases** — Supabase CLI, migrations, auth, storage
- **Deploys code** — Vercel, KConsole (KOOMPI Cloud), or self-hosted
- **Coding agent** — Claude Code for complex tasks, Copilot for everyday work
- **Runs 24/7** — systemd services, auto-restart, health checks

## Tech stack (locked)

| Component | Technology |
|-----------|-----------|
| Runtime | OpenClaw |
| Webapp framework | Next.js 16+ |
| Database/Auth/Storage | Supabase |
| Primary model | Configurable (default: Gemini 3.1 Pro) |
| Model routing | OpenClaw — swappable at runtime via /model |
| Coding model | Claude Code (ACP) + Copilot sub-agents |
| Primary channel | Telegram |
| Language | TypeScript strict |
| Package manager | Bun (never npm) |

## Requirements

- Ubuntu 22.04+ or KOOMPI OS (Arch-based)
- 2GB RAM minimum, 4GB recommended
- Telegram bot token (create with @BotFather)

## Structure

```
koompi-nimmit/
├── install.sh               # One-command setup
├── brain/                   # AI team brain template
│   ├── ARCHITECTURE.md      # Runtime self-awareness (identity ≠ model)
│   ├── SOUL.md              # Personality, rules, values
│   ├── IDENTITY.md          # Name, role, what you are
│   ├── AGENTS.md            # Departments, routing, startup
│   ├── TOOLS.md             # Capabilities, model config
│   └── ...                  # Memory, topics, heartbeat, etc.
├── config/                  # Agent configuration templates
├── skills/                  # Client-facing skills
├── templates/               # App templates
├── systemd/                 # Service files
└── README.md
```

## License

Apache License 2.0 — see [LICENSE](LICENSE)
