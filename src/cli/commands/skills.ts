import type { Command } from "commander";
import { loadConfig, saveConfig } from "../../config.js";
import {
  listBundledSkills,
  listInstalledSkills,
  installSkillPack,
  removeSkillPack,
  findSkillPack,
  groupByCategory,
  categoryLabel,
} from "../../skills.js";
import type { SkillPackId } from "../../types.js";

export function registerSkillsCommand(program: Command): void {
  const skills = program
    .command("skills")
    .description("Manage Nimmit skill packs");

  skills
    .command("list")
    .description("List all available skill packs")
    .action(async () => {
      const config = await loadConfig();
      const installed = config
        ? await listInstalledSkills(config.workspace)
        : [];
      const installedSet = new Set(installed);
      const grouped = groupByCategory(listBundledSkills());

      console.log("");
      for (const [category, packs] of grouped) {
        const maxLen = Math.max(...packs.map((p) => p.name.length));
        console.log(`  ${categoryLabel(category)}`);
        for (const pack of packs) {
          const marker = installedSet.has(pack.id) ? " [installed]" : "";
          console.log(`    ${pack.name.padEnd(maxLen + 2)} ${pack.description}${marker}`);
        }
        console.log("");
      }
    });

  skills
    .command("add")
    .description("Install skill packs")
    .argument("<names...>", "Skill pack names (or 'all')")
    .action(async (names: string[]) => {
      const config = await loadConfig();
      if (!config) {
        console.error("Not onboarded. Run: nimmit onboard");
        process.exit(1);
      }

      const toInstall: SkillPackId[] = [];

      if (names.includes("all")) {
        toInstall.push(...listBundledSkills().map((s) => s.id));
      } else {
        for (const name of names) {
          const meta = findSkillPack(name);
          if (!meta) {
            console.error(`Unknown skill pack: ${name}`);
            console.error(
              `Available: ${listBundledSkills().map((s) => s.id).join(", ")}`,
            );
            process.exit(1);
          }
          toInstall.push(meta.id);
        }
      }

      if (toInstall.length > 5) {
        console.log(
          `Installing ${toInstall.length} packs — this increases token costs per API call.`,
        );
      }

      for (const id of toInstall) {
        await installSkillPack(id, config.workspace);
        const meta = findSkillPack(id);
        console.log(`  Installed: ${meta?.name ?? id}`);
      }

      // Update config
      const existing = new Set(config.skills);
      for (const id of toInstall) existing.add(id);
      config.skills = [...existing];
      await saveConfig(config);
    });

  skills
    .command("remove")
    .description("Remove skill packs")
    .argument("<names...>", "Skill pack names")
    .action(async (names: string[]) => {
      const config = await loadConfig();
      if (!config) {
        console.error("Not onboarded. Run: nimmit onboard");
        process.exit(1);
      }

      for (const name of names) {
        const meta = findSkillPack(name);
        if (!meta) {
          console.error(`Unknown skill pack: ${name}`);
          process.exit(1);
        }
        await removeSkillPack(meta.id, config.workspace);
        console.log(`  Removed: ${meta.name}`);
      }

      config.skills = config.skills.filter(
        (s) => !names.includes(s),
      );
      await saveConfig(config);
    });
}
