# HEARTBEAT.md

## Every Heartbeat

### 0. Workspace Sync (REQUIRED)
- `cd ~/workspace/nimmit-workspace && git pull --quiet`
- Check `handoff/` — see HANDOFF.md for processing spec
- Update `status/heartbeat.json` with my timestamp
- Push if changes made

#### Workspace Sync Failure Modes
| Scenario | Action | Escalation |
|----------|--------|------------|
| git pull fails | Retry 3x, 1min apart | Still failing → notify Rithy |
| git pull conflict | `git merge --abort`, notify Rithy | Do NOT proceed until clean |
| koompi_dev offline | Wait 15min, recheck | Still down → notify Rithy |

### 1. Daily Ops Brief (once/day, before 8am)
- Read `projects/README.md` + `tasks/TASKS.md`
- Post 3-line brief: shipped | blocked | due today
- Nothing changed → post HEARTBEAT_OK (silence could mean heartbeat failed)

### 2. Role Health Check (every 6h)
- Check: Are all roles responding? Is routing working? Any role idle >24h?
- If `memory/procedural/role-health-check.md` exists, follow it. Otherwise use checklist above.

### 3. Group Scan
- Review last 2h across channels. Answer unanswered. Flag Rithy items.

### 4. Scheduled Tasks
- **Daily 09:00:** Intel Brief → `koompi/nimmit-intel-briefs` (Signal → Landscape → Intel → Actions)
- **Mon 10:00:** Competitive intel → `memory/episodic/competitive-intel-YYYY-MM-DD.md`
- **Mon 10:30:** StadiumX Sport & Entertainment Intel → post to #stadiumx, tag @vuthysan. Save to `memory/episodic/stadiumx-intel-YYYY-MM-DD.md`
- **Tue-Sat 09:30:** Metric check. Surface one insight.
- **Sun 10:00:** Evolution scorecard
- **Sun 11:00:** Weekly failure review. Same failure type 3x in 7 days = pattern → add to anti-patterns in SOUL.md or adjust routing in AGENTS.md.
- **1st of month 10:00:** Monthly outcome review.

### 5. NOW.md + Commitments
- NOW.md >24h old → update. Overdue → act or escalate.

### 6. Token Efficiency
- Skip files already in context. Skip re-checks koompi_dev did.
- Target: <50k tokens per task. Track in daily log. >100k = flag for review.
- Flag waste patterns to `memory/failures/token-waste.md`

## Scheduled Task Failure Modes
| Scenario | Action |
|----------|--------|
| Service down | Log to memory/failures/, retry next scheduled run |
| No new data | Log skip with reason to memory/failures/scheduled-task-skip-YYYY-MM-DD.md |
| Already done manually | Log skip, no retry |

## Rules
- Nothing needs attention → `HEARTBEAT_OK`
- Late night (23:00-08:00): skip except urgent
- Every scheduled task MUST produce visible output. No evidence = didn't run.

## Urgent Escalation Path
1. DM Rithy with "[URGENT]" prefix
2. No response in 1h → DM Sila (@chysila)
3. No response in 2h → DM Vuthy (@vuthysan)
4. Document in memory/episodic/urgent-escalation-YYYY-MM-DD.md
