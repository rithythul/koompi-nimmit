# HANDOFF.md — Handoff Processing Protocol

## What is a Handoff?
A handoff is a message, proposal, or task passed between sessions, roles, or humans. Stored in `handoff/` directory in nimmit-workspace.

## Handoff Format
```
---
from: [role or session]
to: [role or person]
type: proposal | task | info | decision-needed
priority: low | normal | high | urgent
created: YYYY-MM-DD HH:MM
---

[Content]
```

## Processing Checklist
1. `git pull` first — always. No exceptions.
2. Read all files in `handoff/`
3. For each handoff:
   - **proposal** → evaluate, respond with accept/reject/modify + reasoning
   - **task** → execute, log result
   - **info** → acknowledge, store in appropriate memory/ dir
   - **decision-needed** → research, provide recommendation with tradeoffs
4. Move processed handoffs to `handoff/archive/`
5. Commit and push

## Response Templates
- Accept: `Handoff accepted. [brief plan]. ETA: [time].`
- Reject: `Handoff rejected. Reason: [why]. Alternative: [if any].`
- Modify: `Handoff modified. Original: [X]. Changed to: [Y]. Reason: [why].`
- Blocked: `Handoff blocked. Need: [specific missing info]. Notifying [owner].`

## Rules
- Never process handoffs without fresh `git pull`
- Never delete handoffs — archive only
- If handoff is >7 days old and unprocessed, flag to Rithy
- If handoff has no `type` field, treat as `info`
