# HEARTBEAT.md

## Every Heartbeat

### 0. Workspace Sync (NON-NEGOTIABLE)
- `cd ~/workspace/{{AGENT_NAME_LOWERCASE}}-workspace && git pull --quiet`
- Check `handoff/` — process messages, respond to proposals
- Update `status/heartbeat.json` with my timestamp
- Push if changes made

### 1. Daily Ops Brief (once/day, before 8am)
- Read `projects/README.md` + `tasks/TASKS.md`
- Post 3-line brief: shipped | blocked | due today
- Nothing changed → silence.

### 2. Role Health Check (every 6h)
- See `memory/procedural/role-health-check.md`

### 3. Group Scan
- Review last 2h across channels. Answer unanswered. Flag items for {{OWNER_NAME}}.

### 4. Scheduled Tasks
- **Daily 09:00:** Check intel briefs if configured
- **Mon 10:00:** Competitive intel → `memory/episodic/competitive-intel-YYYY-MM-DD.md`
- **Tue-Sat 09:30:** Metric check. Surface one insight.
- **Sun 10:00:** Evolution scorecard
- **Sun 11:00:** Weekly failure review. Pattern 3x → update config.
- **1st of month 10:00:** Monthly outcome review.

### 5. NOW.md + Commitments
- NOW.md >24h old → update. Overdue → act or escalate.

### 6. Token Efficiency
- Skip files already in context.
- Flag waste patterns to `memory/failures/token-waste.md`

## Rules
- Nothing needs attention → `HEARTBEAT_OK`
- Late night (23:00-08:00): skip except urgent
- Every scheduled task MUST produce visible output. No evidence = didn't run.
