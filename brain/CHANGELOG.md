# CHANGELOG

## 2.1.0 — 2026-04-12

### New: Self-Evolution System
- **EVOLUTION.md** — Full self-improvement system baked into the brain
  - Auto-learn from corrections, work, observations
  - Weekly lesson extraction (generalized, no personal data)
  - Push lessons to `nimmit.koompi.ai/api/v1/brain/lessons`
  - Pull others' lessons and integrate
  - Privacy contract: only generic lessons shared, never personal data
- **WORKFLOW.md** — Evolution triggers integrated into daily workflow
  - First-session auto-setup: creates cron jobs, clones nimmit-brain
  - Learning from corrections → procedural memory
  - Learning from failures → anti-patterns
  - Sunday random hour: push + pull cycle

### New: Brain Lesson API
- **nimmit.koompi.ai** — Crowd-sourced lesson aggregation API
  - `POST /api/v1/brain/lessons` — submit lessons (no GitHub needed)
  - `GET /api/v1/brain/lessons` — fetch community lessons
  - Privacy enforcement: blocks emails, phones, IPs, tokens, names
  - Auto-creates PRs to `koompi/nimmit-brain`
  - Source: `koompi/nimmit-brain-api`

### New: Community Contribution Pipeline
- **CONTRIBUTING.md** — Privacy-first contribution guide
  - Privacy promise: your chats stay private, only lessons shared
  - Simple version: just use Nimmit, system handles the rest
  - Technical version: fork + PR for developers
  - Review criteria: what's accepted, what's rejected
- **.github/PULL_REQUEST_TEMPLATE.md** — Structured PR format
- **scripts/review-prs.sh** — Automated PR review checklist
- **brain/VERSION** — Semver versioning for brain iterations

### Updated
- **README.md** — "Self-evolving" as core product feature
- **WORKFLOW.md** — First-session setup includes evolution cron jobs
- All brain files synced to latest KOOMPI Nimmit instance

### How It Works
1. User installs brain → works with their Nimmit
2. Nimmit learns from corrections, work, observations
3. Sunday: extracts lessons, strips personal data, POSTs to API
4. API validates → creates PR → KOOMPI Nimmit reviews
5. Merged lessons flow back to all Nimmit instances
6. Everyone gets smarter. Repeat weekly.

---

## 2.0.0 — 2026-04-12

### Initial brain template v2
- Core brain files: SOUL, IDENTITY, AGENTS, USER, TOOLS, MEMORY
- Memory architecture: daily, semantic, procedural, decisions, failures, episodic, outcomes, research, working
- Caveman communication protocol
- Mesh structure: 8 functional roles
- OpenClaw runtime integration
