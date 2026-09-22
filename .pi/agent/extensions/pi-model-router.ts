import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { pathToFileURL } from "node:url";
import { ROUTE_IDS, defaultConfig as baseDefaultConfig, hashPrompt, splitModelId } from "./pi-model-router-logic.mjs";
import { existsSync, readFileSync, mkdirSync, appendFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { homedir } from "node:os";

const CONFIG_PATH = join(homedir(), ".pi", "agent", "model-router.json");
const DEFAULT_LOG_PATH = join(homedir(), ".cache", "pi", "model-router.jsonl");
const TYPESAFE_MODULE = pathToFileURL(join(homedir(), ".pi", "agent", "npm", "node_modules", "pi-typesafe", "dist", "index.js")).href;
let typesafeModulePromise: Promise<any> | undefined;

async function getTypeSafeModule(): Promise<any> {
  typesafeModulePromise ??= import(TYPESAFE_MODULE);
  return typesafeModulePromise;
}

type RouteId = "fast" | "balanced" | "deep";
type RouterMode = "shadow" | "auto" | "off";

type RouterConfig = {
  mode: RouterMode;
  routes: Record<RouteId, string>;
  minConfidence: number;
  maxSwitchesPerSession: number;
  logFile?: string;
};

type RouteResult = {
  route: RouteId;
  modelId: string;
  probabilities: Record<string, number>;
  confidence: number;
  elapsedMs: number;
};

type RouterState = {
  config: RouterConfig;
  mode: RouterMode;
  switches: number;
  explicitModelChoice: boolean;
  applyingSwitch: boolean;
  validModels: Set<string>;
};

const ROUTE_CRITERIA = {
  fast: "Short factual answer, routine lookup, or small isolated edit where low latency matters.",
  balanced: "Normal coding, debugging, analysis, or multi-step work with ordinary ambiguity.",
  deep: "Complex architecture, difficult debugging, ambiguous requirements, or demanding reasoning.",
};

function defaultConfig(): RouterConfig {
  return { ...baseDefaultConfig(), logFile: DEFAULT_LOG_PATH };
}

function loadConfig(): RouterConfig {
  const fallback = defaultConfig();
  try {
    const parsed = JSON.parse(readFileSync(CONFIG_PATH, "utf8")) as Partial<RouterConfig>;
    const routes = parsed.routes as Partial<Record<RouteId, string>> | undefined;
    if (!routes || ROUTE_IDS.some((id) => typeof routes[id] !== "string" || !routes[id])) {
      throw new Error("routes must define fast, balanced, and deep");
    }
    const mode = parsed.mode ?? fallback.mode;
    const minConfidence = parsed.minConfidence ?? fallback.minConfidence;
    const maxSwitchesPerSession = parsed.maxSwitchesPerSession ?? fallback.maxSwitchesPerSession;
    if (!["shadow", "auto", "off"].includes(mode)) throw new Error("mode must be shadow, auto, or off");
    if (typeof minConfidence !== "number" || minConfidence < 0 || minConfidence > 1) throw new Error("minConfidence must be 0..1");
    if (!Number.isInteger(maxSwitchesPerSession) || maxSwitchesPerSession < 0) throw new Error("maxSwitchesPerSession must be a non-negative integer");
    return {
      mode,
      routes: routes as Record<RouteId, string>,
      minConfidence,
      maxSwitchesPerSession,
      logFile: parsed.logFile ?? fallback.logFile,
    };
  } catch (error) {
    console.warn(`[pi-model-router] Using defaults: ${error instanceof Error ? error.message : String(error)}`);
    return fallback;
  }
}

function logPath(config: RouterConfig): string {
  return (config.logFile ?? DEFAULT_LOG_PATH).replace(/^~/, homedir());
}

function logDecision(config: RouterConfig, record: Record<string, unknown>): void {
  try {
    const path = logPath(config);
    mkdirSync(dirname(path), { recursive: true });
    appendFileSync(path, `${JSON.stringify({ timestamp: new Date().toISOString(), ...record })}\n`, { mode: 0o600 });
  } catch (error) {
    console.warn(`[pi-model-router] Could not write log: ${error instanceof Error ? error.message : String(error)}`);
  }
}

function currentModelId(ctx: ExtensionContext): string {
  return ctx.model ? `${ctx.model.provider}/${ctx.model.id}` : "none";
}

function isScoped(ctx: ExtensionContext, modelId: string): boolean {
  if (ctx.scopedModels.length === 0) return true;
  return ctx.scopedModels.some(({ model }) => `${model.provider}/${model.id}` === modelId);
}

function routeText(result: RouteResult): string {
  const probabilities = Object.entries(result.probabilities)
    .map(([route, probability]) => `${route} ${(probability * 100).toFixed(1)}%`)
    .join(", ");
  return `${result.route} → ${result.modelId} (confidence ${(result.confidence * 100).toFixed(1)}%; ${probabilities})`;
}

async function judge(prompt: string, currentModel: string): Promise<RouteResult> {
  const { ask, choice, createTypeSafe } = await getTypeSafeModule();
  const typesafe = createTypeSafe({ maxRequests: 20 });
  const started = Date.now();
  const answer = await ask(typesafe, {
    state: {
      task: prompt,
      currentModel,
      routes: Object.fromEntries(ROUTE_IDS.map((id) => [id, ROUTE_CRITERIA[id]])),
    },
    questions: {
      route: choice("Which route best fits `task`? Choose based on task demands, not model reputation. `currentModel` is context only.", ROUTE_CRITERIA),
    },
  }, { timeoutMs: 5000 });
  if (!answer.ok) throw new Error(answer.error);
  const routeAnswer = answer.answers.route;
  return {
    route: routeAnswer.choice as RouteId,
    modelId: "",
    probabilities: routeAnswer.probabilities,
    confidence: routeAnswer.confidence,
    elapsedMs: Date.now() - started,
  };
}

function resolveRoute(ctx: ExtensionContext, config: RouterConfig, route: RouteId): { modelId: string; model: NonNullable<ExtensionContext["model"]> } | null {
  const modelId = config.routes[route];
  if (!isScoped(ctx, modelId)) return null;
  const { provider, id } = splitModelId(modelId);
  const model = ctx.modelRegistry.find(provider, id);
  return model ? { modelId, model } : null;
}

function validateModels(ctx: ExtensionContext, state: RouterState): void {
  state.validModels.clear();
  for (const route of ROUTE_IDS) {
    const resolved = resolveRoute(ctx, state.config, route);
    if (resolved) state.validModels.add(resolved.modelId);
    else ctx.ui.notify(`Router route unavailable or out of scope: ${route} → ${state.config.routes[route]}`, "warning");
  }
}

async function evaluateAndHandle(
  prompt: string,
  ctx: ExtensionContext,
  state: RouterState,
  applySwitch: boolean,
  notify: boolean,
  setModel: (model: NonNullable<ExtensionContext["model"]>) => Promise<boolean>,
): Promise<RouteResult | null> {
  if (!prompt.trim() || state.mode === "off") return null;
  const current = currentModelId(ctx);
  try {
    const result = await judge(prompt, current);
    const resolved = resolveRoute(ctx, state.config, result.route);
    result.modelId = state.config.routes[result.route];
    if (!resolved) {
      logDecision(state.config, { promptHash: hashPrompt(prompt), currentModel: current, ...result, applied: false, reason: "route-unavailable" });
      if (notify) ctx.ui.notify(`Router skipped: ${result.route} model unavailable`, "warning");
      return result;
    }

    let reason = state.mode === "shadow" ? "shadow-mode" : "not-applied";
    let applied = false;
    if (applySwitch && state.mode === "auto") {
      if (state.explicitModelChoice) reason = "explicit-model-choice";
      else if (result.confidence < state.config.minConfidence) reason = "below-confidence-threshold";
      else if (state.switches >= state.config.maxSwitchesPerSession) reason = "switch-limit";
      else if (current === resolved.modelId) reason = "already-active";
      else if (!state.validModels.has(resolved.modelId)) reason = "model-not-validated";
      else {
        state.applyingSwitch = true;
        try {
          applied = await setModel(resolved.model);
          reason = applied ? "switched" : "authentication-unavailable";
          if (applied) state.switches += 1;
        } finally {
          state.applyingSwitch = false;
        }
      }
    }
    logDecision(state.config, { promptHash: hashPrompt(prompt), currentModel: current, ...result, applied, reason });
    if (notify) ctx.ui.notify(`Router: ${routeText(result)}${applied ? " [switched]" : ` [${reason}]`}`, "info");
    return result;
  } catch (error) {
    logDecision(state.config, { promptHash: hashPrompt(prompt), currentModel: current, applied: false, reason: "jev-error" });
    if (notify) ctx.ui.notify(`Router skipped: ${error instanceof Error ? error.message : String(error)}`, "warning");
    return null;
  }
}

export default function (pi: ExtensionAPI) {
  const state: RouterState = {
    config: loadConfig(),
    mode: "shadow",
    switches: 0,
    explicitModelChoice: false,
    applyingSwitch: false,
    validModels: new Set(),
  };
  state.mode = state.config.mode;

  pi.on("session_start", async (_event, ctx) => {
    state.config = loadConfig();
    state.mode = state.config.mode;
    state.switches = 0;
    state.explicitModelChoice = false;
    validateModels(ctx, state);
    ctx.ui.setStatus("pi-model-router", `router: ${state.mode}`);
  });

  pi.on("model_select", (event, _ctx) => {
    if (!state.applyingSwitch && (event.source === "set" || event.source === "cycle")) state.explicitModelChoice = true;
  });

  pi.registerCommand("route", {
    description: "Ask Jev which configured model route best fits a task (no model switch)",
    handler: async (args, ctx) => {
      const prompt = args.trim();
      if (!prompt) {
        ctx.ui.notify("Usage: /route <task description>", "warning");
        return;
      }
      const previousMode = state.mode;
      state.mode = "shadow";
      await evaluateAndHandle(prompt, ctx, state, false, true, (model) => pi.setModel(model));
      state.mode = previousMode;
    },
  });

  pi.registerCommand("router", {
    description: "Set router mode: shadow, auto, or off",
    handler: async (args, ctx) => {
      const mode = args.trim() as RouterMode;
      if (!["shadow", "auto", "off"].includes(mode)) {
        ctx.ui.notify(`Usage: /router ${state.mode === "auto" ? "shadow" : "auto|shadow|off"}`, "warning");
        return;
      }
      state.mode = mode;
      state.switches = 0;
      ctx.ui.setStatus("pi-model-router", `router: ${mode}`);
      ctx.ui.notify(`Model router: ${mode}`, "info");
    },
  });

  pi.on("input", async (event, ctx) => {
    if (event.source === "extension" || event.streamingBehavior || event.text.startsWith("/")) return { action: "continue" as const };
    if (!event.text.trim() || state.mode === "off") return { action: "continue" as const };
    const explicitChoice = state.explicitModelChoice;
    state.explicitModelChoice = false;
    await evaluateAndHandle(event.text, ctx, state, true, true, (model) => pi.setModel(model));
    if (explicitChoice) state.explicitModelChoice = true;
    return { action: "continue" as const };
  });
}
