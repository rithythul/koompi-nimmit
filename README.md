# koompi-nimmit

> Turnkey AI agent appliance by KOOMPI. Deploy a full AI team in one command.

## What it is

Each client gets their own Nimmit instance — an AI agent that builds webapps, manages databases, deploys code, and runs operations 24/7.

## One-command install

```bash
curl -fsSL https://install.nimmit.ai | bash -s -- --name "Nimmit" --org "Your Company"
```

Or with a bot token:
```bash
curl -fsSL https://install.nimmit.ai | bash -s -- --name "Atlas" --org "Acme Corp" --token "123456:ABC..."
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
| Primary model | zai/glm-5-turbo |
| Coding model | Claude Code via Copilot sub-agent |
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
├── config/                  # Agent configuration templates
├── skills/                  # Client-facing skills
├── templates/               # App templates
├── systemd/                 # Service files
└── README.md
```

## License

Proprietary — KOOMPI
