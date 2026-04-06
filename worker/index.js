const SCRIPT_URL =
  "https://raw.githubusercontent.com/koompi/koompi-nimmit/master/install.sh";

export default {
  async fetch(request) {
    const url = new URL(request.url);

    // GET / or /install → serve install.sh
    if (url.pathname === "/" || url.pathname === "/install") {
      const res = await fetch(SCRIPT_URL, {
        headers: { "User-Agent": "nimmit-koompi-ai" },
      });
      return new Response(res.body, {
        headers: {
          "content-type": "text/plain; charset=utf-8",
          "cache-control": "public, max-age=300",
        },
      });
    }

    // GET /version → quick version check
    if (url.pathname === "/version") {
      const res = await fetch(SCRIPT_URL, {
        headers: { "User-Agent": "nimmit-koompi-ai" },
      });
      const text = await res.text();
      const match = text.match(/VERSION="([^"]+)"/);
      return new Response((match ? match[1] : "unknown") + "\n");
    }

    // Anything else → usage hint
    return new Response(
      [
        "KOOMPI Nimmit — AI Agent Installer",
        "",
        "Install:",
        "  curl -fsSL https://nimmit.koompi.ai | bash",
        "",
        "Version:",
        "  curl https://nimmit.koompi.ai/version",
        "",
        "Docs: https://github.com/koompi/koompi-nimmit",
        "",
      ].join("\n"),
      { status: 404, headers: { "content-type": "text/plain" } },
    );
  },
};
