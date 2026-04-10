# {{AGENT_NAME}}

> Your AI team in 5 minutes. 8 functional roles, one brain, mesh structure. Runs on OpenClaw.

## What this is

A production-ready template for an AI team that runs your company. Not a chatbot — a teammate.

- **8 functional roles:** Strategy, Product, Engineering, Design, DevOps, Growth, Operations, QA
- **Mesh structure** — roles collaborate directly, not through hierarchy
- **Autonomous operation** — heartbeat tasks, scheduled work, proactive monitoring
- **Swappable AI models** — Claude, GPT, Gemini, GLM, or others. Identity persists across switches.
- **Multi-channel** — Telegram, Discord, or API
- **Cold standby** — $0 idle cost, roles activate on demand

## What you get

| Component | Description |
|-----------|-------------|
| **Brain template** | `brain/` — Personality, memory, roles, company context |
| **Migration guide** | `MIGRATION-GUIDE.md` — Customize for your company in 5 minutes |
| **Config templates** | `config/` — OpenClaw config, model settings |
| **Skills** | `skills/` — Pre-built capabilities (cloud, ecommerce, auth, payments) |
| **One-line install** | `install.sh` — Set up with bot token + API key |

## Quick start

```bash
curl -fsSL https://raw.githubusercontent.com/koompi/koompi-nimmit/master/install.sh | bash
```

Then enter your Telegram bot token when prompted.

The installer sets up OpenClaw, deploys the brain, and starts background services.

### Non-interactive (CI/automation)

```bash
bash install.sh --non-interactive --token "123:ABC..." [--google-key "AIza..."]
```

## Org Structure

```
{{OWNER_NAME}} (CEO & Founder)
└── {{AGENT_NAME}} (AI Team)
        Strategy
       ╱        ╲
  Product      Engineering
     ╲            ╱
  Design      DevOps
       ╲        ╱
  Growth      Operations
       ╲        ╱
        QA
```

**Mesh, not hierarchy.** Roles collaborate directly across all business lines. No product-specific roles — products change, functions endure.

### Roles

| Role | Owns |
|------|------|
| **Strategy** | Direction, coordination, resource allocation |
| **Product** | What to build, design, roadmap, specs |
| **Engineering** | Code, architecture, feature development |
| **Design** | Brand, UX, visual identity, content design |
| **DevOps** | Infrastructure, CI/CD, deployments, monitoring |
| **Growth** | Marketing, sales, partnerships, revenue |
| **Operations** | Finance, logistics, HR, admin, legal |
| **QA** | Testing, code review, quality gates |

### Adapting for your company

| Company type | Recommended roles |
|-------------|-------------------|
| **Solo founder** | All 8 — you're the CEO, AI handles the rest |
| **Startup** | Product, Engineering, Growth (+ QA when scaling) |
| **Agency** | Product, Engineering, Design, Growth, Operations |
| **Enterprise** | All 8 + add specialized roles as needed |

## How it works

1. **Task arrives** → identify which role(s) → execute → deliver
2. **Multi-role tasks** → roles collaborate directly (mesh, not chain)
3. **Needs CEO** → escalate, don't decide
4. **Heartbeat** → scheduled checks, proactive monitoring, daily briefs
5. **Memory** — persistent across sessions. Writes down what matters. Forgets what doesn't.

## Tech stack

| Component | Technology |
|-----------|-----------|
| Runtime | [OpenClaw](https://github.com/koompi/openclaw) |
| Coding | Claude Code + Copilot sub-agents |
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
koompi-nimmit/
├── install.sh               # One-command setup
├── MIGRATION-GUIDE.md       # Customize for your company
├── brain/                   # AI team brain template
│   ├── SOUL.md              # Core personality (7 Rules, Tensions, Anti-Patterns)
│   ├── IDENTITY.md          # Who you are
│   ├── AGENTS.md            # Org structure and roles
│   ├── COMPANY.md           # Business context (fill in yours)
│   ├── USER.md              # Founder profile (fill in yours)
│   ├── TOOLS.md             # Capabilities and model config
│   ├── WORKFLOW.md          # Memory and task system
│   ├── HEARTBEAT.md         # Scheduled tasks and health checks
│   ├── BOOTSTRAP.md         # First-run setup
│   ├── MEMORY.md            # Memory index
│   ├── ARCHITECTURE.md      # Runtime self-awareness
│   ├── agents/              # Role routing and roster
│   │   ├── README.md        # Quick reference
│   │   ├── ROUTING.md       # Task → role → model routing
│   │   └── ROSTER.md        # Role definitions
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
│   └── claude-code/
├── skills/                  # Pre-built skills
├── templates/               # App templates
├── systemd/                 # Service files
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

### Get help
- Issues: https://github.com/koompi/koompi-nimmit/issues
- OpenClaw docs: https://docs.openclaw.ai

## Upgrading

```bash
bun install -g openclaw
systemctl --user restart openclaw
```

## License

Apache License 2.0 — see [LICENSE](LICENSE)

## Acknowledgments

Built on [OpenClaw](https://github.com/koompi/openclaw) — the open-source AI agent runtime.
