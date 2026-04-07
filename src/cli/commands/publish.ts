import type { Command } from "commander";
import { execFile } from "node:child_process";
import { promisify } from "node:util";
import { SKILL_PACKS, bundledSkillPath } from "../../skills.js";

const exec = promisify(execFile);

export function registerPublishCommand(program: Command): void {
  program
    .command("publish")
    .description("Publish skill packs to ClawHub registry")
    .option("--dry-run", "Preview what would be published")
    .option("--bump <strategy>", "Version bump strategy: patch, minor, major")
    .option(
      "--skill <id>",
      "Publish a single skill pack instead of all",
    )
    .action(
      async (opts: {
        dryRun?: boolean;
        bump?: string;
        skill?: string;
      }) => {
        const packs = opts.skill
          ? SKILL_PACKS.filter((p) => p.id === opts.skill)
          : SKILL_PACKS;

        if (packs.length === 0) {
          console.error(`  Unknown skill pack: ${opts.skill}`);
          console.error(
            `  Available: ${SKILL_PACKS.map((s) => s.id).join(", ")}`,
          );
          process.exit(1);
        }

        console.log(
          `  Publishing ${packs.length} skill pack(s) to ClawHub...`,
        );
        if (opts.dryRun) {
          console.log("  (dry run — no changes will be made)\n");
        }

        let published = 0;
        let failed = 0;

        // Check clawhub CLI is available (skip for dry-run)
        if (!opts.dryRun) {
          try {
            await exec("clawhub", ["--version"]);
          } catch {
            console.error(
              "  clawhub CLI not found. Install: npm install -g clawhub",
            );
            process.exit(1);
          }
        }

        for (const pack of packs) {
          const skillDir = bundledSkillPath(pack.id).replace(
            "/SKILL.md",
            "",
          );
          const slug = `koompi/${pack.id}`;
          const args = [
            "skill",
            "publish",
            skillDir,
            "--slug",
            slug,
          ];

          if (opts.bump) {
            args.push("--bump", opts.bump);
          }

          if (opts.dryRun) {
            console.log(`  [dry-run] ${slug}`);
            published++;
            continue;
          }

          try {
            const { stdout } = await exec("clawhub", args);
            if (stdout.trim()) console.log(`  ${stdout.trim()}`);
            console.log(`  Published: ${slug}`);
            published++;
          } catch (e) {
            const msg =
              e instanceof Error ? e.message : String(e);
            console.error(`  Failed: ${slug} — ${msg}`);
            failed++;
          }
        }

        console.log("");
        console.log(
          `  ${published} published, ${failed} failed.`,
        );

        if (!opts.dryRun && published > 0) {
          console.log(
            "  Skills are now available at https://clawhub.ai",
          );
        }
      },
    );
}
