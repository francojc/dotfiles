import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { join } from "node:path";

// ---------------------------------------------------------------------------
// Configuration
// ---------------------------------------------------------------------------

const CACHE_DIR = join(process.env.HOME || "/tmp", ".cache", "pi");
const CACHE_FILE = join(CACHE_DIR, "copilot-api-models.json");
const CACHE_TTL_MS = 12 * 60 * 60 * 1000; // 12 hours
const CACHE_SCHEMA_VERSION = 1;
const DEFAULT_BASE_URL = "https://api.githubcopilot.com";
const COPILOT_API_VERSION = "2026-06-01";
const QUIET_STARTUP = process.argv.includes("-p") || process.argv.includes("--print") || process.argv.includes("json") || process.env.PI_MODEL_DISCOVERY_DEBUG !== "1";

function logInfo(message: string): void {
  if (!QUIET_STARTUP) console.log(message);
}

function logWarn(message: string): void {
  if (!QUIET_STARTUP) console.warn(message);
}

function copilotBaseUrl(): string {
  return (process.env.GITHUB_COPILOT_BASE_URL || DEFAULT_BASE_URL).replace(/\/+$/, "");
}

function copilotHeaders(token?: string): Record<string, string> {
  return {
    Accept: "application/json",
    ...(token ? { Authorization: `Bearer ${token}` } : {}),
    "Content-Type": "application/json",
    "Copilot-Integration-Id": "vscode-chat",
    "Editor-Version": "vscode/1.107.0",
    "Editor-Plugin-Version": "copilot-chat/0.35.0",
    "User-Agent": "GitHubCopilotChat/0.35.0",
    "X-GitHub-Api-Version": COPILOT_API_VERSION,
  };
}

// ---------------------------------------------------------------------------
// Types
// ---------------------------------------------------------------------------

type CopilotRawModel = {
  id?: string;
  name?: string;
  vendor?: string;
  policy?: { state?: string };
  billing?: {
    token_prices?: {
      batch_size?: number;
      input_price?: number;
      output_price?: number;
      cache_price?: number;
    };
  } | null;
  capabilities?: {
    type?: string;
    limits?: {
      max_context_window_tokens?: number;
      max_output_tokens?: number;
      max_prompt_tokens?: number;
      vision?: unknown;
    };
    supports?: {
      tool_calls?: boolean;
      vision?: boolean;
      reasoning_effort?: string[];
      reasoningEffort?: boolean;
    };
  };
};

type CopilotModelsResponse = {
  data?: CopilotRawModel[];
};

type PiModel = {
  id: string;
  name: string;
  reasoning: boolean;
  input: string[];
  cost: { input: number; output: number; cacheRead: number; cacheWrite: number };
  contextWindow: number;
  maxTokens: number;
  compat?: Record<string, any>;
  thinkingLevelMap?: Record<string, string | null>;
};

type CacheEntry = {
  schemaVersion: number;
  fetchedAt: number;
  baseUrl: string;
  models: PiModel[];
};

// ---------------------------------------------------------------------------
// Cache helpers
// ---------------------------------------------------------------------------

function ensureCacheDir(): void {
  if (!existsSync(CACHE_DIR)) {
    mkdirSync(CACHE_DIR, { recursive: true });
  }
}

function readCache(): CacheEntry | null {
  try {
    if (!existsSync(CACHE_FILE)) return null;
    const parsed = JSON.parse(readFileSync(CACHE_FILE, "utf-8")) as CacheEntry;
    if (parsed.schemaVersion !== CACHE_SCHEMA_VERSION) {
      logInfo(`[copilot-api-discovery] Cache schema v${parsed.schemaVersion ?? 0} != v${CACHE_SCHEMA_VERSION}, ignoring`);
      return null;
    }
    return parsed;
  } catch {
    return null;
  }
}

function writeCache(models: PiModel[]): void {
  try {
    ensureCacheDir();
    const entry: CacheEntry = {
      schemaVersion: CACHE_SCHEMA_VERSION,
      fetchedAt: Date.now(),
      baseUrl: copilotBaseUrl(),
      models,
    };
    writeFileSync(CACHE_FILE, JSON.stringify(entry, null, 2));
  } catch (err) {
    logWarn(`[copilot-api-discovery] Failed to write cache: ${err}`);
  }
}

function isStale(entry: CacheEntry): boolean {
  return Date.now() - entry.fetchedAt > CACHE_TTL_MS || entry.baseUrl !== copilotBaseUrl();
}

// ---------------------------------------------------------------------------
// Mapping
// ---------------------------------------------------------------------------

function isUsableChatModel(model: CopilotRawModel): model is CopilotRawModel & { id: string } {
  if (typeof model.id !== "string" || model.id.length === 0) return false;
  if (model.policy?.state === "disabled") return false;
  if (model.capabilities?.type && model.capabilities.type !== "chat") return false;
  if (model.capabilities?.supports?.tool_calls === false) return false;
  return true;
}

