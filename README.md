# @koompi/nimmit

> Install an AI worker. Teach it your job. Let it work.

Built on [OpenClaw](https://github.com/openclaw/openclaw). Shipped by [KOOMPI](https://koompi.com).

## What Nimmit Does

Nimmit is an **AI worker that runs 24/7** on your machine. It doesn't wait to be asked. It wakes up, checks what needs doing, and does it.

- **Remembers everything** — your org, your preferences, your history. Gets sharper over time.
- **Works on its own** — proactive heartbeat checks tasks, deadlines, and inboxes without being prompted.
- **Executes, not just advises** — drafts the document, replies to the customer, prepares the report, updates the spreadsheet.
- **Talks to you where you are** — Telegram, terminal, or any channel OpenClaw supports.
- **Learns any domain** — install a skill pack or teach it yourself. School, factory, law firm, farm, clinic — the domain doesn't matter.

This isn't a chatbot. It's a team member that never sleeps.

## Install

**Quick start (installs Node.js + nimmit + runs guided setup):**

```bash
curl -fsSL https://nimmit.koompi.ai/install | bash
```

**Manual install:**

```bash
npm install -g @koompi/nimmit
nimmit onboard
```

Requires Node.js 22.16+.

## CLI Commands

```
nimmit onboard          # Guided first-time setup
nimmit status           # Show installation status
nimmit update           # Update OpenClaw runtime + refresh skills
nimmit skills list      # List all available skill packs
nimmit skills add <n>   # Install skill packs
nimmit skills remove <n># Remove skill packs
nimmit publish          # Publish skill packs to ClawHub
```

## OpenClaw Plugin

Nimmit also works as an OpenClaw plugin. When installed alongside OpenClaw, it registers slash commands (`/nimmit-status`, `/nimmit-skills`, `/nimmit-update`) directly in the AI assistant.

```json
{
  "openclaw": {
    "extensions": ["./dist/plugin.js"]
  }
}
```

## Skill Packs

Skill packs give Nimmit domain knowledge on day one. They're **starter kits, not limits** — Nimmit can learn any domain you teach it.

### Core

| Pack | Purpose |
|------|---------|
| **Memory** | Hierarchical storage, daily logging, weekly compaction, proactive memory hygiene |

Installed by default. Teaches Nimmit to write everything down, index (not dump), and prune aggressively.

### Business & Operations

| Pack | Domain |
|------|--------|
| **Executive** | Morning briefings, decision support, report drafting, strategic thinking |
| **SME** | Social media, customer service, inventory alerts, marketing, financials |
| **Finance** | AP/AR, reconciliation, budgets, P&L, cash flow, month-end close |
| **Creative** | Project management, client briefs, content calendars, asset management |
| **Logistics** | Shipment tracking, route planning, customs docs, fleet coordination |
| **Construction** | Scheduling, daily site reports, subcontractor coordination, safety compliance |

### Public Sector & Education

| Pack | Domain |
|------|--------|
| **Government** | Formal documents, meeting prep, procurement, compliance |
| **Education** | Scheduling, curriculum planning, attendance, parent communication |
| **Nonprofit** | Donor management, grant tracking, volunteer coordination, impact reporting |

### Professional Services

| Pack | Domain |
|------|--------|
| **Healthcare** | Patient scheduling, records, prescriptions, follow-ups, compliance |
| **Legal** | Case management, document drafting, deadline tracking, billing, discovery |
| **Real Estate** | Listings, client pipeline, contracts, market analysis |
| **Agriculture** | Crop planning, weather alerts, market prices, harvest tracking |
| **Hospitality** | Reservations, guest communication, housekeeping, revenue management |

### Intelligence & Research

| Pack | Domain |
|------|--------|
| **Geopolitical** | Conflict monitoring, sanctions tracking, scenario analysis, intelligence briefs |
| **Economist** | Macro indicators, central bank monitoring, forecasting, research notes |
| **Web Crawler** | Social media monitoring, brand tracking, competitor intelligence, trend detection |

All 18 skill packs are available on [ClawHub](https://clawhub.ai) under the `koompi/` namespace.

Don't see your domain? Nimmit works without a skill pack. Or write your own — it's a single markdown file.

## How It Works

```
You install Nimmit
    -> OpenClaw seeds the brain (SOUL.md, IDENTITY.md, HEARTBEAT.md)
    -> You pick a skill pack (domain knowledge + proactive behavior)
    -> Nimmit gets a heartbeat (wakes up, checks what needs doing, does it)
    -> It works — every day, on its own
```

## Structure

```
koompi-nimmit/
├── bin/nimmit.mjs              # CLI entry point
├── src/
│   ├── cli/
│   │   ├── index.ts            # CLI program definition
│   │   └── commands/
│   │       ├── onboard.ts      # Guided setup
│   │       ├── update.ts       # Runtime + skill refresh
│   │       ├── status.ts       # Installation status
│   │       ├── skills.ts       # Skill pack management
│   │       └── publish.ts      # ClawHub publishing
│   ├── config.ts               # Config I/O (~/.nimmit/config.json)
│   ├── skills.ts               # Skill pack registry + install/remove
│   ├── templates.ts            # Template rendering (SOUL/IDENTITY/HEARTBEAT)
│   ├── plugin.ts               # OpenClaw plugin interface
│   └── types.ts                # Shared types + VERSION
├── skill-packs/                # 18 bundled domain skill packs
├── templates/                  # Onboarding templates (SOUL.md, etc.)
├── install.sh                  # Bootstrap installer
├── worker/                     # Cloudflare Worker (nimmit.koompi.ai)
└── package.json
```

## License

Apache 2.0 — same as OpenClaw.
