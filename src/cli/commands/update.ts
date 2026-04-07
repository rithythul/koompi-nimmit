import type { Command } from "commander";
import { execFile } from "node:child_process";
import { promisify } from "node:util";
import { loadConfig, saveConfig } from "../../config.js";
import { installSkillPack, findSkillPack } from "../../skills.js";
import { VERSION } from "../../types.js";

const exec = promisify(execFile);

export function registerUpdateCommand(program: Command): void {
  program
    .command("update")
    .description("Update OpenClaw runtime and refresh skill packs")
    .option("--channel <channel>", "Update channel: stable, beta, dev", "stable")
    .option("--skills-only", "Only refresh skill packs, skip OpenClaw update")
    .action(
      async (opts: { channel: string; skillsOnly?: boolean }) => {
        const config = await loadConfig();
        if (!config) {
          console.error("Not onboarded. Run: nimmit onboard");
          process.exit(1);
        }

        // Update OpenClaw
        if (!opts.skillsOnly) {
          console.log(`  Updating OpenClaw (channel: ${opts.channel})...`);
          try {
            const { stdout } = await exec("openclaw", [
              "update",
              "--channel",
              opts.channel,
            ]);
            if (stdout.trim()) console.log(`  ${stdout.trim()}`);
            console.log("  OpenClaw updated.");
          } catch (e) {
            console.error("  Failed to update OpenClaw. Try manually: openclaw update");
          }
        }

        // Refresh installed skill packs
        console.log("  Refreshing skill packs...");
        let refreshed = 0;
        for (const id of config.skills) {
          const meta = findSkillPack(id);
          if (!meta) continue;
          try {
            await installSkillPack(meta.id, config.workspace);
            refreshed++;
          } catch {
            console.error(`  Failed to refresh: ${meta.name}`);
          }
        }
        console.log(`  ${refreshed} skill pack(s) refreshed.`);

        // Update nimmit version in config
        config.version = VERSION;
        await saveConfig(config);

        console.log("  Done.");
      },
    );
}
