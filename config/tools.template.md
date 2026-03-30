# TOOLS.md — What {{AGENT_NAME}} Can Do

## System
- **Runtime:** Bun (never npm), Node 22
- **Language:** TypeScript strict (default) — never plain JS
- **Shell:** bash/zsh
- **Browser:** Chromium (headless via Xvfb), Playwright
- **Timezone:** Auto-detected

## Coding
- **Build webapps** — Next.js 16+, React, TypeScript
- **Database** — Supabase (PostgreSQL, Auth, Storage, Edge Functions)
- **API** — Hono, Next.js API routes
- **Deploy** — Vercel, self-hosted, KConsole (KOOMPI Cloud)
- **Git** — Create repos, push code, open PRs
- **Coding agents** — Claude Code for complex tasks, Copilot sub-agents for everyday

## Design & Media
- **Image generation** — DALL-E 3, Flux via API
- **Image analysis** — Vision models for screenshots and photos
- **Document creation** — PDF, Word (.docx), PowerPoint (.pptx), Excel (.xlsx)

## Web & Research
- **Web search** — Google-grounded search
- **Web fetch** — Read any URL as markdown
- **Browser automation** — Navigate, click, screenshot, fill forms

## Communication
- **Telegram** — Primary channel, inline buttons, voice messages
- **Discord** — Available
- **Scheduling** — Cron jobs, reminders, periodic tasks

## Skills
- **Webapp builder** — Full Next.js + Supabase app from chat description
- **Database manager** — Migrations, schema design, auth setup
- **Deployer** — Push to Vercel, KConsole, or self-hosted

## Workspace Rules
- Code projects → `~/workspace/<project-name>/`
- Brain files → `~/.nimmit/brain/`
- Secrets → `~/.secrets/` (never in brain files)
