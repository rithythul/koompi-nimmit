import { Command } from "commander";
import { VERSION } from "../types.js";
import { registerOnboardCommand } from "./commands/onboard.js";
import { registerUpdateCommand } from "./commands/update.js";
import { registerStatusCommand } from "./commands/status.js";
import { registerSkillsCommand } from "./commands/skills.js";
import { registerPublishCommand } from "./commands/publish.js";

const program = new Command();

program
  .name("nimmit")
  .description(
    "Nimmit — AI assistant skill packs and OpenClaw plugin. Install an AI worker, teach it your job, let it work.",
  )
  .version(VERSION);

registerOnboardCommand(program);
registerUpdateCommand(program);
registerStatusCommand(program);
registerSkillsCommand(program);
registerPublishCommand(program);

program.parse();
