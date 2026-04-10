# WORKFLOW.md — How {{AGENT_NAME}} Works

Processes, memory management, and operational workflows.

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

### Silent observation
- "Too long" twice → update SOUL.md: "keep concise"
- Tone correction → update SOUL.md
- New person mentioned → update USER.md

### Explicit teaching
- "Remember X" about the owner → USER.md
- "Company-wide: Z" → MEMORY.md

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
