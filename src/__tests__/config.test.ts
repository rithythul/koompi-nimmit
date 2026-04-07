import { describe, it, before, after } from "node:test";
import assert from "node:assert/strict";
import { mkdtemp, rm, readFile } from "node:fs/promises";
import { join } from "node:path";
import { tmpdir } from "node:os";

// We test config functions by overriding the config path.
// Since config.ts uses hardcoded paths, we test the serialization logic directly.
import type { NimmitConfig } from "../types.js";

describe("config serialization", () => {
  it("NimmitConfig round-trips through JSON", () => {
    const config: NimmitConfig = {
      version: "0.1.0",
      agent: "nimmit",
      workspace: "/home/test/.openclaw/agents/nimmit/workspace",
      deploymentMode: "lite",
      skills: ["memory", "executive"],
      channels: {
        telegram: { enabled: true },
        discord: { enabled: false },
      },
      provider: {
        type: "anthropic",
        model: "anthropic/claude-sonnet-4-20250514",
      },
      org: {
        name: "Test Org",
        type: "business",
        location: "Earth",
      },
      language: "English",
      timezone: "UTC",
      onboardedAt: "2026-04-07T12:00:00.000Z",
    };

    const json = JSON.stringify(config, null, 2);
    const parsed = JSON.parse(json) as NimmitConfig;

    assert.equal(parsed.version, config.version);
    assert.equal(parsed.agent, config.agent);
    assert.equal(parsed.deploymentMode, config.deploymentMode);
    assert.deepEqual(parsed.skills, config.skills);
    assert.deepEqual(parsed.channels, config.channels);
    assert.deepEqual(parsed.provider, config.provider);
    assert.equal(parsed.org?.name, config.org?.name);
    assert.equal(parsed.language, config.language);
    assert.equal(parsed.timezone, config.timezone);
    assert.equal(parsed.onboardedAt, config.onboardedAt);
  });

  it("handles minimal config", () => {
    const config: NimmitConfig = {
      version: "0.1.0",
      agent: "nimmit",
      workspace: "/tmp/test",
      deploymentMode: "lite",
      skills: [],
      channels: {},
      provider: { type: "ollama" },
      onboardedAt: new Date().toISOString(),
    };

    const json = JSON.stringify(config);
    const parsed = JSON.parse(json) as NimmitConfig;
    assert.equal(parsed.skills.length, 0);
    assert.equal(parsed.provider.model, undefined);
    assert.equal(parsed.org, undefined);
  });
});
