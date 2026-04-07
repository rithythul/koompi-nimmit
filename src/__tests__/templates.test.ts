import { describe, it, before, after } from "node:test";
import assert from "node:assert/strict";
import { mkdtemp, rm, readFile, readdir } from "node:fs/promises";
import { join } from "node:path";
import { tmpdir } from "node:os";
import { renderTemplate, installTemplates } from "../templates.js";
import type { WorkspaceVars } from "../types.js";

const testVars: WorkspaceVars = {
  ORG_NAME: "Acme Corp",
  ORG_TYPE: "Technology",
  LOCATION: "San Francisco",
  PRIMARY_LANGUAGE: "English",
  SECONDARY_LANGUAGE: "Spanish",
  TIMEZONE: "America/Los_Angeles",
  BRIEFING_TIME: "08:00",
};

describe("template rendering", () => {
  it("replaces all placeholders in SOUL.md", async () => {
    const rendered = await renderTemplate("SOUL.md", testVars);
    assert.ok(rendered.includes("Acme Corp"));
    assert.ok(rendered.includes("English"));
    assert.ok(rendered.includes("Spanish"));
    assert.ok(rendered.includes("America/Los_Angeles"));
    assert.ok(!rendered.includes("{{"), "unreplaced placeholder found");
  });

  it("replaces all placeholders in IDENTITY.md", async () => {
    const rendered = await renderTemplate("IDENTITY.md", testVars);
    assert.ok(rendered.includes("Acme Corp"));
    assert.ok(rendered.includes("Technology"));
    assert.ok(rendered.includes("San Francisco"));
    assert.ok(!rendered.includes("{{"), "unreplaced placeholder found");
  });

  it("replaces all placeholders in HEARTBEAT.md", async () => {
    const rendered = await renderTemplate("HEARTBEAT.md", testVars);
    assert.ok(rendered.includes("08:00"));
    assert.ok(rendered.includes("America/Los_Angeles"));
    assert.ok(!rendered.includes("{{"), "unreplaced placeholder found");
  });

  it("single-pass: values containing {{KEY}} are not double-replaced", async () => {
    const evilVars: WorkspaceVars = {
      ...testVars,
      ORG_NAME: "{{TIMEZONE}}",
    };
    const rendered = await renderTemplate("SOUL.md", evilVars);
    // The literal string "{{TIMEZONE}}" should appear in output, not "America/Los_Angeles"
    assert.ok(rendered.includes("{{TIMEZONE}}"), "double-replacement occurred");
  });

  it("rejects unknown template names", async () => {
    await assert.rejects(
      () => renderTemplate("../../etc/passwd", testVars),
      { message: "Unknown template: ../../etc/passwd" },
    );
  });
});

describe("template installation", () => {
  let tmpDir: string;

  before(async () => {
    tmpDir = await mkdtemp(join(tmpdir(), "nimmit-tmpl-test-"));
  });

  after(async () => {
    await rm(tmpDir, { recursive: true, force: true });
  });

  it("creates skill directories in workspace", async () => {
    await installTemplates(tmpDir, testVars);

    const skillsDir = join(tmpDir, "skills");
    const entries = await readdir(skillsDir);
    assert.ok(entries.includes("nimmit-soul"));
    assert.ok(entries.includes("nimmit-identity"));
    assert.ok(entries.includes("nimmit-heartbeat"));
  });

  it("writes rendered SKILL.md files", async () => {
    const soulContent = await readFile(
      join(tmpDir, "skills", "nimmit-soul", "SKILL.md"),
      "utf-8",
    );
    assert.ok(soulContent.includes("Acme Corp"));
    assert.ok(soulContent.includes("name: soul"));

    const identityContent = await readFile(
      join(tmpDir, "skills", "nimmit-identity", "SKILL.md"),
      "utf-8",
    );
    assert.ok(identityContent.includes("Technology"));

    const heartbeatContent = await readFile(
      join(tmpDir, "skills", "nimmit-heartbeat", "SKILL.md"),
      "utf-8",
    );
    assert.ok(heartbeatContent.includes("08:00"));
  });
});
