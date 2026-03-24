import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  pi.registerProvider("openrouter", {
    baseUrl: "https://openrouter.ai/api/v1",
    apiKey: "OPENROUTER_API_KEY",
    api: "openai-completions",
    models: [
      {
        id: "anthropic/claude-sonnet-4.6",
        name: "Claude Sonnet 4.6",
        reasoning: true,
        input: ["text", "image"],
        cost: { input: 3, output: 15, cacheRead: 0.3, cacheWrite: 3.75 },
        contextWindow: 1000000,
        maxTokens: 128000,
      },
      {
        id: "anthropic/claude-opus-4.6",
        name: "Claude Opus 4.6",
        reasoning: true,
        input: ["text", "image"],
        cost: { input: 5, output: 25, cacheRead: 0.5, cacheWrite: 6.25 },
        contextWindow: 1000000,
        maxTokens: 128000,
      },
      {
        id: "anthropic/claude-haiku-4.5",
        name: "Claude Haiku 4.5",
        reasoning: true,
        input: ["text", "image"],
        cost: { input: 1, output: 5, cacheRead: 0.1, cacheWrite: 1.25 },
        contextWindow: 200000,
        maxTokens: 64000,
      },
      {
        id: "z-ai/glm-5",
        name: "GLM 5",
        reasoning: true,
        input: ["text"],
        cost: { input: 0.6, output: 1.9, cacheRead: 0.119, cacheWrite: 0 },
        contextWindow: 80000,
        maxTokens: 131072,
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
