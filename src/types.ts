export const VERSION = "0.1.0";

export type SkillPackId =
  | "executive"
  | "sme"
  | "finance"
  | "creative"
  | "logistics"
  | "construction"
  | "government"
  | "education"
  | "nonprofit"
  | "healthcare"
  | "legal"
  | "real-estate"
  | "agriculture"
  | "hospitality"
  | "geopolitical"
  | "economist"
  | "web-crawler"
  | "memory";

export type SkillCategory =
  | "core"
  | "business"
  | "public"
  | "professional"
  | "intelligence";

export interface SkillPackMeta {
  id: SkillPackId;
  name: string;
  description: string;
  category: SkillCategory;
}

export type ProviderType =
  | "anthropic"
  | "openai"
  | "google"
  | "ollama"
  | "openrouter"
  | "custom";

export type DeploymentMode = "full" | "lite";

export interface ProviderConfig {
  type: ProviderType;
  model?: string;
}

export interface ChannelConfig {
  telegram?: { enabled: boolean };
  discord?: { enabled: boolean };
  whatsapp?: { enabled: boolean };
  slack?: { enabled: boolean };
}

export interface NimmitConfig {
  version: string;
  agent: string;
  workspace: string;
  deploymentMode: DeploymentMode;
  skills: SkillPackId[];
  channels: ChannelConfig;
  provider: ProviderConfig;
  org?: {
    name: string;
    type?: string;
    location?: string;
  };
  language?: string;
  timezone?: string;
  onboardedAt: string;
}

export interface WorkspaceVars {
  ORG_NAME: string;
  ORG_TYPE: string;
  LOCATION: string;
  PRIMARY_LANGUAGE: string;
  SECONDARY_LANGUAGE: string;
  TIMEZONE: string;
  BRIEFING_TIME: string;
}
