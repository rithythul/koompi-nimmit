# MIGRATION-GUIDE.md — Customizing {{AGENT_NAME}} for Your Company

This guide walks you through customizing the {{AGENT_NAME}} brain template for your company.

## Quick Start (5 minutes)

1. **Replace placeholders** in all `brain/*.md` files:
   - `{{AGENT_NAME}}` → your AI team's name
   - `{{COMPANY}}` → your company name
   - `{{OWNER_NAME}}` → founder/CEO name
   - `{{OWNER_TELEGRAM_ID}}` → founder's Telegram ID
   - `{{OWNER_LOCATION}}` → city, country
   - `{{OWNER_TZ}}` → timezone (e.g., `Asia/Phnom_Penh`)
   - `{{OWNER_LANGUAGE}}` → primary language
   - `{{NORTH_STAR}}` → your company's goal
   - `{{COMPANY_MISSION}}` → what you do and why
   - `{{COMPANY_VISION}}` → where you're going
   - `{{COMPANY_VALUES}}` → your principles
   - `{{COMPANY_PRODUCTS}}` → your products/services
   - `{{TECH_STACK}}` → your preferred technologies

2. **Set up `openclaw.json`** — see `config/openclaw.template.json`

3. **Start the gateway** — `openclaw gateway start`

4. **Verify** — send a message to your AI team

## Choosing Your Product Tier

| Tier | Who | Setup |
|------|-----|-------|
| **Nimmit Cloud** | Startups, agencies, SMBs | Sign up at nimmit.koompi.cloud. No install needed. |
| **Nimmit Mini** | Government, schools, offline orgs | KOOMPI Mini pre-loaded. Plug in, configure channels. |
| **Nimmit Enterprise** | Large orgs, ministries | Custom deployment. Contact KOOMP. |

This guide covers **Nimmit Mini / self-hosted** setup. For Cloud, see the web dashboard.

## Adapting Roles for Your Company

**Startup (3 roles):**
Keep Product, Engineering, Growth. Fold Design into Product, DevOps into Engineering, Operations into Growth. Add Strategy and QA when you scale.

**Agency (5 roles):**
Keep Product, Engineering, Design, Growth, Operations. Add QA if quality is client-facing. DevOps can fold into Engineering.

**Enterprise (8+ roles):**
Use all 8 roles. Add specialized roles as needed (Data, Legal, Compliance, Research).

**Solo founder:**
All 8 roles. You are the CEO. The AI team handles everything else.

## Role Model Routing

Default model assignments (change in `openclaw.json`):

| Role | Why this model |
|------|----------------|
| Strategy, Product, Design, DevOps | Deep reasoning needed for decisions |
| Engineering | Code generation optimized |
| Growth, Operations, QA | Speed + breadth over depth |

## What to Customize vs What to Keep

### Keep as-is
- SOUL.md philosophy (7 Rules, Tensions, Anti-Patterns)
- WORKFLOW.md memory architecture
- HEARTBEAT.md scheduled tasks (adjust times to your timezone)
- Mesh structure (don't add hierarchy)

### Customize
- COMPANY.md — your actual business
- USER.md — your profile and preferences
- TOOLS.md — your tech stack and model choices
- Red lines in AGENTS.md — your security constraints
- NOW.md — your current priorities

### Delete if not needed
- Any role you don't use (just remove from AGENTS.md and ROUTING.md)
- Scheduled tasks in HEARTBEAT.md that don't apply

## File Map

| File | Purpose | Customize? |
|------|---------|------------|
| SOUL.md | Personality, communication style | Minimal — add your language preferences |
| IDENTITY.md | Name and role description | Yes — replace placeholders |
| AGENTS.md | Org structure and roles | Yes — remove roles you don't need |
| COMPANY.md | Business context | Yes — your company |
| USER.md | Founder profile | Yes — your info |
| TOOLS.md | Tech stack and model routing | Yes — your tools |
| WORKFLOW.md | Memory and task system | Minimal — adjust tech stack |
| HEARTBEAT.md | Scheduled tasks | Yes — adjust times and tasks |
| BOOTSTRAP.md | First-run setup | No |
| MEMORY.md | Memory index | No |
| ARCHITECTURE.md | Runtime awareness | No |

## Common Mistakes

1. **Don't add hierarchy.** The mesh works. Hierarchy creates bottlenecks.
2. **Don't over-specify.** The AI team adapts. Too many rules = too rigid.
3. **Don't skip COMPANY.md.** The AI team needs to understand your business.
4. **Don't copy the KOOMPI reference.** It's an example, not a template.
5. **Do write things down.** Memory is the AI team's professionalism.
