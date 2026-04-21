# CHANGELOG

## 2.1.0 — 2026-04-12

### New: Self-Evolution System
- **EVOLUTION.md** — Full self-improvement system baked into the brain
  - Auto-learn from corrections, work, observations
  - Weekly lesson extraction (generalized, no personal data)
  - Push lessons to the brain repo
  - Pull others' lessons and integrate
  - Privacy contract: only generic lessons shared, never personal data
- **WORKFLOW.md** — Evolution triggers integrated into daily workflow
  - First-session auto-setup: creates cron jobs, clones brain repo
  - Learning from corrections → procedural memory
  - Learning from failures → anti-patterns
  - Sunday random hour: push + pull cycle

### New: Brain Lesson API
- Lesson aggregation API for crowd-sourced improvements
  - Privacy enforcement: blocks emails, phones, IPs, tokens, names
  - Auto-creates PRs to the brain repo

### New: Community Contribution Pipeline
- **CONTRIBUTING.md** — Privacy-first contribution guide
- **.github/PULL_REQUEST_TEMPLATE.md** — Structured PR format
- **scripts/review-prs.sh** — Automated PR review checklist
- **brain/VERSION** — Semver versioning for brain iterations

### Updated
- **README.md** — "Self-evolving" as core product feature
- **WORKFLOW.md** — First-session setup includes evolution cron jobs
- All brain files templatized for client use

---

## 2.0.0 — 2026-04-12

### Initial brain template v2
- Core brain files: SOUL, IDENTITY, AGENTS, USER, TOOLS, MEMORY
- Memory architecture: daily, semantic, procedural, decisions, failures, episodic, outcomes, research, working
- Caveman communication protocol
- Mesh structure: 8 functional roles
- OpenClaw runtime integration
