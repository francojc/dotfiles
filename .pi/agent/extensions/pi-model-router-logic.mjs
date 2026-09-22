import { createHash } from "node:crypto";

export const ROUTE_IDS = ["fast", "balanced", "deep"];

export function defaultConfig() {
  return {
    mode: "shadow",
    routes: {
      fast: "opencode/deepseek-v4.1-flash",
      balanced: "opencode/glm-5.3",
      deep: "openai-codex/gpt-6-astra",
    },
    minConfidence: 0.6,
    maxSwitchesPerSession: 5,
  };
}

export function splitModelId(modelId) {
  const separator = modelId.indexOf("/");
  if (separator <= 0 || separator === modelId.length - 1) throw new Error(`Invalid model ID: ${modelId}`);
  return { provider: modelId.slice(0, separator), id: modelId.slice(separator + 1) };
}

export function hashPrompt(prompt) {
  return createHash("sha256").update(prompt).digest("hex").slice(0, 16);
}
