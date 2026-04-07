import { readFile, writeFile, mkdir, rename } from "node:fs/promises";
import { randomBytes } from "node:crypto";
import { homedir } from "node:os";
import { join, dirname } from "node:path";
import { execFile } from "node:child_process";
import { promisify } from "node:util";
import type { NimmitConfig } from "./types.js";

const exec = promisify(execFile);

const CONFIG_DIR = join(homedir(), ".nimmit");
const CONFIG_FILE = join(CONFIG_DIR, "config.json");

export function configDir(): string {
  return CONFIG_DIR;
}

export function configPath(): string {
  return CONFIG_FILE;
}

export async function atomicWriteFile(
  path: string,
  content: string,
  opts?: { mode?: number },
): Promise<void> {
  await mkdir(dirname(path), { recursive: true });
  const tmpPath = `${path}.${randomBytes(4).toString("hex")}.tmp`;
  await writeFile(tmpPath, content, { encoding: "utf-8", mode: opts?.mode });
  await rename(tmpPath, path);
}

export async function loadConfig(): Promise<NimmitConfig | null> {
  try {
    const raw = await readFile(CONFIG_FILE, "utf-8");
    return JSON.parse(raw) as NimmitConfig;
  } catch {
    return null;
  }
}

export async function saveConfig(config: NimmitConfig): Promise<void> {
  await mkdir(CONFIG_DIR, { recursive: true });
  await atomicWriteFile(
    CONFIG_FILE,
    JSON.stringify(config, null, 2) + "\n",
    { mode: 0o600 },
  );
}

export async function resolveWorkspace(agent: string): Promise<string> {
  try {
    const { stdout } = await exec("openclaw", ["agents", "show", agent, "--json"]);
    const data = JSON.parse(stdout) as { workspace?: string };
    if (data.workspace) return data.workspace;
  } catch {
    // fall through to default
  }
  return join(homedir(), ".openclaw", "agents", agent, "workspace");
}

export function defaultWorkspace(agent: string): string {
  return join(homedir(), ".openclaw", "agents", agent, "workspace");
}

export async function openclawInstalled(): Promise<boolean> {
  try {
    await exec("openclaw", ["--version"]);
    return true;
  } catch {
    return false;
  }
}

export async function openclawVersion(): Promise<string | null> {
  try {
    const { stdout } = await exec("openclaw", ["--version"]);
    return stdout.trim().split("\n")[0];
  } catch {
    return null;
  }
}

export async function openshellInstalled(): Promise<boolean> {
  try {
    await exec("openshell", ["--version"]);
    return true;
  } catch {
    return false;
  }
}

export async function runOpenclaw(
  args: string[],
): Promise<{ stdout: string; stderr: string }> {
  return exec("openclaw", args);
}
