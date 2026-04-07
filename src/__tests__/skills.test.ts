import { describe, it, before, after } from "node:test";
import assert from "node:assert/strict";
import { readFile, mkdtemp, rm } from "node:fs/promises";
import { join } from "node:path";
import { tmpdir } from "node:os";
import { parse as parseYaml } from "yaml";
import {
  listBundledSkills,
  findSkillPack,
  bundledSkillPath,
  installSkillPack,
  removeSkillPack,
  listInstalledSkills,
  groupByCategory,
  SKILL_PACKS,
} from "../skills.js";

describe("skills registry", () => {
  it("has 18 skill packs", () => {
    assert.equal(SKILL_PACKS.length, 18);
  });

  it("every pack has required fields", () => {
    for (const pack of SKILL_PACKS) {
      assert.ok(pack.id, `missing id`);
      assert.ok(pack.name, `missing name for ${pack.id}`);
      assert.ok(pack.description, `missing description for ${pack.id}`);
      assert.ok(pack.category, `missing category for ${pack.id}`);
    }
  });

  it("no duplicate ids", () => {
    const ids = SKILL_PACKS.map((s) => s.id);
    const unique = new Set(ids);
    assert.equal(unique.size, ids.length, "duplicate skill pack IDs found");
  });

  it("findSkillPack returns correct pack", () => {
    const exec = findSkillPack("executive");
    assert.ok(exec);
    assert.equal(exec.id, "executive");
    assert.equal(exec.category, "business");
  });

  it("findSkillPack returns undefined for unknown", () => {
    assert.equal(findSkillPack("nonexistent"), undefined);
  });

  it("groupByCategory groups correctly", () => {
    const groups = groupByCategory(listBundledSkills());
    assert.ok(groups.has("core"));
    assert.ok(groups.has("business"));
    assert.ok(groups.has("public"));
    assert.ok(groups.has("professional"));
    assert.ok(groups.has("intelligence"));

    const core = groups.get("core");
    assert.ok(core);
    assert.equal(core.length, 1);
    assert.equal(core[0].id, "memory");
  });
});

describe("skill pack YAML frontmatter", () => {
  it("every bundled SKILL.md has valid YAML frontmatter", async () => {
    for (const pack of SKILL_PACKS) {
      const path = bundledSkillPath(pack.id);
      const content = await readFile(path, "utf-8");

      // Find frontmatter between --- markers
      // Some files may have ```skill wrapper, handle both cases
      const cleaned = content.replace(/^```skill\n/, "").replace(/\n```$/, "");
      const match = cleaned.match(/^---\n([\s\S]*?)\n---/);
      assert.ok(match, `${pack.id}: no YAML frontmatter found`);

      const yaml = parseYaml(match[1]);
      assert.ok(yaml.name, `${pack.id}: frontmatter missing 'name'`);
      assert.ok(
        yaml.description,
        `${pack.id}: frontmatter missing 'description'`,
      );
      assert.ok(
        yaml.version,
        `${pack.id}: frontmatter missing 'version'`,
      );
      assert.ok(
        yaml.author,
        `${pack.id}: frontmatter missing 'author'`,
      );
      assert.ok(
        Array.isArray(yaml.tags) && yaml.tags.length > 0,
        `${pack.id}: frontmatter missing 'tags' array`,
      );

      // Name should NOT have nimmit- prefix (we cleaned those up)
      assert.ok(
        !yaml.name.startsWith("nimmit-"),
        `${pack.id}: name still has nimmit- prefix: ${yaml.name}`,
      );
    }
  });
});

describe("skill pack install/remove", () => {
  let tmpDir: string;

  before(async () => {
    tmpDir = await mkdtemp(join(tmpdir(), "nimmit-test-"));
  });

  after(async () => {
    await rm(tmpDir, { recursive: true, force: true });
  });

  it("installs a skill pack to workspace", async () => {
    await installSkillPack("executive", tmpDir);
    const content = await readFile(
      join(tmpDir, "skills", "nimmit-executive", "SKILL.md"),
      "utf-8",
    );
    assert.ok(content.includes("name: executive"));
  });

  it("lists installed skills", async () => {
    await installSkillPack("memory", tmpDir);
    const installed = await listInstalledSkills(tmpDir);
    assert.ok(installed.includes("executive"));
    assert.ok(installed.includes("memory"));
  });

  it("removes a skill pack", async () => {
    await removeSkillPack("executive", tmpDir);
    const installed = await listInstalledSkills(tmpDir);
    assert.ok(!installed.includes("executive"));
    assert.ok(installed.includes("memory"));
  });

  it("listInstalledSkills returns empty for nonexistent dir", async () => {
    const result = await listInstalledSkills("/tmp/nonexistent-nimmit-test");
    assert.deepEqual(result, []);
  });
});
