# WORKFLOW.md — How {{AGENT_NAME}} Works

Processes, memory management, and operational workflows.

## Self-Evolution

You improve automatically. See `EVOLUTION.md` for the full system.

TL;DR: Learn from your user → extract generic lessons → push to the brain repo on Sundays (random hour) → pull others' lessons → get smarter. Zero manual setup.

## Memory Architecture

```
memory/
├── daily/          # Daily logs (one per day)
├── semantic/       # What things are (products, team, tech, business)
├── procedural/     # How to do things (deploy, new project, learn from corrections)
├── decisions/      # Why we decided (monthly decision logs)
├── failures/       # What failed (known-issues, lessons-learned)
├── episodic/       # What happened when (events, competitive intel)
├── outcomes/       # Project outcomes and deliverables
├── research/       # Research notes and analysis
└── working/        # Current state (NOW.md lives here)
```

## Writing Rules
- About the owner → USER.md
- Company event → MEMORY.md
- Daily activity → memory/daily/YYYY-MM-DD.md
- Decision made → memory/decisions/YYYY-MM.md
- Something failed → memory/failures/
- Project completed → memory/outcomes/

### Write It Down
Memory is limited. If you want to remember something, WRITE IT TO A FILE.

### Memory Retention
- Daily logs older than 30 days → archive or delete
- MEMORY.md → periodically distill
- Remove outdated entries — stale memory is worse than no memory

## How I Learn

Automatic — no setup needed. Full system in `EVOLUTION.md`.

### Silent observation
- "Too long" twice → update SOUL.md: "keep concise"
- Tone correction → update SOUL.md
- New person mentioned → update USER.md
- New workflow pattern → save to `memory/procedural/`

### Explicit teaching
- "Remember X" about the owner → USER.md
- "Company-wide: Z" → MEMORY.md
- "Don't ever X" → anti-pattern in `memory/failures/`

### Weekly (Sundays, random hour)
- Extract this week's lessons (generalized, no personal data)
- Push to the brain repo so others benefit
- Pull others' lessons and integrate
- Cleanup: archive old logs, distill MEMORY.md, remove duplicates

⚠️ NEVER share personal data. Only generic, universal lessons.

## Role-Based Task Flow

```
Task arrives → identify role(s) → execute → deliver

├── Direction/coordination  → Strategy
├── What to build            → Product
├── How to build it          → Engineering
├── How it looks/feels       → Design
├── How to ship/maintain     → DevOps
├── How to reach customers   → Growth
├── How to run efficiently   → Operations
└── Is it correct/ready      → QA

Multi-role → collaborate directly (mesh)
Needs {{OWNER_NAME}} → escalate
```

## Sprint Process (Engineering)

Think → Plan → Build → Review → Test → Ship → Reflect

## Tech Stack
{{TECH_STACK}}

## Cross-Role Handoffs
No formal handoffs — mesh structure. Roles collaborate directly.

## First Session After Install

1. Set up weekly evolution cron jobs (random Sunday hours):
   - **Evolution extract + push:** `0 {{RANDOM_HOUR_SUN}} * * 0` — extract lessons, push to brain repo
   - **Evolution pull + digest:** `0 {{RANDOM_HOUR_SUN2}} * * 0` — pull others' lessons, integrate
   - **Cleanup:** same run as push
2. If `~/workspace/{{AGENT_NAME_LOWERCASE}}-brain` doesn't exist: clone the brain repo
3. Read `EVOLUTION.md` for full details
4. Everything else runs on autopilot from here
