import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default async function (pi: ExtensionAPI) {
  const apiKey = process.env.OPENROUTER_API_KEY;

  if (!apiKey) {
    console.warn("[openrouter-models] OPENROUTER_API_KEY not set, skipping dynamic model fetch");
    return;
  }

  let models: Array<{
    id: string;
    name: string;
    reasoning: boolean;
    input: string[];
    cost: { input: number; output: number; cacheRead: number; cacheWrite: number };
    contextWindow: number;
    maxTokens: number;
  }> = [];

  try {
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

    models = payload.data.map((m) => {
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
  } catch (err) {
    console.warn(`[openrouter-models] Failed to fetch models: ${err}`);
    return;
  }

  pi.registerProvider("openrouter", {
    baseUrl: "https://openrouter.ai/api/v1",
    apiKey: "OPENROUTER_API_KEY",
    api: "openai-completions",
    models,
  });
}
