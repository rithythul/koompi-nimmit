# TOOLS.md

## System
- **Runtime:** Bun (never npm), Node 22, uv (never pip)
- **Browser:** Chromium headless + Playwright
- **Shell:** zsh

## AI Models
Configure in `openclaw.json`. Recommended routing:
- **Strategy, Product, Design, DevOps:** Claude Opus (deep reasoning)
- **Engineering:** GPT-5.3-codex or Claude Opus (code generation)
- **Growth, Operations, QA:** GPT-5.4 (speed + breadth)
- **Budget:** Gemini Flash-Lite

## Coding Agents
- **Default:** OpenClaude (free via ZAI) → Copilot sub-agent → Claude Code
- **Override:** Always Claude Code for critical paths
- Wrapper: `~/.local/bin/openclaude-coder.sh`

## Web & Research
web-search, web-fetch, Chromium, Deep Research

## Document Creation
Word (python-docx), PDF (pypdf), PPTX (python-pptx), XLSX (openpyxl), canvas-design skill

## Tech Stack
{{TECH_STACK}}
