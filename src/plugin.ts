// OpenClaw plugin entry point.
// This file is loaded by OpenClaw when nimmit is installed as a plugin.
// It registers /nimmit slash commands inside chat sessions.
//
// The openclaw peer dependency provides the plugin SDK types.
// We use dynamic import to avoid hard build-time dependency.

import {
  listBundledSkills,
  listInstalledSkills,
  installSkillPack,
  findSkillPack,
  groupByCategory,
  categoryLabel,
} from "./skills.js";
import { loadConfig } from "./config.js";

interface PluginCommandContext {
  args: string;
  sessionId?: string;
}

interface PluginCommandResult {
  text: string;
}

interface PluginCommandDefinition {
  name: string;
  description: string;
  acceptsArgs?: boolean;
  handler: (ctx: PluginCommandContext) => Promise<PluginCommandResult>;
}

interface OpenClawPluginApi {
  registerCommand(definition: PluginCommandDefinition): void;
  logger?: { info: (msg: string) => void };
}

interface PluginEntry {
  id: string;
  name: string;
  description: string;
  register: (api: OpenClawPluginApi) => void;
}

// Export the plugin entry
const plugin: PluginEntry = {
  id: "nimmit",
  name: "Nimmit",
  description: "AI assistant skill packs and workspace management",

  register(api: OpenClawPluginApi) {
    api.registerCommand({
      name: "nimmit",
      description: "Nimmit skill packs and configuration — /nimmit status | skills | update",
      acceptsArgs: true,
      handler: async (ctx: PluginCommandContext): Promise<PluginCommandResult> => {
        const args = ctx.args.trim().split(/\s+/);
        const subcmd = args[0] || "help";

        switch (subcmd) {
          case "status":
            return handleStatus();
          case "skills":
            return handleSkills();
          case "update":
            return handleUpdate();
          default:
            return {
              text: [
                "**Nimmit** — AI assistant skill packs",
                "",
                "Commands:",
                "  `/nimmit status` — Show installed skills and config",
                "  `/nimmit skills` — List available skill packs",
                "  `/nimmit update` — Refresh installed skill packs",
              ].join("\n"),
            };
        }
      },
    });

    api.logger?.info("Nimmit plugin loaded");
  },
};

async function handleStatus(): Promise<PluginCommandResult> {
  const config = await loadConfig();
  if (!config) {
    return { text: "Nimmit is not onboarded. Run `nimmit onboard` in your terminal." };
  }

  const installed = await listInstalledSkills(config.workspace);
  const lines = [
    "**Nimmit Status**",
    "",
    `Agent: ${config.agent}`,
    `Mode: ${config.deploymentMode}`,
    `Provider: ${config.provider.type}${config.provider.model ? ` (${config.provider.model})` : ""}`,
    `Skills: ${installed.length} installed`,
  ];

  if (config.org?.name) lines.push(`Org: ${config.org.name}`);

  const activeChannels = Object.entries(config.channels)
    .filter(([, v]) => v?.enabled)
    .map(([k]) => k);
  if (activeChannels.length > 0) {
    lines.push(`Channels: ${activeChannels.join(", ")}`);
  }

  return { text: lines.join("\n") };
}

async function handleSkills(): Promise<PluginCommandResult> {
  const config = await loadConfig();
  const installed = config
    ? new Set(await listInstalledSkills(config.workspace))
    : new Set<string>();

  const grouped = groupByCategory(listBundledSkills());
  const lines = ["**Available Skill Packs**", ""];

  for (const [category, packs] of grouped) {
    lines.push(`**${categoryLabel(category)}**`);
    for (const pack of packs) {
      const marker = installed.has(pack.id) ? " ✓" : "";
      lines.push(`  ${pack.name}${marker} — ${pack.description}`);
    }
    lines.push("");
  }

  lines.push("Use `nimmit skills add <name>` in terminal to install.");

  return { text: lines.join("\n") };
}

async function handleUpdate(): Promise<PluginCommandResult> {
  const config = await loadConfig();
  if (!config) {
    return { text: "Nimmit is not onboarded. Run `nimmit onboard` in your terminal." };
  }

  let refreshed = 0;
  const failed: string[] = [];
  for (const id of config.skills) {
    const meta = findSkillPack(id);
    if (!meta) continue;
    try {
      await installSkillPack(meta.id, config.workspace);
      refreshed++;
    } catch {
      failed.push(meta.name);
    }
  }

  let text = `Refreshed ${refreshed} skill pack(s).`;
  if (failed.length > 0) {
    text += `\nFailed to refresh: ${failed.join(", ")}`;
  }
  text += " Run `nimmit update` in terminal for full update (including OpenClaw).";

  return { text };
}

export default plugin;
