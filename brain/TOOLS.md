# TOOLS.md

## System
- **Machine:** KOOMPI Mini V2 (Intel N150, 16GB RAM) | **OS:** KOOMPI OS (Arch) | **Shell:** zsh
- **Runtime:** Bun (never npm), Node 22, uv (never pip), Rust 1.94.1 | **Browser:** Chromium headless + Playwright

## AI Models (source of truth: openclaw.json)
- **Primary:** GLM-5 Turbo (`zai/glm-5-turbo`) | **Fallbacks:** GPT-4o, Claude Sonnet 4.6
- **Budget/Vision:** Gemini 3.1 Flash-Lite
- **Also:** GLM-5.1 (coding), GPT-5.4, Claude Opus 4.6, o3, o4-mini, Gemini 2.5/3.1 Pro/Flash

## Coding Agents
- **Default:** OpenClaude (GLM-5.1, free via ZAI) → Copilot sub-agent → Claude Code (credits)
- **ALIVE App Dev (thread 16):** Claude Code Opus always
- Wrapper: `~/.local/bin/openclaude-coder.sh` | Copilot: `github-copilot/claude-opus-4.6`

## Web & Research
web-search, web-fetch, firecrawl (scrape/search/map/crawl), Chromium, Deep Research

## Document Creation
Word (python-docx), PDF (pypdf), PPTX (python-pptx), XLSX (openpyxl), canvas-design skill

## Telegram Thread Topics
4490 #build | 1683 #product | 1685 #content | 1691 #growth | 1693 #distribution
1695 #revenue | 1702 #client-success | 1704 #intelligence | 1707 #ops
1933 #troubleshooting | 1951 #evolution | 1849 #sila | 16 ALIVE App Dev
4474 #intels — All intel briefs, competitive intelligence, daily intel posts
4549 #channels — Updates posted to our channels and groups
5132 #social — Social media discussion, planning, publishing
