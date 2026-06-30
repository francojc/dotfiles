import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { join } from "node:path";

// ---------------------------------------------------------------------------
// Configuration
// ---------------------------------------------------------------------------

const CACHE_DIR = join(process.env.HOME || "/tmp", ".cache", "pi");
const CACHE_FILE = join(CACHE_DIR, "opencode-go-models.json");
const CACHE_TTL_MS = 24 * 60 * 60 * 1000; // 24 hours
const CACHE_SCHEMA_VERSION = 3;
const QUIET_STARTUP = process.argv.includes("-p") || process.argv.includes("--print") || process.argv.includes("json") || process.env.PI_MODEL_DISCOVERY_DEBUG !== "1";

function logInfo(message: string): void {
  if (!QUIET_STARTUP) console.log(message);
}

function logWarn(message: string): void {
  if (!QUIET_STARTUP) console.warn(message);
}

const MODELS_DEV_URL = "https://models.dev/api.json";
const OPENCODE_MODELS_URL = "https://opencode.ai/zen/go/v1/models";
// Base URLs differ by API family:
// - anthropic-messages: SDK appends /v1/messages → base must NOT include /v1
// - openai-completions: SDK appends /chat/completions → base includes /v1
const BASE_URL_ANTHROPIC = "https://opencode.ai/zen/go";
const BASE_URL_OPENAI    = "https://opencode.ai/zen/go/v1";

// ---------------------------------------------------------------------------
// Endpoint routing
// Source of truth for availability: https://opencode.ai/zen/go/v1/models
// Metadata/routing hints: https://models.dev/api.json
// If models.dev marks a model as Anthropic SDK, route to /v1/messages.
// Otherwise default to OpenAI-compatible chat completions. This keeps new Go
// models visible in Pi without needing a code edit every time OpenCode adds one.
// ---------------------------------------------------------------------------

type ApiKind = "anthropic-messages" | "openai-completions";

type Endpoint = { api: ApiKind; baseUrl: string; sdk: string };

const SDK_ANTHROPIC = "@ai-sdk/anthropic";
const SDK_OPENAI_COMPATIBLE = "@ai-sdk/openai-compatible";

// Explicit docs-backed mappings. Dynamic routing below handles new models.
const ENDPOINT_OVERRIDES: Record<string, Endpoint> = {
  "minimax-m3":   { api: "anthropic-messages", baseUrl: BASE_URL_ANTHROPIC, sdk: SDK_ANTHROPIC },
  "minimax-m2.7": { api: "anthropic-messages", baseUrl: BASE_URL_ANTHROPIC, sdk: SDK_ANTHROPIC },
  "minimax-m2.5": { api: "anthropic-messages", baseUrl: BASE_URL_ANTHROPIC, sdk: SDK_ANTHROPIC },
  "qwen3.7-max":  { api: "anthropic-messages", baseUrl: BASE_URL_ANTHROPIC, sdk: SDK_ANTHROPIC },
  "qwen3.7-plus": { api: "anthropic-messages", baseUrl: BASE_URL_ANTHROPIC, sdk: SDK_ANTHROPIC },
  "qwen3.6-plus": { api: "anthropic-messages", baseUrl: BASE_URL_ANTHROPIC, sdk: SDK_ANTHROPIC },
  "qwen3.5-plus": { api: "anthropic-messages", baseUrl: BASE_URL_ANTHROPIC, sdk: SDK_ANTHROPIC },
};

// ---------------------------------------------------------------------------
// Types
// ---------------------------------------------------------------------------

type ModelsDevModel = {
  id: string;
  name?: string;
  family?: string;
  reasoning?: boolean;
  tool_call?: boolean;
  modalities?: { input?: string[]; output?: string[] };
  limit?: { context?: number; output?: number };
  cost?: { input?: number; output?: number; cache_read?: number; cache_write?: number };
  status?: string;
  provider?: { npm?: string };
};

type PiModel = {
  id: string;
  name: string;
  api: ApiKind;
  baseUrl: string;
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
  models: PiModel[];
};

// ---------------------------------------------------------------------------
// Per-model Pi-specific overrides
// Add compat/thinkingLevelMap here for models that need special handling
// ---------------------------------------------------------------------------

const MODEL_OVERRIDES: Record<string, Partial<PiModel>> = {
  "kimi-k2.6": {
    compat: { thinkingFormat: "openai" },
    thinkingLevelMap: {
      off: "none",
      minimal: null,
      low: "low",
      medium: "medium",
      high: "high",
      xhigh: null,
    },
  },
  // Add overrides for other reasoning models as needed, e.g.:
  // "deepseek-v4-pro": { compat: { thinkingFormat: "deepseek" } },
  // "minimax-m3":      { compat: { forceAdaptiveThinking: true } },
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
    const raw = readFileSync(CACHE_FILE, "utf-8");
    const parsed = JSON.parse(raw) as CacheEntry;
    if (parsed.schemaVersion !== CACHE_SCHEMA_VERSION) {
      logInfo(`[opencode-go-discovery] Cache schema v${parsed.schemaVersion ?? 1} != v${CACHE_SCHEMA_VERSION}, ignoring`);
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
      models,
    };
    writeFileSync(CACHE_FILE, JSON.stringify(entry, null, 2));
  } catch (err) {
    logWarn(`[opencode-go-discovery] Failed to write cache: ${err}`);
  }
}

function isStale(entry: CacheEntry): boolean {
  return Date.now() - entry.fetchedAt > CACHE_TTL_MS;
}

// ---------------------------------------------------------------------------
// Mapping
// ---------------------------------------------------------------------------

