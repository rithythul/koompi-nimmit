# Changelog

All notable changes to nimmit-brain will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Multi-agent coordination protocol (shared workspace, handoff system, proposal system)
- Token optimization: git-log-first pattern, heartbeat deduplication, delta reads
- Shared heartbeat.json for agent status awareness
- STANDARDS.md — quality and process standards
- Brain export roadmap for productization

### Changed
- Repo renamed from `koompi-nimmit` to `nimmit-brain`
- README rewritten with multi-agent docs, memory architecture, evolution section
- Updated all repo references from koompi/koompi-nimmit to koompi/nimmit-brain

### Previous (3.2.0)
- Quick Start section to README
- Troubleshooting section with common issues and solutions
- `.env.example` file for configuration reference
- `CONTRIBUTING.md` with contribution guidelines
- `SECURITY.md` with security policy and vulnerability reporting
- `CODE_OF_CONDUCT.md` with community guidelines
- GitHub issue templates (bug report, feature request)
- GitHub workflow for shellcheck and markdown linting
- Uninstall function in install.sh
- Docker Compose configuration for local testing
- Interactive installation wizard
- Non-interactive mode for CI/automation
- Auto-update timer (every 6 hours)
- Watchdog health check (every 5 minutes)
- Support for multiple AI model providers
- Division mode (4 departments: build, product, growth, ops)
- KOOMPI Mini autologin support
- Migrated to OpenClaw v3.x

## [3.2.0] - 2025-04-XX

### Added
- Interactive installation wizard
- Non-interactive mode for CI/automation
- Auto-update timer (every 6 hours)
- Watchdog health check (every 5 minutes)
- Support for multiple AI model providers
- Division mode (4 departments: build, product, growth, ops)
- KOOMPI Mini autologin support

### Changed
- Migrated to OpenClaw v3.x
- Improved service reliability with systemd

## [3.1.0] - 2025-03-XX

### Added
- Telegram bot integration
- Google Gemini model support
- GitHub Copilot integration
- ZAI/GLM model support

### Fixed
- Installation on Arch-based systems
- Node.js 22 compatibility

## [3.0.0] - 2025-02-XX

### Added
- Initial public release
- One-command installation
- AI agent brain template
- Supabase integration
- Next.js app generation

[Unreleased]: https://github.com/koompi/nimmit-brain/compare/v3.2.0...HEAD
[3.2.0]: https://github.com/koompi/nimmit-brain/compare/v3.1.0...v3.2.0
[3.1.0]: https://github.com/koompi/nimmit-brain/compare/v3.0.0...v3.1.0
[3.0.0]: https://github.com/koompi/nimmit-brain/releases/tag/v3.0.0
