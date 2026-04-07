import type { Command } from "commander";
import { execFile } from "node:child_process";
import { promisify } from "node:util";
import { mkdir, readFile } from "node:fs/promises";
import { join, dirname } from "node:path";
import { homedir } from "node:os";
import { input, select, checkbox, confirm, password } from "@inquirer/prompts";
import {
  loadConfig,
  saveConfig,
  atomicWriteFile,
  openclawInstalled,
  openshellInstalled,
  resolveWorkspace,
  runOpenclaw,
} from "../../config.js";
import {
  listBundledSkills,
  installSkillPack,
  groupByCategory,
  categoryLabel,
} from "../../skills.js";
import { installTemplates } from "../../templates.js";
import type {
  NimmitConfig,
  ProviderType,
  DeploymentMode,
  SkillPackId,
  WorkspaceVars,
} from "../../types.js";
import { VERSION } from "../../types.js";

const exec = promisify(execFile);

export function registerOnboardCommand(program: Command): void {
  program
    .command("onboard")
    .description("Set up Nimmit — guided configuration for OpenClaw")
    .option("--lite", "Skip OpenShell, install OpenClaw directly")
    .option("--non-interactive", "Use defaults, no prompts")
    .action(async (opts: { lite?: boolean; nonInteractive?: boolean }) => {
      try {
        await runOnboard(opts);
      } catch (e) {
        if ((e as { name?: string }).name === "ExitPromptError") {
          console.log("\n  Onboarding cancelled.");
          process.exit(130);
        }
        throw e;
      }
    });
}

