# MEMORY.md — Long-Term Index

## Memory Architecture
```
memory/
├── daily/          # Daily logs (one per day)
├── semantic/       # What things are (products, team, tech, business)
├── procedural/     # How to do things (deploy, new project, learn from corrections)
├── decisions/      # Why we decided (monthly decision logs)
├── failures/       # What failed (known-issues.md, lessons-log.md)
├── episodic/       # What happened when (events, competitive intel)
├── outcomes/       # Project outcomes and deliverables
├── research/       # Research notes and analysis
└── working/        # Current project state (NOW.md lives here)
```

### Memory Type Decision Tree
| Content type | Destination |
|--------------|-------------|
| What X is (products, people, tech) | semantic/ |
| How to do X (deploy, configure, fix) | procedural/ |
| Why we decided X | decisions/ |
| What happened when (events, intel) | episodic/ |
| What failed and why | failures/ |
| Analysis of X (research, comparisons) | research/ |
| Project state (current tasks) | working/ |
| Project results | outcomes/ |
| Daily activity log | daily/ |

## Projects
See `projects/README.md` for active projects.

## Repositories
- `rithythul/koompi-claw` — Nimmit's brain (internal)
- `koompi/nimmit-brain` — Product template (client-facing)

## Key Context
- **Architecture:** Nimmit = identity + brain files. OpenClaw = runtime. Models = swappable engines.
- **Coding:** OpenClaude first → Copilot → Claude Code
- **KOOMPI business:** Cloud, Nimmit.ai, Enterprise, Hardware, Claw. See `memory/semantic/koompi-business-structure.md`
- **Access:** DMs open (gated), groups whitelist-only. New users → Rithy for approval.

## Key Lessons
- Communication: short, concise, direct. "Got it." then fix.
- Bun not npm. TypeScript strict. Always.
- Code → `~/workspace/<project>/` | Brain → `~/.openclaw/nimmit/` | Secrets → `~/.secrets/`
- You CAN be proactive — use cron.
- Execute approved plans without re-asking.
- Khmer content must be reviewed by native speaker (Rithy) before shipping. Tag with '🇰🇭 review needed'. If unavailable, use English + note 'pending Khmer translation'.
- SQLite brain at `~/.openclaw/nimmit/brain.db` for structured queries.

### Context Budget (per session)
- NOW.md + TASKS.md: always load (~2000 tokens)
- Daily logs: last 3 days only (~3000 tokens)
- Semantic memory: lazy load by topic (~1000 tokens each)
- Role context: only for active role (~500 tokens)
- Trim oldest first. Target: <50k tokens per task.
