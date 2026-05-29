import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { join } from "node:path";

// ---------------------------------------------------------------------------
// Configuration
// ---------------------------------------------------------------------------

const CACHE_DIR = join(process.env.HOME || "/tmp", ".cache", "pi");
const CACHE_FILE = join(CACHE_DIR, "openrouter-models.json");
const CACHE_TTL_MS = 24 * 60 * 60 * 1000; // 24 hours

// ---------------------------------------------------------------------------
// Types
// ---------------------------------------------------------------------------

type Model = {
  id: string;
  name: string;
  reasoning: boolean;
  input: string[];
  cost: { input: number; output: number; cacheRead: number; cacheWrite: number };
  contextWindow: number;
  maxTokens: number;
};

type CacheEntry = {
  fetchedAt: number;
  models: Model[];
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
    return JSON.parse(raw) as CacheEntry;
  } catch {
    return null;
  }
}

function writeCache(models: Model[]): void {
  try {
    ensureCacheDir();
    const entry: CacheEntry = { fetchedAt: Date.now(), models };
    writeFileSync(CACHE_FILE, JSON.stringify(entry, null, 2));
  } catch (err) {
    console.warn(`[openrouter-models] Failed to write cache: ${err}`);
  }
}

function isStale(entry: CacheEntry): boolean {
  return Date.now() - entry.fetchedAt > CACHE_TTL_MS;
}

// ---------------------------------------------------------------------------
// Fetch
// ---------------------------------------------------------------------------

async function fetchModels(apiKey: string): Promise<Model[]> {
  const response = await fetch("https://openrouter.ai/api/v1/models", {
    headers: { Authorization: `Bearer ${apiKey}` },
  });

  if (!response.ok) {
    throw new Error(`HTTP ${response.status}`);
  }

  const payload = (await response.json()) as {
    data: Array<{
      id: string;
      name?: string;
      context_length?: number;
      top_provider?: { max_completion_tokens?: number };
      pricing?: { prompt?: string; completion?: string };
      architecture?: { input_modalities?: string[] };
    }>;
  };

  return payload.data.map((m) => {
    const inputCost = parseFloat(m.pricing?.prompt ?? "0") * 1_000_000;
    const outputCost = parseFloat(m.pricing?.completion ?? "0") * 1_000_000;
    const modalities = m.architecture?.input_modalities ?? ["text"];

    return {
      id: m.id,
      name: m.name ?? m.id,
      reasoning: m.id.includes(":thinking") || m.id.includes("o1") || m.id.includes("r1"),
      input: modalities.map((mod) => (mod === "image" ? "image" : "text")),
      cost: { input: inputCost, output: outputCost, cacheRead: 0, cacheWrite: 0 },
      contextWindow: m.context_length ?? 128000,
      maxTokens: m.top_provider?.max_completion_tokens ?? 4096,
    };
  });
}

// ---------------------------------------------------------------------------
// Provider registration
// ---------------------------------------------------------------------------

function registerProvider(pi: ExtensionAPI, models: Model[]): void {
  pi.registerProvider("openrouter", {
    baseUrl: "https://openrouter.ai/api/v1",
    apiKey: "$OPENROUTER_API_KEY",
    api: "openai-completions",
    compat: {
      thinkingFormat: "openrouter",
    },
    models,
  });
}

// ---------------------------------------------------------------------------
// Extension entry point
// ---------------------------------------------------------------------------

export default async function (pi: ExtensionAPI) {
  const apiKey = process.env.OPENROUTER_API_KEY;

  if (!apiKey) {
    console.warn("[openrouter-models] OPENROUTER_API_KEY not set, skipping dynamic model fetch");
    return;
  }

  const cached = readCache();
  let hadCache = false;

  if (cached) {
    hadCache = true;
    registerProvider(pi, cached.models);
    console.log(`[openrouter-models] Registered ${cached.models.length} models from cache`);
  }

  // Refresh if cache is missing or stale; skip if fresh cache exists
  if (!cached || isStale(cached)) {
    try {
      const fresh = await fetchModels(apiKey);
      writeCache(fresh);

      if (!hadCache) {
        registerProvider(pi, fresh);
        console.log(`[openrouter-models] Registered ${fresh.length} models from API`);
      } else {
        console.log(`[openrouter-models] Background refresh cached ${fresh.length} models`);
      }
    } catch (err) {
      console.warn(`[openrouter-models] Background fetch failed: ${err}`);
      if (!hadCache) {
        console.warn("[openrouter-models] No cache available — provider not registered");
      }
    }
  }
}
