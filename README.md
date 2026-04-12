# Nimmit Brain

> Deploy an AI team that runs your business. Install in 5 minutes, customize in 5 more.

**Nimmit Brain** is the brain template behind [Nimmit Cloud](https://nimmit.koompi.cloud) and [Nimmit Mini](https://koompi.com/nimmit). It's the open-source template for an autonomous AI operations team — the same one KOOMPI uses to run its companies.

Built by [KOOMPI](https://koompi.com). Powered by [OpenClaw](https://github.com/openclaw/openclaw).

## What This Is

Not a chatbot. Not a coding tool. An AI teammate that handles ops, growth, finance, design, and engineering — 24/7.

- **Message-native** — your team works via Telegram, Discord, WhatsApp, or Slack. No dashboards needed.
- **Autonomous** — heartbeat tasks, scheduled work, proactive monitoring. It works while you sleep.
- **Multi-agent** — two or more agents share one brain, cover each other's blind spots, and collaborate.
- **Self-evolving** — learns from you AND from every other Nimmit user. Weekly lesson sharing. Everyone gets smarter.
- **Swappable models** — Claude, GPT, Gemini, GLM. Identity persists across switches.
- **Cold standby** — $0 idle cost. Roles activate on demand.

## Three Products, One Brain

| Product | What | Who | Price |
|---------|------|-----|-------|
| **Nimmit Cloud** | Hosted SaaS. Sign up, configure, go. | Startups, agencies, SMBs | $29-99/mo |
| **Nimmit Mini** | Pre-installed on KOOMPI Mini. Zero config. | Government, schools, offline orgs | $499 + $29/mo |
| **Nimmit Enterprise** | Custom deployment, multi-team, SLA. | Large orgs, ministries | Custom |

**This repo is the brain template** shared by all three. Install it locally, customize it, or contribute to the open-source project.

## Quick Start

```bash
curl -fsSL https://raw.githubusercontent.com/koompi/nimmit-brain/master/install.sh | bash
```

### What You Get

| Component | Description |
|-----------|-------------|
| **Brain template** | `brain/` — Personality, identity, memory, roles, company context |
| **Setup wizard** | `install.sh` — One-command deploy with bot token + API key |
| **Config templates** | `config/` — OpenClaw config, model routing, API settings |
| **Skills** | `skills/` — Pre-built capabilities (cloud, ecommerce, auth, payments, docs) |
| **Memory system** | `brain/memory/` — 8-category architecture that compounds over time |

### Non-interactive (CI/automation)

```bash
bash install.sh --non-interactive --token "123:ABC..." [--google-key "AIza..."]
```

## How It Works

```
You message the bot on Telegram/Discord/WhatsApp
        │
        ▼
AI agent receives task → identifies what's needed → executes
        │
        ▼
If complex: spawns sub-agents (coding, research, design)
        │
        ▼
Delivers result → logs outcome → gets smarter
```

**No dashboards. No Jira. No standup meetings. Just message, get work done.**

### What Your AI Team Handles

| Function | Examples |
|----------|---------|
| **Engineering** | Code, architecture, deploys, bug fixes |
| **Product** | Specs, roadmaps, user research |
| **Growth** | Marketing, sales outreach, partnerships |
| **Operations** | Finance, HR, logistics, admin |
| **Design** | Brand, UX, visual assets, content |
| **DevOps** | Infrastructure, monitoring, CI/CD |
| **Strategy** | Direction, coordination, resource allocation |
| **QA** | Testing, code review, quality gates |

Adapt the roles to your company. Solo founder? Use all 8. 50-person agency? Add specialized roles.

## Multi-Agent Collaboration

Two or more agents can share one brain and coordinate:

- **Shared workspace** — agents sync via git on a shared repo
- **Handoff system** — async messages between agents with <24h response SLA
- **Proposal system** — joint decisions with discussion, scoring, and escalation
- **Heartbeat deduplication** — avoids redundant work when multiple agents are online
- **Token optimization** — git-log-first pattern, delta reads, shared intel pipeline

See `PROTOCOL.md` in [nimmit-workspace](https://github.com/koompi/nimmit-workspace) for the full coordination protocol.

## Memory Architecture

```
brain/memory/
├── daily/          # Daily logs
├── semantic/       # What things are (products, team, tech)
├── procedural/     # How to do things (deploy, build, troubleshoot)
├── decisions/      # Why we decided
├── failures/       # What failed (known issues, lessons)
├── episodic/       # What happened when (events, intel)
├── outcomes/       # Project outcomes and deliverables
├── research/       # Research notes
└── working/        # Current state
```

Memory compounds. The longer your team runs, the more context it has.

## Tech Stack

| Component | Technology |
|-----------|-----------|
| Runtime | [OpenClaw](https://github.com/openclaw/openclaw) (MIT) |
| Coding agents | Claude Code, Copilot sub-agents |
| Models | Claude, GPT, Gemini, GLM (swappable) |
| Database | Supabase (PostgreSQL) or Cloudflare D1 (SQLite) |
| Channels | Telegram, Discord, WhatsApp, Slack |
| Language | TypeScript strict |
| Package manager | Bun |

## Structure

```
nimmit-brain/
├── install.sh               # One-command setup
├── MIGRATION-GUIDE.md       # Customize for your company
├── brain/                   # AI team brain template
│   ├── SOUL.md              # Personality and communication
│   ├── IDENTITY.md          # Who you are
│   ├── AGENTS.md            # Roles and session protocol
│   ├── COMPANY.md           # Business context (fill in yours)
│   ├── USER.md              # Founder profile (fill in yours)
│   ├── TOOLS.md             # Capabilities and model config
│   ├── WORKFLOW.md          # Memory and task system
│   ├── HEARTBEAT.md         # Scheduled tasks and health checks
│   ├── BOOTSTRAP.md         # First-run setup
│   ├── MEMORY.md            # Memory index
│   ├── ARCHITECTURE.md      # Runtime self-awareness
│   ├── STANDARDS.md         # Quality and process standards
│   ├── agents/              # Role routing and roster
│   ├── memory/              # Memory directories
│   ├── projects/            # Active project tracking
│   ├── tasks/               # Task queue
│   └── users/               # User profiles
├── config/                  # Configuration templates
├── skills/                  # Pre-built skills
├── templates/               # App templates
├── systemd/                 # Service files
└── README.md
```

## Requirements

- Linux (Ubuntu 22.04+ or Arch-based)
- 2GB RAM minimum, 4GB recommended
- Telegram/Discord bot token
- At least one AI model API key (Google, GitHub Copilot, or ZAI/GLM)

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Bot doesn't respond | `systemctl --user status openclaw` then check logs |
| "Permission denied" | `loginctl enable-linger $USER` then reboot |
| Port 18789 in use | `lsof -i :18789` |
| Agent forgets context | Check disk: `df -h ~/.openclaw/` |
| Model errors | Verify API keys. Try `/model <different>` in chat |

### Get help
- Issues: https://github.com/koompi/nimmit-brain/issues
- OpenClaw docs: https://docs.openclaw.ai
- Community: https://discord.com/invite/clawd

## Upgrading

```bash
bun install -g openclaw
systemctl --user restart openclaw
```

Brain updates are pulled from this repo. Your customizations are never overwritten.

## Contributing

We ship Nimmit Brain as open-source (Apache 2.0). Contributions welcome:
- New skills for the `skills/` directory
- Industry-specific templates
- Documentation improvements
- Bug fixes

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## Roadmap

- [ ] Nimmit Cloud MVP — hosted SaaS, sign up in 2 minutes
- [ ] Web setup wizard — replace CLI with web UI
- [ ] Industry templates — agency, SaaS, ecommerce, restaurant
- [ ] Brain export from running instance
- [ ] Skill marketplace
- [ ] Stripe billing integration

## License

Apache License 2.0 — see [LICENSE](LICENSE)

## Acknowledgments

Built on [OpenClaw](https://github.com/openclaw/openclaw) — the open-source AI agent runtime.
