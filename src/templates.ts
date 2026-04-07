import { readFile, writeFile, mkdir } from "node:fs/promises";
import { join, dirname } from "node:path";
import { fileURLToPath } from "node:url";
import type { WorkspaceVars } from "./types.js";

const __dirname = dirname(fileURLToPath(import.meta.url));
const TEMPLATES_DIR = join(__dirname, "..", "templates");

const VALID_TEMPLATES = ["SOUL.md", "IDENTITY.md", "HEARTBEAT.md"];

export async function renderTemplate(
  templateName: string,
  vars: WorkspaceVars,
): Promise<string> {
  if (!VALID_TEMPLATES.includes(templateName)) {
    throw new Error(`Unknown template: ${templateName}`);
  }

  const templatePath = join(TEMPLATES_DIR, templateName);
  let content = await readFile(templatePath, "utf-8");

  // Single-pass replacement prevents double-substitution when a value contains {{KEY}}
  const varsRecord: Record<string, string> = { ...vars };
  content = content.replace(/\{\{(\w+)\}\}/g, (match, key: string) => {
    return key in varsRecord ? varsRecord[key] : match;
  });

  return content;
}

export async function installTemplates(
  workspace: string,
  vars: WorkspaceVars,
): Promise<void> {
  const templates: Array<{ file: string; destSkill: string }> = [
    { file: "SOUL.md", destSkill: "nimmit-soul" },
    { file: "IDENTITY.md", destSkill: "nimmit-identity" },
    { file: "HEARTBEAT.md", destSkill: "nimmit-heartbeat" },
  ];

  for (const { file, destSkill } of templates) {
    const rendered = await renderTemplate(file, vars);
    const destDir = join(workspace, "skills", destSkill);
    await mkdir(destDir, { recursive: true });
    await writeFile(join(destDir, "SKILL.md"), rendered, "utf-8");
  }
}