function mapInput(modalities?: { input?: string[] }): string[] {
  if (!modalities?.input) return ["text"];
  const inputs = modalities.input;
  const result: string[] = ["text"];
  if (inputs.includes("image")) result.push("image");
  // Pi only supports "text" and "image" for input modalities
  return result;
}

function endpointFor(id: string, meta?: ModelsDevModel): Endpoint {
  const override = ENDPOINT_OVERRIDES[id];
  if (override) return override;

  if (meta?.provider?.npm === SDK_ANTHROPIC) {
    return { api: "anthropic-messages", baseUrl: BASE_URL_ANTHROPIC, sdk: SDK_ANTHROPIC };
  }

  return { api: "openai-completions", baseUrl: BASE_URL_OPENAI, sdk: meta?.provider?.npm ?? SDK_OPENAI_COMPATIBLE };
}

function buildModel(id: string, meta?: ModelsDevModel): PiModel {
  const endpoint = endpointFor(id, meta);

  // Cross-check models.dev SDK hint; warn (don't fail) on mismatch
  if (meta?.provider?.npm && meta.provider.npm !== endpoint.sdk) {
    logWarn(
      `[opencode-go-discovery] SDK hint mismatch for "${id}": route=${endpoint.sdk}, models.dev=${meta.provider.npm}`,
    );
  }

  const base: PiModel = {
    id,
    name: meta?.name ?? id,
    api: endpoint.api,
    baseUrl: endpoint.baseUrl,
    reasoning: meta?.reasoning ?? false,
    input: mapInput(meta?.modalities),
    cost: {
      input: meta?.cost?.input ?? 0,
      output: meta?.cost?.output ?? 0,
      cacheRead: meta?.cost?.cache_read ?? 0,
      cacheWrite: meta?.cost?.cache_write ?? 0,
    },
    contextWindow: meta?.limit?.context ?? 128000,
    maxTokens: meta?.limit?.output ?? 16384,
  };

  const overrides = MODEL_OVERRIDES[id];
  if (overrides) {
    return { ...base, ...overrides };
  }
  return base;
}

// ---------------------------------------------------------------------------
// Fetch
// ---------------------------------------------------------------------------

async function fetchModels(): Promise<PiModel[]> {
  const [devRes, apiRes] = await Promise.all([
    fetch(MODELS_DEV_URL).catch(() => null),
    fetch(OPENCODE_MODELS_URL).catch(() => null),
  ]);

  // Parse models.dev metadata for opencode-go provider
  let devModels: Record<string, ModelsDevModel> = {};
  if (devRes?.ok) {
    try {
      const devData = (await devRes.json()) as Record<string, any>;
      const ogProvider = devData["opencode-go"];
      if (ogProvider?.models) {
        devModels = ogProvider.models;
      }
    } catch (err) {
      logWarn(`[opencode-go-discovery] Failed to parse models.dev: ${err}`);
    }
  } else {
    logWarn(`[opencode-go-discovery] models.dev fetch failed: ${devRes?.status ?? "network error"}`);
  }

  // Parse active model list from OpenCode API
  let activeIds: string[] = [];
  if (apiRes?.ok) {
    try {
      const apiData = (await apiRes.json()) as { data: Array<{ id: string }> };
      activeIds = apiData.data.map((m) => m.id);
    } catch (err) {
      logWarn(`[opencode-go-discovery] Failed to parse API models: ${err}`);
    }
  } else {
    logWarn(`[opencode-go-discovery] OpenCode API fetch failed, using models.dev keys`);
    activeIds = Object.keys(devModels);
  }

  if (activeIds.length === 0 && Object.keys(devModels).length === 0) {
    throw new Error("No model data from any source");
  }

  // Build models for all active IDs from OpenCode. Unknown models default to
  // OpenAI-compatible routing so Pi sees newly added Go models immediately.
  const models: PiModel[] = [];
  for (const id of activeIds) {
    const meta = devModels[id];
    if (meta?.status === "deprecated") {
      logInfo(`[opencode-go-discovery] Skipping deprecated model: ${id}`);
      continue;
    }
    if (!meta) {
      logWarn(`[opencode-go-discovery] No models.dev metadata for "${id}", using defaults`);
    }
    models.push(buildModel(id, meta));
  }

  if (models.length === 0) {
    throw new Error("No models after filtering");
  }

  return models;
}

// ---------------------------------------------------------------------------
// Provider registration
// ---------------------------------------------------------------------------

function registerProvider(pi: ExtensionAPI, models: PiModel[]): void {
  pi.registerProvider("opencode-go", {
    baseUrl: BASE_URL_OPENAI,
    apiKey: "$OPENCODE_API_KEY",
    // Provider-level api is a fallback only; each model overrides it with its own api + baseUrl + compat
    api: "openai-completions",
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
    logInfo(`[opencode-go-discovery] Registered ${cached.models.length} models from cache`);
  }

  // Refresh if cache is missing or stale
  if (!cached || isStale(cached)) {
    try {
      const fresh = await fetchModels();
      writeCache(fresh);

      if (!cached) {
        registerProvider(pi, fresh);
        logInfo(`[opencode-go-discovery] Registered ${fresh.length} models from API`);
      } else {
        logInfo(`[opencode-go-discovery] Background refresh cached ${fresh.length} models`);
      }
    } catch (err) {
      logWarn(`[opencode-go-discovery] Fetch failed: ${err}`);
      if (!cached) {
        logWarn("[opencode-go-discovery] No cache available - provider not registered");
      }
    }
  }
}
