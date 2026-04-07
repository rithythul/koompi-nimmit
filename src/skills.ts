import { readFile, writeFile, mkdir, readdir, rm } from "node:fs/promises";
import { join, dirname } from "node:path";
import { fileURLToPath } from "node:url";
import type { SkillPackId, SkillPackMeta, SkillCategory } from "./types.js";

const __dirname = dirname(fileURLToPath(import.meta.url));
const PACKAGE_ROOT = join(__dirname, "..");

export const SKILL_PACKS: SkillPackMeta[] = [
  // Core
  { id: "memory", name: "Memory", description: "Structured memory architecture — hierarchical storage, daily logging, weekly compaction", category: "core" },

  // Business & Operations
  { id: "executive", name: "Executive", description: "C-suite and leadership — daily briefings, decision support, report drafting", category: "business" },
  { id: "sme", name: "SME", description: "Small & medium business — social media, customer service, inventory, marketing", category: "business" },
  { id: "finance", name: "Finance", description: "Accounting and CFO — AP/AR, reconciliation, budgets, cash flow, close procedures", category: "business" },
  { id: "creative", name: "Creative", description: "Agencies and studios — project management, client briefs, content calendars", category: "business" },
  { id: "logistics", name: "Logistics", description: "Supply chain — shipment tracking, warehouse, route planning, fleet coordination", category: "business" },
  { id: "construction", name: "Construction", description: "Project management — scheduling, daily reports, subcontractor coordination, safety", category: "business" },

  // Public Sector & Education
  { id: "government", name: "Government", description: "Ministries and departments — formal documents, meeting prep, procurement, compliance", category: "public" },
  { id: "education", name: "Education", description: "Schools and universities — scheduling, curriculum, student progress, parent communication", category: "public" },
  { id: "nonprofit", name: "Nonprofit", description: "NGOs and foundations — donor management, grant tracking, fundraising, impact reporting", category: "public" },

  // Professional Services
  { id: "healthcare", name: "Healthcare", description: "Clinics and practices — patient scheduling, records, prescriptions, follow-ups", category: "professional" },
  { id: "legal", name: "Legal", description: "Law firms — case management, document drafting, deadline tracking, billing", category: "professional" },
  { id: "real-estate", name: "Real Estate", description: "Brokerages and agents — listings, client pipeline, showings, contracts", category: "professional" },
  { id: "agriculture", name: "Agriculture", description: "Farms and cooperatives — crop planning, weather alerts, inventory, market prices", category: "professional" },
  { id: "hospitality", name: "Hospitality", description: "Hotels and resorts — reservations, guest communication, revenue management", category: "professional" },

  // Intelligence & Research
  { id: "geopolitical", name: "Geopolitical", description: "Risk analysis and OSINT — conflict monitoring, sanctions, scenario analysis", category: "intelligence" },
  { id: "economist", name: "Economist", description: "Economic analysis — macro indicators, central bank monitoring, forecasting", category: "intelligence" },
  { id: "web-crawler", name: "Web Crawler", description: "Research and monitoring — social media, brand tracking, competitor intelligence", category: "intelligence" },
];

const CATEGORY_LABELS: Record<SkillCategory, string> = {
  core: "Core",
  business: "Business & Operations",
  public: "Public Sector & Education",
  professional: "Professional Services",
  intelligence: "Intelligence & Research",
};

export function categoryLabel(category: SkillCategory): string {
  return CATEGORY_LABELS[category];
}

export function listBundledSkills(): SkillPackMeta[] {
  return SKILL_PACKS;
}

export function findSkillPack(id: string): SkillPackMeta | undefined {
  return SKILL_PACKS.find((s) => s.id === id);
}

export function bundledSkillPath(id: SkillPackId): string {
  return join(PACKAGE_ROOT, "skill-packs", id, "SKILL.md");
}

export function installedSkillDir(workspace: string, id: SkillPackId): string {
  return join(workspace, "skills", `nimmit-${id}`);
}

export async function installSkillPack(
  id: SkillPackId,
  workspace: string,
): Promise<void> {
  const src = bundledSkillPath(id);
  const destDir = installedSkillDir(workspace, id);
  const destFile = join(destDir, "SKILL.md");

  await mkdir(destDir, { recursive: true });
  const content = await readFile(src, "utf-8");
  await writeFile(destFile, content, "utf-8");
}

export async function removeSkillPack(
  id: SkillPackId,
  workspace: string,
): Promise<void> {
  const dir = installedSkillDir(workspace, id);
  await rm(dir, { recursive: true, force: true });
}

export async function listInstalledSkills(
  workspace: string,
): Promise<SkillPackId[]> {
  const skillsDir = join(workspace, "skills");
  try {
    const entries = await readdir(skillsDir);
    return entries
      .filter((e) => e.startsWith("nimmit-"))
      .map((e) => e.replace("nimmit-", "") as SkillPackId)
      .filter((id) => findSkillPack(id) !== undefined);
  } catch {
    return [];
  }
}

export function groupByCategory(
  skills: SkillPackMeta[],
): Map<SkillCategory, SkillPackMeta[]> {
  const groups = new Map<SkillCategory, SkillPackMeta[]>();
  for (const skill of skills) {
    const list = groups.get(skill.category) ?? [];
    list.push(skill);
    groups.set(skill.category, list);
  }
  return groups;
}
