# Agent Routing — Mesh Structure

**Match task → role in under 5 seconds.**

## By Role

### Strategy
| Task | Model |
|------|-------|
| Resource allocation, prioritization | opus |
| Cross-product coordination | opus |
| Competitive analysis, market research | fast |

### Product
| Task | Model |
|------|-------|
| Roadmap, specs, feature prioritization | opus |
| User research, competitor analysis | fast |
| Analytics, dashboards, metrics | fast |

### Engineering
| Task | Model |
|------|-------|
| Architecture, system design | opus |
| Backend, API, database | codex |
| Frontend, UI, components | codex |
| Security, auth | opus |

### Design
| Task | Model |
|------|-------|
| Brand identity, visual guidelines | opus |
| UX, wireframes, prototypes | opus |
| Marketing assets, social graphics | opus |
| Content design, copy | fast |

### DevOps
| Task | Model |
|------|-------|
| CI/CD, deployments | opus |
| Infrastructure, monitoring | opus |
| Docker, server config | codex |

### Growth
| Task | Model |
|------|-------|
| Content, blog, social | fast |
| SEO, paid ads, campaigns | fast |
| Partnerships, bizdev | opus |
| Client acquisition, sales | opus |

### Operations
| Task | Model |
|------|-------|
| Finance, budgets, invoicing | fast |
| Process, HR, admin | fast |
| Contracts, legal, compliance | opus |

### QA
| Task | Model |
|------|-------|
| Testing, code review | fast |
| Bug verification, regression | fast |
| Quality gates, acceptance criteria | fast |

## Escalation
- Sub-agent fails 2x → escalate model
- Multi-role task → collaborate directly (mesh)
- Needs {{OWNER_NAME}} → never spawn, ask first

## Model Legend
- **opus** = deep reasoning (Claude Opus or equivalent)
- **codex** = code generation (GPT-5.3-codex or equivalent)
- **fast** = speed + breadth (GPT-5.4 or equivalent)
