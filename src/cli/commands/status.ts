import type { Command } from "commander";
import { loadConfig, openclawVersion } from "../../config.js";
import {
  listInstalledSkills,
  findSkillPack,
  categoryLabel,
} from "../../skills.js";

export function registerStatusCommand(program: Command): void {
  program
    .command("status")
    .description("Show Nimmit installation status")
    .action(async () => {
      const config = await loadConfig();

      if (!config) {
        console.log("Nimmit is not onboarded yet.");
        console.log("Run: nimmit onboard");
        return;
      }

      const clawVersion = await openclawVersion();

      console.log("");
      console.log("  Nimmit Status");
      console.log("  ─────────────────────────────");
      console.log(`  Agent:       ${config.agent}`);
      console.log(`  Mode:        ${config.deploymentMode}`);
      console.log(`  Workspace:   ${config.workspace}`);
      console.log(
        `  OpenClaw:    ${clawVersion ?? "not found"}`,
      );
      console.log(
        `  Provider:    ${config.provider.type}${config.provider.model ? ` (${config.provider.model})` : ""}`,
      );

      // Channels
      const activeChannels = Object.entries(config.channels)
        .filter(([, v]) => v?.enabled)
        .map(([k]) => k);
      console.log(
        `  Channels:    ${activeChannels.length > 0 ? activeChannels.join(", ") : "none"}`,
      );

      // Org
      if (config.org?.name) {
        console.log(`  Org:         ${config.org.name}`);
      }
      if (config.language) {
        console.log(`  Language:    ${config.language}`);
      }
      if (config.timezone) {
        console.log(`  Timezone:    ${config.timezone}`);
      }

      // Skills
      const installed = await listInstalledSkills(config.workspace);
      if (installed.length > 0) {
        console.log("");
        console.log("  Installed Skills");
        console.log("  ─────────────────────────────");
        for (const id of installed) {
          const meta = findSkillPack(id);
          const cat = meta ? categoryLabel(meta.category) : "";
          console.log(`  ${meta?.name ?? id}  (${cat})`);
        }
      }

      console.log(
        `\n  Onboarded:   ${config.onboardedAt}`,
      );
      console.log("");
    });
}