function price(raw?: number): number {
  // Copilot token_prices are raw fixed-point-ish integers. Pi cost fields are $/1M tokens.
  return typeof raw === "number" && raw > 0 ? raw / 100_000_000_000 : 0;
}

function modelCost(model: CopilotRawModel): PiModel["cost"] {
  const prices = model.billing?.token_prices;
  return {
    input: price(prices?.input_price),
    output: price(prices?.output_price),
    cacheRead: price(prices?.cache_price),
    cacheWrite: 0,
  };
}

function supportsVision(model: CopilotRawModel): boolean {
  return model.capabilities?.supports?.vision === true || !!model.capabilities?.limits?.vision;
}

function buildModel(model: CopilotRawModel & { id: string }): PiModel {
  const supportsReasoning = Array.isArray(model.capabilities?.supports?.reasoning_effort) || model.capabilities?.supports?.reasoningEffort === true;

  return {
    id: model.id,
    name: model.name ?? model.id,
    // Keep raw Copilot API models conservative. Pi will not send reasoning_effort unless model-specific compatibility is proven.
    reasoning: false,
    ...(supportsReasoning ? { thinkingLevelMap: { off: null, minimal: null, low: null, medium: null, high: null, xhigh: null } } : {}),
    input: supportsVision(model) ? ["text", "image"] : ["text"],
    cost: modelCost(model),
    contextWindow: model.capabilities?.limits?.max_context_window_tokens ?? model.capabilities?.limits?.max_prompt_tokens ?? 128000,
    maxTokens: model.capabilities?.limits?.max_output_tokens ?? 4096,
    compat: {
      supportsDeveloperRole: false,
      supportsReasoningEffort: false,
      supportsStore: false,
    },
  };
}

// ---------------------------------------------------------------------------
// Fetch
// ---------------------------------------------------------------------------

async function fetchModels(): Promise<PiModel[]> {
  const token = process.env.GITHUB_COPILOT_API_KEY;
  if (!token) throw new Error("GITHUB_COPILOT_API_KEY not set");

  const response = await fetch(`${copilotBaseUrl()}/models`, {
    headers: copilotHeaders(token),
    signal: AbortSignal.timeout(8000),
  });

  if (!response.ok) {
    const text = await response.text().catch(() => "");
    throw new Error(`${response.status} ${response.statusText}${text ? `: ${text}` : ""}`);
  }

  const payload = (await response.json()) as CopilotModelsResponse;
  if (!Array.isArray(payload.data)) throw new Error("Invalid Copilot models response");

  const models = payload.data
    .filter(isUsableChatModel)
    .map(buildModel)
    .sort((a, b) => a.id.localeCompare(b.id));

  if (models.length === 0) throw new Error("No usable chat models returned");
  return models;
}

// ---------------------------------------------------------------------------
// Provider registration
// ---------------------------------------------------------------------------

function registerProvider(pi: ExtensionAPI, models: PiModel[]): void {
  pi.registerProvider("copilot-api", {
    baseUrl: copilotBaseUrl(),
    apiKey: "$GITHUB_COPILOT_API_KEY",
    api: "openai-completions",
    headers: {
      "Copilot-Integration-Id": "vscode-chat",
      "Editor-Version": "vscode/1.107.0",
      "Editor-Plugin-Version": "copilot-chat/0.35.0",
      "User-Agent": "GitHubCopilotChat/0.35.0",
      "X-GitHub-Api-Version": COPILOT_API_VERSION,
      "Openai-Intent": "conversation-edits",
      "X-Initiator": "user",
    },
    compat: {
      supportsDeveloperRole: false,
      supportsReasoningEffort: false,
      supportsStore: false,
    },
    models,
  });
}

// ---------------------------------------------------------------------------
// Extension entry point
// ---------------------------------------------------------------------------

export default async function (pi: ExtensionAPI) {
  const cached = readCache();

  if (cached) {
    registerProvider(pi, cached.models);
    logInfo(`[copilot-api-discovery] Registered ${cached.models.length} models from cache`);
  }

  if (!cached || isStale(cached)) {
    try {
      const fresh = await fetchModels();
      writeCache(fresh);

      if (!cached) {
        registerProvider(pi, fresh);
        logInfo(`[copilot-api-discovery] Registered ${fresh.length} models from API`);
      } else {
        logInfo(`[copilot-api-discovery] Background refresh cached ${fresh.length} models`);
      }
    } catch (err) {
      logWarn(`[copilot-api-discovery] Fetch failed: ${err}`);
      if (!cached) {
        logWarn("[copilot-api-discovery] No cache available - provider not registered");
      }
    }
  }
}
