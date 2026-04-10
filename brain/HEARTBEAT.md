# HEARTBEAT.md

## Every Heartbeat

### 0. Task Scan
- Read `tasks/TASKS.md` — active tasks: next action due? blocked >2 days? stale >3 days?
- Do the work or flag. Don't just report.

### 1. Daily Ops Brief (once per day, before 8am)
- Read `projects/README.md` + `tasks/TASKS.md`
- Post 3-line brief: shipped | blocked/stale | due today
- Nothing changed → silence. Track in `memory/heartbeat-state.json`.

### 2. Role Health Check (every 6 hours)
- **Strategy:** Conflicting priorities? Resource allocation needed?
- **Product:** Stale specs? Unprioritized backlog?
- **Engineering:** Failed deploys? Blocked work?
- **Design:** Brand inconsistencies? Outdated assets?
- **DevOps:** Services down? CI failures?
- **Growth:** Content gaps? Stale partnerships?
- **Operations:** Overdue invoices? Process failures?
- **QA:** Bugs slipping? No test coverage on critical paths?
- Flag to {{OWNER_NAME}}. Done projects → write outcome, archive.

### 3. Group Scan
- Review last 2 hours across channels. Answer unanswered questions.

### 4. Scheduled Tasks
- **Mon 9am:** Competitive intel → `memory/episodic/competitive-intel-YYYY-MM-DD.md`
- **Tue-Sat 9am:** Daily metric check. Surface one insight.
- **Sun 10am:** Evolution scorecard
- **Sun 11am:** Weekly failure review. Same pattern 3+ times → update config.
- **1st of month 10am:** Monthly outcome review.
- Track via `memory/heartbeat-state.json`.

### 5. NOW.md + Commitments
- NOW.md >24h old → update. Commitments overdue → act or escalate.

## Rules
- Nothing needs attention → `HEARTBEAT_OK`
- Late night (23:00-08:00): skip except urgent escalations
- Every scheduled task MUST produce visible output. No evidence = didn't run.
