import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  pi.registerProvider("openrouter", {
    baseUrl: "https://openrouter.ai/api/v1",
    apiKey: "OPENROUTER_API_KEY",
    api: "openai-completions",
    models: [
      {
        id: "z-ai/glm-5.1",
        name: "GLM 5.1",
        reasoning: true,
        input: ["text"],
        cost: { input: 0.95, output: 3.5, cacheRead: 0.475, cacheWrite: 0 },
        contextWindow: 202800,
        maxTokens: 65000,
      },
      {
        id: "minimax/minimax-m2.7",
        name: "MiniMax M2.7",
        reasoning: true,
        input: ["text"],
        cost: { input: 0.3, output: 1.2, cacheRead: 0.06, cacheWrite: 0 },
        contextWindow: 204800,
        maxTokens: 131072,
      },
      {
        id: "qwen/qwen3-coder-next",
        name: "Qwen3 Coder Next",
        reasoning: false,
        input: ["text"],
        cost: { input: 0.12, output: 0.75, cacheRead: 0.06, cacheWrite: 0 },
        contextWindow: 262144,
        maxTokens: 65536,
      },
    ],
  });
}