async function runOnboard(opts: {
  lite?: boolean;
  nonInteractive?: boolean;
}): Promise<void> {
  console.log("");
  console.log("  Welcome to Nimmit");
  console.log("  ─────────────────────────────");
  console.log("  Install an AI worker. Teach it your job. Let it work.");
  console.log("");

  // Check existing config
  const existing = await loadConfig();
  if (existing) {
    const proceed = opts.nonInteractive
      ? true
      : await confirm({
          message:
            "Nimmit is already onboarded. Re-run onboarding? (existing config will be updated)",
          default: false,
        });
    if (!proceed) {
      console.log("Onboarding cancelled.");
      return;
    }
  }

  // 1. Check Node.js version (requires 22.16+)
  const [major, minor] = process.version
    .replace("v", "")
    .split(".")
    .map(Number);
  if (major < 22 || (major === 22 && minor < 16)) {
    console.error(
      `Node.js ${process.version} detected. Nimmit requires Node.js 22.16+.`,
    );
    console.error("Install: https://nodejs.org/");
    process.exit(1);
  }

  // 2. Check/install OpenClaw
  const hasOpenclaw = await openclawInstalled();
  if (!hasOpenclaw) {
    console.log("  OpenClaw is not installed.");
    const installIt = opts.nonInteractive
      ? true
      : await confirm({
          message: "Install OpenClaw now? (npm install -g openclaw)",
          default: true,
        });
    if (installIt) {
      console.log("  Installing OpenClaw...");
      try {
        await exec("npm", ["install", "-g", "openclaw"]);
        console.log("  OpenClaw installed.");
      } catch {
        console.error(
          "  Failed to install OpenClaw. Try manually: npm install -g openclaw",
        );
        process.exit(1);
      }
    } else {
      console.error(
        "OpenClaw is required. Install it and re-run: nimmit onboard",
      );
      process.exit(1);
    }
  }

  // 3. Deployment mode
  let deploymentMode: DeploymentMode;
  if (opts.lite) {
    deploymentMode = "lite";
  } else if (opts.nonInteractive) {
    deploymentMode = "lite";
  } else {
    deploymentMode = await select({
      message: "Deployment mode:",
      choices: [
        {
          name: "Lite — OpenClaw directly (simple, lightweight)",
          value: "lite" as DeploymentMode,
        },
        {
          name: "Full — OpenShell sandbox (secure, Docker-based)",
          value: "full" as DeploymentMode,
        },
      ],
    });
  }

  // Full mode: check OpenShell
  if (deploymentMode === "full") {
    const hasOpenshell = await openshellInstalled();
    if (!hasOpenshell) {
      console.log("  OpenShell is not installed.");
      console.log(
        "  Install: curl -LsSf https://raw.githubusercontent.com/NVIDIA/OpenShell/main/install.sh | sh",
      );
      const fallback = await confirm({
        message: "Continue in Lite mode instead?",
        default: true,
      });
      if (fallback) {
        deploymentMode = "lite";
      } else {
        console.log("Install OpenShell and re-run: nimmit onboard");
        process.exit(1);
      }
    }
  }

  // 4. Register agent
  const agentName = "nimmit";
  console.log(`  Registering agent '${agentName}'...`);
  try {
    await runOpenclaw([
      "agents",
      "add",
      "--name",
      agentName,
      "--non-interactive",
    ]);
  } catch {
    // Agent may already exist
  }

  const workspace = await resolveWorkspace(agentName);
  await mkdir(join(workspace, "skills"), { recursive: true });
  console.log(`  Workspace: ${workspace}`);

  // 5. Model provider
  const providerType: ProviderType = opts.nonInteractive
    ? "anthropic"
    : await select({
        message: "AI model provider:",
        choices: [
          { name: "Anthropic (Claude)", value: "anthropic" as ProviderType },
          { name: "OpenAI (GPT)", value: "openai" as ProviderType },
          { name: "Google (Gemini)", value: "google" as ProviderType },
          { name: "Ollama (local models)", value: "ollama" as ProviderType },
          { name: "OpenRouter", value: "openrouter" as ProviderType },
          { name: "Custom endpoint", value: "custom" as ProviderType },
        ],
      });

  const providerEnvKeys: Record<ProviderType, string> = {
    anthropic: "ANTHROPIC_API_KEY",
    openai: "OPENAI_API_KEY",
    google: "GOOGLE_API_KEY",
    ollama: "",
    openrouter: "OPENROUTER_API_KEY",
    custom: "CUSTOM_API_KEY",
  };

  const defaultModels: Record<ProviderType, string> = {
    anthropic: "anthropic/claude-sonnet-4-20250514",
    openai: "openai/gpt-4o",
    google: "google/gemini-2.5-pro",
    ollama: "ollama/llama3",
    openrouter: "openrouter/auto",
    custom: "",
  };

  // Accumulate all env vars, write once at the end (H1: avoid race condition)
  const pendingEnv: Record<string, string> = {};

  let apiKey = "";
  const envKey = providerEnvKeys[providerType];
  if (envKey && !opts.nonInteractive) {
    apiKey = await password({
      message: `${envKey}:`,
      mask: "*",
    });
  }

  const model = opts.nonInteractive
    ? defaultModels[providerType]
    : await input({
        message: "Model (leave blank for default):",
        default: defaultModels[providerType],
      });

  // Collect API key for batch write
  if (apiKey && envKey) {
    pendingEnv[envKey] = apiKey;
  }

  // Set model in OpenClaw config
  if (model) {
    try {
      await runOpenclaw(["config", "set", "agent.model", model]);
    } catch {
      // Config command may not exist in all versions
    }
  }

  // 6. Channels
  const channels: NimmitConfig["channels"] = {};

  if (!opts.nonInteractive) {
    // Telegram
    const setupTelegram = await confirm({
      message: "Set up Telegram channel?",
      default: false,
    });
    if (setupTelegram) {
      const token = await password({
        message: "Telegram bot token:",
        mask: "*",
      });
      if (token) {
        pendingEnv["TELEGRAM_BOT_TOKEN"] = token;
        try {
          await runOpenclaw([
            "config",
            "set",
            "channels.telegram.enabled",
            "true",
          ]);
        } catch {
          // Ignore if command not supported
        }
        channels.telegram = { enabled: true };
      }
    }

    // Discord
    const setupDiscord = await confirm({
      message: "Set up Discord channel?",
      default: false,
    });
    if (setupDiscord) {
      const token = await password({
        message: "Discord bot token:",
        mask: "*",
      });
      if (token) {
        pendingEnv["DISCORD_BOT_TOKEN"] = token;
        try {
          await runOpenclaw([
            "config",
            "set",
            "channels.discord.enabled",
            "true",
          ]);
        } catch {
          // Ignore if command not supported
        }
        channels.discord = { enabled: true };
      }
    }
  }

  // Write all env vars at once (C1: escaped, C2: atomic, H1: single write)
  if (Object.keys(pendingEnv).length > 0) {
    const envFile = join(homedir(), ".openclaw", ".env");
    const envContent = await readEnvFile(envFile);
    Object.assign(envContent, pendingEnv);
    await writeEnvFile(envFile, envContent);
  }

  // 7. Skill packs
  let selectedSkills: SkillPackId[];

  if (opts.nonInteractive) {
    selectedSkills = ["memory", "executive"];
  } else {
    const grouped = groupByCategory(listBundledSkills());
    const choices: Array<{
      name: string;
      value: SkillPackId;
      checked: boolean;
    }> = [];

    for (const [category, packs] of grouped) {
      for (const pack of packs) {
        choices.push({
          name: `[${categoryLabel(category)}] ${pack.name} — ${pack.description}`,
          value: pack.id,
          checked: pack.id === "memory",
        });
      }
    }

    selectedSkills = await checkbox({
      message: "Select skill packs (space to toggle, enter to confirm):",
      choices,
    });

    // Always include memory
    if (!selectedSkills.includes("memory")) {
      selectedSkills.unshift("memory");
    }
  }

  if (selectedSkills.length > 5) {
    console.log(
      `  Installing ${selectedSkills.length} packs — this increases token costs per API call.`,
    );
  }

  for (const id of selectedSkills) {
    await installSkillPack(id, workspace);
  }
  console.log(`  ${selectedSkills.length} skill pack(s) installed.`);

  // 8. Workspace personalization
  let orgName = "";
  let orgType = "";
  let location = "";
  let primaryLanguage = "English";
  let secondaryLanguage = "";
  let timezone = Intl.DateTimeFormat().resolvedOptions().timeZone;
  let briefingTime = "07:00";

  if (!opts.nonInteractive) {
    orgName = await input({
      message: "Organization name:",
      default: "",
    });

    orgType = await input({
      message: "Organization type (e.g., school, business, government):",
      default: "",
    });

    location = await input({
      message: "Location (e.g., city, country):",
      default: "",
    });

    primaryLanguage = await input({
      message: "Primary language:",
      default: "English",
    });

    secondaryLanguage = await input({
      message: "Secondary language (blank if none):",
      default: "",
    });

    timezone = await input({
      message: "Timezone:",
      default: timezone,
      validate: (val: string) => {
        try {
          const valid = Intl.supportedValuesOf("timeZone");
          if (valid.includes(val)) return true;
        } catch {
          // Intl.supportedValuesOf may not exist in older runtimes
          return true;
        }
        return "Invalid timezone. Example: America/New_York, Asia/Phnom_Penh, UTC";
      },
    });

    briefingTime = await input({
      message: "Morning briefing time (24h):",
      default: "07:00",
      validate: (val: string) =>
        /^\d{2}:\d{2}$/.test(val) || "Use HH:MM format (e.g., 07:00)",
    });
  }

  // 9. Generate workspace templates
  const vars: WorkspaceVars = {
    ORG_NAME: orgName || "My Organization",
    ORG_TYPE: orgType || "Organization",
    LOCATION: location || "",
    PRIMARY_LANGUAGE: primaryLanguage,
    SECONDARY_LANGUAGE: secondaryLanguage || "English",
    TIMEZONE: timezone,
    BRIEFING_TIME: briefingTime,
  };

  await installTemplates(workspace, vars);
  console.log("  Workspace templates installed.");

  // 10. OpenShell sandbox (Full mode)
  if (deploymentMode === "full") {
    console.log("  Creating OpenShell sandbox...");
    try {
      await exec("openshell", [
        "sandbox",
        "create",
        "--forward",
        "18789",
        "--from",
        "openclaw",
        "--",
        "openclaw-start",
      ]);
      console.log("  OpenShell sandbox created.");
    } catch {
      console.error("  Failed to create OpenShell sandbox.");
      console.error(
        "  Try manually: openshell sandbox create --forward <port> --from openclaw -- openclaw-start",
      );
      console.error(
        "  If port 18789 is in use, choose a different port with --forward <port>.",
      );
      deploymentMode = "lite";
    }
  }

  // 11. Save config
  const config: NimmitConfig = {
    version: VERSION,
    agent: agentName,
    workspace,
    deploymentMode,
    skills: selectedSkills,
    channels,
    provider: {
      type: providerType,
      model: model || undefined,
    },
    org: orgName ? { name: orgName, type: orgType, location } : undefined,
    language: primaryLanguage,
    timezone,
    onboardedAt: new Date().toISOString(),
  };

  await saveConfig(config);

  // 12. Offer to start gateway (Lite mode only — Full mode starts via OpenShell)
  if (deploymentMode === "lite" && !opts.nonInteractive) {
    const startNow = await confirm({
      message: "Start OpenClaw gateway now?",
      default: true,
    });
    if (startNow) {
      console.log("  Starting gateway...");
      try {
        await runOpenclaw(["gateway", "--force"]);
      } catch {
        console.log(
          "  Gateway may already be running, or use: openclaw gateway",
        );
      }
    }
  }

  // 13. Summary
  console.log("");
  console.log("  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
  console.log("  Nimmit is ready.");
  console.log("  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
  console.log("");
  console.log(`  Mode:      ${deploymentMode}`);
  console.log(`  Provider:  ${providerType}${model ? ` (${model})` : ""}`);
  console.log(`  Skills:    ${selectedSkills.length} installed`);

  const activeChannels = Object.entries(channels)
    .filter(([, v]) => v?.enabled)
    .map(([k]) => k);
  if (activeChannels.length > 0) {
    console.log(`  Channels:  ${activeChannels.join(", ")}`);
  }

  // M2: Warn if non-interactive mode skipped API key
  if (opts.nonInteractive && !apiKey && envKey) {
    console.log("");
    console.log(
      `  Warning: No API key configured. Set your provider key:`,
    );
    console.log(`    export ${envKey}=<your-key>`);
    console.log(`    # or add to ~/.openclaw/.env`);
  }

  console.log("");
  console.log("  Commands:");
  console.log("    nimmit status          Show status");
  console.log("    nimmit skills list     Available skill packs");
  console.log("    nimmit update          Update OpenClaw + skills");
  console.log("    openclaw gateway       Start the gateway");
  console.log("");
}

// Escape special characters for double-quoted .env values (C1)
function escapeEnvValue(value: string): string {
  return value
    .replace(/\\/g, "\\\\")
    .replace(/"/g, '\\"')
    .replace(/\$/g, "\\$")
    .replace(/`/g, "\\`");
}

// Helper: read .env file into key-value map
async function readEnvFile(path: string): Promise<Record<string, string>> {
  const result: Record<string, string> = {};
  try {
    const content = await readFile(path, "utf-8");
    for (const line of content.split("\n")) {
      const trimmed = line.trim();
      if (!trimmed || trimmed.startsWith("#")) continue;
      const eqIdx = trimmed.indexOf("=");
      if (eqIdx === -1) continue;
      const key = trimmed.slice(0, eqIdx);
      let value = trimmed.slice(eqIdx + 1);
      // Strip surrounding quotes
      if (
        (value.startsWith('"') && value.endsWith('"')) ||
        (value.startsWith("'") && value.endsWith("'"))
      ) {
        value = value.slice(1, -1);
      }
      result[key] = value;
    }
  } catch {
    // File doesn't exist yet
  }
  return result;
}

// Helper: write key-value map to .env file (C1: escaped, C2: atomic)
async function writeEnvFile(
  path: string,
  env: Record<string, string>,
): Promise<void> {
  const lines = Object.entries(env).map(
    ([key, value]) => `${key}="${escapeEnvValue(value)}"`,
  );
  await atomicWriteFile(path, lines.join("\n") + "\n", { mode: 0o600 });
}
