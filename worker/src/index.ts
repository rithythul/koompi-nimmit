const GITHUB_RAW = "https://raw.githubusercontent.com/koompi/koompi-nimmit/main";

export default {
  async fetch(request: Request): Promise<Response> {
    const url = new URL(request.url);
    const path = url.pathname;

    // GET /install → serve install.sh
    if (path === "/install" || path === "/install.sh") {
      const res = await fetch(`${GITHUB_RAW}/install.sh`);
      if (!res.ok) {
        return new Response("Failed to fetch install script", { status: 502 });
      }
      const body = await res.text();
      return new Response(body, {
        headers: {
          "Content-Type": "text/plain; charset=utf-8",
          "Cache-Control": "public, max-age=300",
        },
      });
    }

    // GET /skill-packs/<industry>/SKILL.md
    const skillMatch = path.match(/^\/skill-packs\/([a-z-]+)\/SKILL\.md$/);
    if (skillMatch) {
      const industry = skillMatch[1];
      const res = await fetch(`${GITHUB_RAW}/skill-packs/${industry}/SKILL.md`);
      if (!res.ok) {
        return new Response(`Skill pack '${industry}' not found`, { status: 404 });
      }
      const body = await res.text();
      return new Response(body, {
        headers: {
          "Content-Type": "text/markdown; charset=utf-8",
          "Cache-Control": "public, max-age=300",
        },
      });
    }

    // GET / → landing
    if (path === "/" || path === "") {
      return new Response(
        [
          "# Nimmit",
          "",
          "AI assistant skill packs and OpenClaw plugin by KOOMPI.",
          "",
          "Install an AI worker. Teach it your job. Let it work.",
          "",
          "## Install",
          "",
          "### npm (recommended)",
          "",
          "```bash",
          "npm install -g openclaw nimmit",
          "nimmit onboard",
          "```",
          "",
          "### Quick start",
          "",
          "```bash",
          "curl -fsSL https://nimmit.koompi.ai/install | bash",
          "```",
          "",
          "## Skill Packs",
          "",
          "### Core",
          "- [Memory](/skill-packs/memory/SKILL.md) — structured memory architecture (installed by default)",
          "",
          "### Business & Operations",
          "- [Executive](/skill-packs/executive/SKILL.md) — C-suite, leadership",
          "- [SME](/skill-packs/sme/SKILL.md) — small & medium business",
          "- [Finance](/skill-packs/finance/SKILL.md) — accounting, CFO",
          "- [Creative](/skill-packs/creative/SKILL.md) — agencies, studios",
          "- [Logistics](/skill-packs/logistics/SKILL.md) — supply chain",
          "- [Construction](/skill-packs/construction/SKILL.md) — project management",
          "",
          "### Public Sector & Education",
          "- [Government](/skill-packs/government/SKILL.md) — ministries, departments",
          "- [Education](/skill-packs/education/SKILL.md) — schools, universities",
          "- [Nonprofit](/skill-packs/nonprofit/SKILL.md) — NGOs, foundations",
          "",
          "### Professional Services",
          "- [Healthcare](/skill-packs/healthcare/SKILL.md) — clinics, practices",
          "- [Legal](/skill-packs/legal/SKILL.md) — law firms",
          "- [Real Estate](/skill-packs/real-estate/SKILL.md) — brokerages, agents",
          "- [Agriculture](/skill-packs/agriculture/SKILL.md) — farms, cooperatives",
          "- [Hospitality](/skill-packs/hospitality/SKILL.md) — hotels, resorts",
          "",
          "### Intelligence & Research",
          "- [Geopolitical](/skill-packs/geopolitical/SKILL.md) — risk analysis, OSINT",
          "- [Economist](/skill-packs/economist/SKILL.md) — economic analysis",
          "- [Web Crawler](/skill-packs/web-crawler/SKILL.md) — research, monitoring",
          "",
          "## Commands",
          "",
          "```",
          "nimmit onboard       # Guided setup",
          "nimmit status        # Installation status",
          "nimmit skills list   # Available skill packs",
          "nimmit skills add    # Install skill packs",
          "nimmit update        # Update OpenClaw + skills",
          "```",
          "",
          "## Runtime",
          "",
          "- [OpenClaw](https://github.com/openclaw/openclaw) — AI assistant runtime",
          "- [OpenShell](https://github.com/NVIDIA/OpenShell) — secure sandbox (optional)",
        ].join("\n"),
        {
          headers: {
            "Content-Type": "text/markdown; charset=utf-8",
            "Cache-Control": "public, max-age=300",
          },
        }
      );
    }

    return new Response("Not found", { status: 404 });
  },
} satisfies ExportedHandler;
