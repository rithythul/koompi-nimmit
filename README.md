# Nimmit Brain

> Your AI team in 5 minutes. 8 functional roles, one brain, mesh structure. Runs on OpenClaw.

**Nimmit Brain** is the exported brain, configuration, and setup for an autonomous AI team. Install it on a KOOMPI Mini (or any Linux machine) and get a team that works 24/7 — running operations, writing code, handling growth, and managing your business.

Built by [KOOMPI](https://koompi.com). Powered by [OpenClaw](https://github.com/koompi/openclaw).

## What this is

Not a chatbot — a teammate. Not a tool — a team member.

- **8 functional roles:** Strategy, Product, Engineering, Design, DevOps, Growth, Operations, QA
- **Mesh structure** — roles collaborate directly, not through hierarchy
- **Autonomous operation** — heartbeat tasks, scheduled work, proactive monitoring
- **Swappable AI models** — Claude, GPT, Gemini, GLM, or others. Identity persists across switches.
- **Multi-agent coordination** — multiple agents share one brain, cover each other's blind spots
- **Memory that compounds** — learns from decisions, failures, and outcomes. Gets smarter every week.
- **Multi-channel** — Telegram, Discord, Signal, WhatsApp, or API
- **Cold standby** — $0 idle cost, roles activate on demand

## What you get

| Component | Description |
|-----------|-------------|
| **Brain template** | `brain/` — Personality, identity, memory, roles, company context |
| **Migration guide** | `MIGRATION-GUIDE.md` — Customize for your company in 5 minutes |
| **Config templates** | `config/` — OpenClaw config, model routing, API settings |
| **Skills** | `skills/` — Pre-built capabilities (cloud, ecommerce, auth, payments, docs) |
| **Memory system** | `brain/memory/` — 8-category memory architecture that compounds over time |
| **One-line install** | `install.sh` — Set up with bot token + API key |

## Quick start

```bash
curl -fsSL https://raw.githubusercontent.com/koompi/nimmit-brain/master/install.sh | bash
```

Then enter your Telegram bot token when prompted.

The installer sets up OpenClaw, deploys the brain, and starts background services.

### Non-interactive (CI/automation)

```bash
bash install.sh --non-interactive --token "123:ABC..." [--google-key "AIza..."]
```

## How it works

### Architecture

```
{{OWNER_NAME}} (CEO & Founder)
└── {{AGENT_NAME}} (AI Team)
        Strategy
       ╱        ╲
  Product      Engineering
     \            /
  Design      DevOps
       \        /
  Growth      Operations
       \        /
        QA
```

**Mesh, not hierarchy.** Roles collaborate directly across all business lines. No product-specific roles — products change, functions endure.

### Roles

| Role | Owns | Suggested Model |
|------|------|----------------|
| **Strategy** | Direction, coordination, resource allocation | Claude Opus / GPT-5.4 |
| **Product** | What to build, design, roadmap, specs | Claude Opus / GPT-5.4 |
| **Engineering** | Code, architecture, feature development | Claude Code / Copilot |
| **Design** | Brand, UX, visual identity, content design | Claude Opus / GPT-5.4 |
| **DevOps** | Infrastructure, CI/CD, deployments, monitoring | Claude Opus / GPT-5.4 |
| **Growth** | Marketing, sales, partnerships, revenue | GPT-5.4 / Claude |
| **Operations** | Finance, logistics, HR, admin, legal | GPT-5.4 / Claude |
| **QA** | Testing, code review, quality gates | GPT-5.4 / Claude |

### Task Flow

1. **Task arrives** → identify which role(s) → execute → deliver
2. **Multi-role tasks** → roles collaborate directly (mesh, not chain)
3. **Needs CEO** → escalate, don't decide
4. **Heartbeat** → scheduled checks, proactive monitoring, daily briefs
5. **Memory** — persistent across sessions. Writes down what matters.

### Multi-Agent Coordination

Nimmit Brain supports running multiple agents that share one brain:

- **Master-master model** — both agents are orchestrators, both can spawn sub-agents
- **Shared workspace** — agents coordinate via `git pull`/`push` on a shared repo
- **Handoff system** — async messages between agents with <24h response SLA
- **Proposal system** — joint decisions with discussion, approval, and escalation
- **Heartbeat deduplication** — avoids redundant work when multiple agents are online
- **Token optimization** — git-log-first pattern, delta reads, shared intel pipeline

### Memory Architecture

```
brain/memory/
├── daily/          # Daily logs (one per day)
├── semantic/       # What things are (products, team, tech, business)
├── procedural/     # How to do things (deploy, build, troubleshoot)
├── decisions/      # Why we decided (monthly decision logs)
├── failures/       # What failed (known issues, lessons learned)
├── episodic/       # What happened when (events, competitive intel)
├── outcomes/       # Project outcomes and deliverables
├── research/       # Research notes and analysis
└── working/        # Current state (NOW.md lives here)
```

Memory compounds. The longer your AI team runs, the more context it has. Decisions, failures, and outcomes are never forgotten.

### Adapting for your company

| Company type | Recommended roles |
|-------------|-------------------|
| **Solo founder** | All 8 — you're the CEO, AI handles the rest |
| **Startup (5-20)** | Product, Engineering, Growth (+ QA when scaling) |
| **Agency** | Product, Engineering, Design, Growth, Operations |
| **Enterprise** | All 8 + add specialized roles as needed |

## Tech stack

| Component | Technology |
|-----------|-----------|
| Runtime | [OpenClaw](https://github.com/koompi/openclaw) |
| Coding agents | Claude Code + Copilot sub-agents |
| Models | Claude, GPT, Gemini, GLM (swappable at runtime) |
| Primary channel | Telegram |
| Language | TypeScript strict |
| Package manager | Bun |

## Requirements

- Linux (Ubuntu 22.04+ or Arch-based)
- 2GB RAM minimum, 4GB recommended
- Telegram bot token (create with @BotFather)
- At least one AI model API key (Google, GitHub Copilot, or ZAI/GLM)

## Structure

```
nimmit-brain/
├── install.sh               # One-command setup
├── MIGRATION-GUIDE.md       # Customize for your company
├── CHANGELOG.md             # Version history
├── brain/                   # AI team brain template
│   ├── SOUL.md              # Core personality and communication rules
│   ├── IDENTITY.md          # Who you are
│   ├── AGENTS.md            # Org structure, roles, session protocol
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
│   │   ├── README.md        # Quick reference
│   │   ├── ROUTING.md       # Task → role → model routing
│   │   └── ROSTER.md        # Role definitions
│   ├── memory/              # Memory directory structure
│   │   ├── daily/
│   │   ├── semantic/
│   │   ├── procedural/
│   │   ├── decisions/
│   │   ├── failures/
│   │   ├── episodic/
│   │   ├── outcomes/
│   │   ├── research/
│   │   └── working/
│   ├── projects/            # Active project tracking
│   ├── tasks/               # Task queue
│   └── users/               # User profiles
├── config/                  # Configuration templates
│   ├── openclaw.template.json
│   ├── models.json
│   └── claude-code/
├── skills/                  # Pre-built skills
├── templates/               # App templates
├── systemd/                 # Service files
├── bin/                     # Utility scripts
└── README.md
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Bot doesn't respond | `systemctl --user status openclaw` then check logs |
| "Permission denied" | `loginctl enable-linger $USER` then reboot |
| Port 18789 in use | `lsof -i :18789` |
| Agent forgets context | Check disk: `df -h ~/.openclaw/` |
| Model errors | Verify API keys. Try `/model <different>` in chat |
| High token usage | Check heartbeat isn't reading unchanged files |

### Get help
- Issues: https://github.com/koompi/nimmit-brain/issues
- OpenClaw docs: https://docs.openclaw.ai
- Community: https://discord.com/invite/clawd

## Upgrading

```bash
bun install -g openclaw
systemctl --user restart openclaw
```

Brain updates are pulled from this repo. Your customizations (COMPANY.md, USER.md, memory/) are never overwritten.

## Evolution

This brain is actively maintained and evolving. Key improvements are tracked in [CHANGELOG.md](CHANGELOG.md).

Recent milestones:
- **Multi-agent coordination** — shared workspace, handoff system, proposal system
- **Token optimization** — git-log-first, heartbeat dedup, delta reads
- **Memory architecture v2** — 8-category system with compounding context
- **Setup wizard** — interactive 5-question company customization

## Roadmap

- [ ] Setup wizard (5-question company config)
- [ ] Industry templates (agency, SaaS, ecommerce)
- [ ] Brain export from running instance
- [ ] Multi-agent dashboard
- [ ] Skill marketplace
- [ ] Token usage analytics

## License

Apache License 2.0 — see [LICENSE](LICENSE)

## Acknowledgments

Built on [OpenClaw](https://github.com/koompi/openclaw) — the open-source AI agent runtime.
