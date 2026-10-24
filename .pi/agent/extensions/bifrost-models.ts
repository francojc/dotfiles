import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { execFileSync } from "node:child_process";
import { existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { join } from "node:path";

// ---------------------------------------------------------------------------
// Bifrost gateway model discovery
//
// Bifrost serves GET <baseUrl>/models. Documented payload is OpenRouter-shaped
// (context_length, max_output_tokens, architecture.input_modalities,
// reasoning.supported_efforts, per-token pricing strings); observed payload for
// Bifrost 1.3.x is sparser: id, normalized_name, created, owned_by, pricing, and
// context_length / max_input_tokens / max_output_tokens on only a few entries.
// No name, architecture, reasoning, or supported_methods. Missing fields come
// from the override file, which is generated from https://models.dev.
//
// Pi pulls that catalog at startup, on /model, and on `pi update --models`,
// through ProviderConfig.refreshModels. A disk cache keeps the provider usable
// offline and when the gateway is down.
//
// Config:
//   BIFROST_BASE_URL          base URL including /v1 (default below)
//   BIFROST_VK                literal virtual key (overrides the pass entry)
//   BIFROST_VK_FILE           file holding the virtual key
//   BIFROST_VK_PASS           pass entry name (default API/BIFROST_VK)
//   BIFROST_MODEL_OVERRIDES   JSON file patching model metadata (default below)
//
// Observed 2026-10: the VK in `pass show API/BIFROST_VK` exposes only the
// opencode-zen provider (85 models). Mint a broader VK to see the rest.
// ---------------------------------------------------------------------------

const BASE_URL = process.env.BIFROST_BASE_URL ?? "https://bifrost.gerbil-matrix.ts.net/v1";
const VK_FILE = process.env.BIFROST_VK_FILE;
const VK_PASS = process.env.BIFROST_VK_PASS ?? "API/BIFROST_VK";
const HOME = process.env.HOME ?? "/tmp";
const CACHE_FILE = join(HOME, ".cache", "pi", "bifrost-models.json");
const OVERRIDES_FILE = process.env.BIFROST_MODEL_OVERRIDES ?? join(HOME, ".config", "bifrost-gateway", "model-overrides.json");
const CACHE_TTL_MS = 6 * 60 * 60 * 1000;
const QUIET = process.argv.includes("-p") || process.argv.includes("--print") || process.argv.includes("json");

type ChatModelCompat = {
  supportsDeveloperRole?: boolean;
  supportsReasoningEffort?: boolean;
  thinkingFormat?: string;
  requiresReasoningContentOnAssistantMessages?: boolean;
  maxTokensField?: "max_tokens" | "max_completion_tokens";
};

type ChatModel = {
  type: "chat";
  id: string;
  name: string;
  reasoning: boolean;
  thinkingLevelMap?: Record<string, string | null>;
  input: Array<"text" | "image">;
  cost: { input: number; output: number; cacheRead: number; cacheWrite: number };
  contextWindow: number;
  maxTokens: number;
  compat?: ChatModelCompat;
};

type CacheEntry = { fetchedAt: number; baseUrl: string; models: ChatModel[] };

type BifrostModel = {
  id?: string;
  name?: string;
  normalized_name?: string;
  canonical_slug?: string;
  context_length?: number;
  max_input_tokens?: number;
  max_output_tokens?: number;
  architecture?: { input_modalities?: string[]; output_modalities?: string[] };
  pricing?: {
    prompt?: string;
    completion?: string;
    input_cache_read?: string;
    input_cache_write?: string;
  };
  reasoning?: { default_enabled?: boolean; supported_efforts?: string[] };
  supported_methods?: string[];
  top_provider?: { max_completion_tokens?: number };
};

type ChatModelPatch = Partial<
  Pick<ChatModel, "name" | "reasoning" | "thinkingLevelMap" | "input" | "contextWindow" | "maxTokens">
> & {
  cost?: Partial<ChatModel["cost"]>;
  compat?: ChatModelCompat;
  /** Set by the generator when a protocol probe showed the gateway cannot serve the model. */
  unreachable?: boolean;
};

function logInfo(message: string): void {
  if (!QUIET) console.log(message);
}

function logWarn(message: string): void {
  if (!QUIET) console.warn(message);
}

// ---------------------------------------------------------------------------
// Credentials
// ---------------------------------------------------------------------------

function vkSpec(): string {
  if (process.env.BIFROST_VK) return "$BIFROST_VK";
  if (VK_FILE) return `!/bin/cat ${VK_FILE}`;
  return `!pass show ${VK_PASS}`;
}

let cachedVk: string | undefined;

/** Resolve the virtual key for the catalog request, memoized for this run. */
function resolveVk(credentialKey?: string): string | undefined {
  if (process.env.BIFROST_VK) return process.env.BIFROST_VK;
  if (cachedVk) return cachedVk;

  try {
    if (VK_FILE) {
      cachedVk = readFileSync(VK_FILE, "utf-8").trim();
    } else {
      cachedVk = execFileSync("pass", ["show", VK_PASS], { encoding: "utf-8" }).trim().split("\n")[0];
    }
  } catch (err) {
    logWarn(`[bifrost-models] could not read virtual key from pass (${VK_PASS}): ${String(err).split("\n")[0]}`);
    return credentialKey;
  }

  return cachedVk || undefined;
}

// ---------------------------------------------------------------------------
// Cache
// ---------------------------------------------------------------------------

function readCache(): CacheEntry | null {
  try {
    if (!existsSync(CACHE_FILE)) return null;
    const entry = JSON.parse(readFileSync(CACHE_FILE, "utf-8")) as CacheEntry;
    return entry.baseUrl === BASE_URL ? entry : null;
  } catch {
    return null;
  }
}

function writeCache(models: ChatModel[]): void {
  try {
    mkdirSync(join(CACHE_FILE, ".."), { recursive: true });
    writeFileSync(CACHE_FILE, JSON.stringify({ fetchedAt: Date.now(), baseUrl: BASE_URL, models }, null, 2));
  } catch (err) {
    logWarn(`[bifrost-models] cache write failed: ${err}`);
  }
}

function isStale(entry: CacheEntry): boolean {
  return Date.now() - entry.fetchedAt > CACHE_TTL_MS;
}

// ---------------------------------------------------------------------------
// Mapping
// ---------------------------------------------------------------------------

// Pi thinking levels, ordered by increasing effort.
const PI_LEVELS = ["minimal", "low", "medium", "high", "xhigh", "max"] as const;

/** Map each pi thinking level to the closest effort the model actually accepts. */
function buildThinkingLevelMap(efforts: string[]): Record<string, string | null> | undefined {
  const offered = new Set(efforts.map((effort) => effort.toLowerCase()));
  if (offered.size === 0) return undefined;
  const map: Record<string, string | null> = {};
  for (const level of PI_LEVELS) {
    const candidates =
      level === "minimal"
        ? ["minimal", "low", "medium"]
        : level === "xhigh" || level === "max"
          ? ["max", "xhigh", "high", "medium"]
          : [level, "medium", "low", "high"];
    const match = candidates.find((candidate) => offered.has(candidate));
    map[level] = match ?? null;
  }
  return map;
}

function perMillionUsd(value: string | undefined): number {
  // WARN: Bifrost documents OpenRouter-shaped pricing, which is per-token USD
  // in a decimal string. Verify against a known model before trusting totals.
  const parsed = Number.parseFloat(value ?? "0");
  return Number.isFinite(parsed) && parsed > 0 ? Number((parsed * 1_000_000).toFixed(6)) : 0;
}

function isChatModel(model: BifrostModel): boolean {
  if (model.supported_methods?.length) {
    return model.supported_methods.some((method) => method.toLowerCase().startsWith("chat"));
  }
  return !/embed|whisper|\btts\b|dall-e|moderation/i.test(model.id ?? "");
}

function toChatModel(model: BifrostModel): ChatModel | null {
  const id = model.id?.trim();
  if (!id || !isChatModel(model)) return null;

  const modalities = model.architecture?.input_modalities ?? ["text"];
  const input: Array<"text" | "image"> = modalities.some((modality) => modality === "image")
    ? ["text", "image"]
    : ["text"];

  const efforts = model.reasoning?.supported_efforts ?? [];
  const reasoning = model.reasoning?.default_enabled === true || efforts.length > 0;

  return {
    type: "chat",
    id,
    name: model.name ?? model.normalized_name ?? model.canonical_slug ?? id,
    reasoning,
    ...(reasoning && efforts.length > 0 ? { thinkingLevelMap: buildThinkingLevelMap(efforts) } : {}),
    input,
    cost: {
      input: perMillionUsd(model.pricing?.prompt),
      output: perMillionUsd(model.pricing?.completion),
      cacheRead: perMillionUsd(model.pricing?.input_cache_read),
      cacheWrite: perMillionUsd(model.pricing?.input_cache_write),
    },
    contextWindow: model.context_length ?? model.max_input_tokens ?? 128_000,
    maxTokens: model.max_output_tokens ?? model.top_provider?.max_completion_tokens ?? 8_192,
  };
}

// ---------------------------------------------------------------------------
// Manual overrides
//
// The gateway omits context, output limits, and reasoning for most entries, so
// patches fill the gaps. Keys match an exact model ID, a bare model name
// (prefix-independent), a `prefix*` pattern, or a `*suffix` pattern. Exact
// matches win. Keys starting with "//" are comments: JSON has no comment syntax,
// so the generator records provenance there and the loader skips it. Example:
//   {
//     "claude-sonnet-5":    { "contextWindow": 300000 },
//     "opencode-zen/glm-*": { "maxTokens": 128000 }
//   }
// ---------------------------------------------------------------------------

function readOverrides(): Record<string, ChatModelPatch> {
  try {
    if (!existsSync(OVERRIDES_FILE)) return {};
    const parsed = JSON.parse(readFileSync(OVERRIDES_FILE, "utf-8")) as Record<string, unknown>;
    // JSON has no comments, so the generator writes its provenance under "//".
    // Ignore that key and any other non-object entry instead of treating it as a patch.
    const patches: Record<string, ChatModelPatch> = {};
    for (const [pattern, patch] of Object.entries(parsed)) {
      if (pattern.startsWith("//")) continue;
      if (typeof patch !== "object" || patch === null || Array.isArray(patch)) continue;
      patches[pattern] = patch as ChatModelPatch;
    }
    return patches;
  } catch (err) {
    logWarn(`[bifrost-models] ignoring ${OVERRIDES_FILE}: ${err}`);
    return {};
  }
}

function patchMatches(pattern: string, id: string): boolean {
  if (pattern === id) return true;
  // "*suffix" matches the end of the ID; a bare name matches the last path segment,
  // so patches survive a change in the gateway's provider prefix.
  if (pattern.startsWith("*")) return id.endsWith(pattern.slice(1));
  if (!pattern.includes("/")) return id.split("/").pop() === pattern;
  if (pattern.endsWith("*")) return id.startsWith(pattern.slice(0, -1));
  return false;
}

function patchSpecificity(pattern: string, id: string): number {
  if (pattern === id) return 3;
  if (pattern.startsWith("*") || !pattern.includes("/")) return 2;
  return 1;
}

function applyOverrides(model: ChatModel, overrides: Record<string, ChatModelPatch>): ChatModel {
  const merged = patchModel(model, overrides);
  const { unreachable: _unreachable, ...clean } = merged;
  return clean as ChatModel;
}

function patchModel(model: ChatModel, overrides: Record<string, ChatModelPatch>): ChatModelPatch & ChatModel {
  const matched = Object.entries(overrides).filter(([pattern]) => patchMatches(pattern, model.id));
  if (matched.length === 0) return model;
  // Narrowest pattern first, most specific last, so it wins.
  matched.sort(([a], [b]) => patchSpecificity(a, model.id) - patchSpecificity(b, model.id));
  return matched.reduce<ChatModelPatch & ChatModel>((merged, [, patch]) => {
    const { cost, ...rest } = patch;
    return { ...merged, ...rest, cost: { ...merged.cost, ...(cost ?? {}) } };
  }, model);
}

// ---------------------------------------------------------------------------
// Fetch
// ---------------------------------------------------------------------------

async function fetchModels(vk: string | undefined, signal: AbortSignal): Promise<ChatModel[]> {
  const models: ChatModel[] = [];
  let nextPage: string | undefined;

  // Bifrost paginates with next_page_token; cap the walk so a misbehaving
  // gateway cannot loop forever.
  for (let page = 0; page < 20; page++) {
    const url = new URL(`${BASE_URL}/models`);
    if (nextPage) url.searchParams.set("next_page_token", nextPage);

    const response = await fetch(url, {
      headers: { accept: "application/json", ...(vk ? { "x-bf-vk": vk } : {}) },
      signal,
    });
    if (!response.ok) {
      const body = await response.text().catch(() => "");
      throw new Error(`HTTP ${response.status}${body ? `: ${body.slice(0, 200)}` : ""}`);
    }

    const payload = (await response.json()) as { data?: BifrostModel[]; next_page_token?: string };
    for (const entry of payload.data ?? []) {
      const mapped = toChatModel(entry);
      if (mapped) models.push(mapped);
    }
    if (!payload.next_page_token) break;
    nextPage = payload.next_page_token;
  }

  if (models.length === 0) throw new Error("gateway returned no chat models");
  return models;
}

/** Cache holds gateway metadata only, so override edits apply without a refetch. */
function patched(models: ChatModel[]): ChatModel[] {
  const overrides = readOverrides();
  if (Object.keys(overrides).length === 0) return models;
  return models
    .filter((model) => patchModel(model, overrides).unreachable !== true)
    .map((model) => applyOverrides(model, overrides));
}

// ---------------------------------------------------------------------------
// Registration
// ---------------------------------------------------------------------------

let warnedNoKey = false;

export default function (pi: ExtensionAPI) {
  const cached = readCache();
  const spec = vkSpec();

  pi.registerProvider("bifrost", {
    name: "Bifrost",
    baseUrl: BASE_URL,
    api: "openai-completions",
    // Pi lists models only for providers with usable auth. The key resolves at
    // request time from BIFROST_VK, BIFROST_VK_FILE, or `pass show API/BIFROST_VK`.
    apiKey: spec,
    authHeader: true,
    headers: { "x-bf-vk": spec },
    models: cached ? patched(cached.models) : [],
    refreshModels: async (ctx) => {
      const current = readCache();
      const fallback = patched(current?.models ?? []);
      const vk = resolveVk(ctx.credential?.type === "api_key" ? ctx.credential.key : undefined);

      if (!vk) {
        if (!warnedNoKey) {
          warnedNoKey = true;
          logWarn("[bifrost-models] no virtual key resolved; serving cached catalog");
        }
        return fallback;
      }
      if (!ctx.allowNetwork || ctx.signal.aborted) return fallback;
      if (!ctx.force && current && !isStale(current)) return patched(current.models);

      try {
        const models = await fetchModels(vk, ctx.signal);
        writeCache(models);
        logInfo(`[bifrost-models] ${models.length} models from ${BASE_URL}`);
        return patched(models);
      } catch (err) {
        logWarn(`[bifrost-models] refresh failed (${err}); serving ${fallback.length} cached models`);
        return fallback;
      }
    },
  });

  if (cached) logInfo(`[bifrost-models] ${cached.models.length} models from cache`);
}
