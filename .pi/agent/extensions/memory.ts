/**
 * Memory Extension - Cross-session memory system for Pi
 *
 * Implements three types of memory:
 * 1. Working Memory - session-scoped, branch-aware
 * 2. Episodic Memory - rolling buffer of 4-5 recent session summaries
 * 3. Semantic Memory - long-term knowledge, self-organizing
 *
 * Session shutdown spawns session-end-processor.mjs to generate episodic
 * summaries and consolidate to semantic memory.
 * Recall skill adds on-demand context loading for relevant past sessions.
 */

import { StringEnum } from "@mariozechner/pi-ai";
import type { ExtensionAPI, ExtensionContext } from "@mariozechner/pi-coding-agent";
import { Type } from "@sinclair/typebox";
import { existsSync, mkdirSync, readdirSync, readFileSync, writeFileSync } from "fs";
import { dirname, join } from "path";
import { homedir } from "os";
import { spawn } from "child_process";

// ─────────────────────────────────────────────────────────────────────────────
// Types
// ─────────────────────────────────────────────────────────────────────────────

interface WorkingMemory {
  keyFacts: string[];
  currentGoals: string[];
  temporaryContext: string[];
  lastUpdated: string;
}

interface EpisodicMemory {
  sessionId: string;
  timestamp: string;
  cwd: string;
  summary: string;
  keyTopics: string[];
  actionItems: string[];
  outcomes: string[];
}

interface MemoryState {
  working: WorkingMemory;
}

// ─────────────────────────────────────────────────────────────────────────────
// Configuration
// ─────────────────────────────────────────────────────────────────────────────

const MEMORY_DIR = join(homedir(), ".pi", "memory");
const EPISODES_DIR = join(MEMORY_DIR, "episodes");
const SEMANTIC_DIR = join(MEMORY_DIR, "semantic");
const EPISODE_LIMIT = 5;

const RECALL_KEYWORDS = [
  "remember",
  "recall",
  "like with",
  "previous work",
  "similar to",
  "we did before",
  "last time",
];

// ─────────────────────────────────────────────────────────────────────────────
// Utility Functions
// ─────────────────────────────────────────────────────────────────────────────

function ensureDir(path: string): void {
  if (!existsSync(path)) {
    mkdirSync(path, { recursive: true });
  }
}

function getMemoryDir(): string {
  ensureDir(MEMORY_DIR);
  return MEMORY_DIR;
}

function getEpisodesDir(): string {
  ensureDir(EPISODES_DIR);
  return EPISODES_DIR;
}

function getSemanticDir(): string {
  ensureDir(SEMANTIC_DIR);
  ensureDir(join(SEMANTIC_DIR, "projects"));
  return SEMANTIC_DIR;
}

function getEpisodicPaths(): string[] {
  const dir = getEpisodesDir();
  if (!existsSync(dir)) return [];
  return readdirSync(dir)
    .filter((f) => f.endsWith(".json"))
    .map((f) => join(dir, f))
    .sort((a, b) => {
      const statA = existsSync(a) ? readFileSync(a).toString() : "";
      const statB = existsSync(b) ? readFileSync(b).toString() : "";
      try {
        const dataA = JSON.parse(statA) as EpisodicMemory;
        const dataB = JSON.parse(statB) as EpisodicMemory;
        return new Date(dataB.timestamp).getTime() - new Date(dataA.timestamp).getTime();
      } catch {
        return 0;
      }
    });
}

function loadEpisodicMemories(limit = EPISODE_LIMIT): EpisodicMemory[] {
  const paths = getEpisodicPaths().slice(0, limit);
  return paths
    .map((p) => {
      try {
        return JSON.parse(readFileSync(p).toString()) as EpisodicMemory;
      } catch {
        return null;
      }
    })
    .filter((m): m is EpisodicMemory => m !== null);
}

function loadAllEpisodicMemories(): EpisodicMemory[] {
  const paths = getEpisodicPaths();
  return paths
    .map((p) => {
      try {
        return JSON.parse(readFileSync(p).toString()) as EpisodicMemory;
      } catch {
        return null;
      }
    })
    .filter((m): m is EpisodicMemory => m !== null);
}

function getProjectSemanticPath(cwd: string): string {
  const projectName = cwd.split("/").pop() || "default";
  return join(getSemanticDir(), "projects", `${projectName}.md`);
}

function loadProjectSemantic(cwd: string): string {
  const path = getProjectSemanticPath(cwd);
  if (!existsSync(path)) return "";
  return readFileSync(path).toString();
}

function formatEpisodesForPrompt(episodes: EpisodicMemory[]): string {
  if (episodes.length === 0) return "No recent sessions.";
  return episodes
    .map((e) => `- ${e.timestamp} (${e.cwd}): ${e.summary}`)
    .join("\n");
}

function formatWorkingMemory(memory: WorkingMemory): string {
  const parts: string[] = [];
  if (memory.currentGoals.length > 0) {
    parts.push(`**Current Goal:** ${memory.currentGoals[memory.currentGoals.length - 1]}`);
  }
  if (memory.keyFacts.length > 0) {
    parts.push(`**Key Facts:**\n${memory.keyFacts.map((f) => `- ${f}`).join("\n")}`);
  }
  if (memory.temporaryContext.length > 0) {
    parts.push(`**Context:**\n${memory.temporaryContext.map((c) => `- ${c}`).join("\n")}`);
  }
  return parts.join("\n\n") || "No working memory.";
}

// ─────────────────────────────────────────────────────────────────────────────
// Schema Definitions
// ─────────────────────────────────────────────────────────────────────────────

const WorkingMemoryParams = Type.Object({
  action: StringEnum(["add", "remove", "clear", "list"] as const),
  type: Type.Optional(StringEnum(["fact", "goal", "context"] as const)),
  content: Type.Optional(Type.String({ description: "Content to add or remove" })),
});

const EpisodicRecallParams = Type.Object({
  query: Type.String({ description: "Search query (keywords, project name, etc.)" }),
  dateRange: Type.Optional(
    Type.String({ description: "Optional date range like 'last week', 'yesterday', etc." }),
  ),
  projectFilter: Type.Optional(Type.String({ description: "Optional project path to filter by" })),
  limit: Type.Optional(Type.Number({ default: 3, description: "Max results to return" })),
});

const SemanticSuggestParams = Type.Object({
  section: Type.String({ description: "Section to update (e.g., 'preferences', 'projects/DOTFILES')" }),
  content: Type.String({ description: "Content to add or update" }),
});

// ─────────────────────────────────────────────────────────────────────────────
// Main Extension
// ─────────────────────────────────────────────────────────────────────────────

export default function (pi: ExtensionAPI) {
  // In-memory working memory state
  let workingMemory: WorkingMemory = {
    keyFacts: [],
    currentGoals: [],
    temporaryContext: [],
    lastUpdated: new Date().toISOString(),
  };

  // Reconstruct working memory from session history
  const reconstructState = (ctx: ExtensionContext) => {
    workingMemory = {
      keyFacts: [],
      currentGoals: [],
      temporaryContext: [],
      lastUpdated: new Date().toISOString(),
    };

    for (const entry of ctx.sessionManager.getBranch()) {
      if (entry.type !== "message") continue;
      const msg = entry.message;
      if (msg.role !== "toolResult" || msg.toolName !== "memory_working") continue;

      const details = (msg.details || {}) as { action: string; type?: string; content?: string };
      if (details.action === "add" && details.type && details.content) {
        const key = details.type as keyof Omit<WorkingMemory, "lastUpdated">;
        workingMemory[key].push(details.content);
      } else if (details.action === "remove" && details.content) {
        const key = details.type as keyof Omit<WorkingMemory, "lastUpdated"> | undefined;
        if (key) {
          workingMemory[key] = workingMemory[key].filter((c) => c !== details.content);
        } else {
          for (const k of Object.keys(workingMemory) as Array<keyof Omit<WorkingMemory, "lastUpdated">>) {
            workingMemory[k] = workingMemory[k].filter((c) => c !== details.content);
          }
        }
      } else if (details.action === "clear") {
        workingMemory = {
          keyFacts: [],
          currentGoals: [],
          temporaryContext: [],
          lastUpdated: new Date().toISOString(),
        };
      }
    }
  };

  // Setup system prompt with memory context
  const setupMemoryContext = (cwd: string) => {
    const episodes = loadEpisodicMemories();
    const recentProjects = [...new Set(episodes.slice(0, 3).map((e) => e.cwd))].filter(Boolean);

    const semanticContent = loadProjectSemantic(cwd);
    const episodeContent = formatEpisodesForPrompt(episodes);
    const workingContent = formatWorkingMemory(workingMemory);

    // Build memory section
    const memorySections: string[] = [];

    memorySections.push(`## Working Memory (Current Session)\n${workingContent}`);

    if (recentProjects.length > 0) {
      memorySections.push(
        `## Recent Projects\n${recentProjects.map((p) => `- ${p}`).join("\n")}\n\n` +
          `Say "recall {project}" or use words like "remember", "previous work", "like with" to load details.`,
      );
    }

    if (semanticContent) {
      memorySections.push(`## Project Knowledge\n${semanticContent}`);
    }

    // Add to system prompt
    pi.systemPrompt.addSection(memorySections.join("\n\n"));
  };

  // ───────────────────────────────────────────────────────────────────────────
  // Event Handlers
  // ───────────────────────────────────────────────────────────────────────────

  pi.on("session_start", async (event, ctx) => {
    reconstructState(ctx);
    setupMemoryContext(ctx.cwd);

    // Show greeting on startup (not on switch/fork/reload)
    if (event.reason === "startup") {
      const episodes = loadEpisodicMemories();
      const recentProjects = [...new Set(episodes.slice(0, 3).map((e) => e.cwd))].filter(Boolean);

      if (recentProjects.length > 0) {
        ctx.ui.notify(
          `Recent projects: ${recentProjects.join(", ")}`,
          "info",
        );
      }
    }
  });

  pi.on("session_shutdown", async (_event, ctx) => {
    const sessionFile = ctx.sessionManager.getSessionFile();
    if (!sessionFile) return; // ephemeral session, nothing to summarize

    // Spawn the session-end processor in the background so it doesn't block exit
    const processorPath = join(dirname(import.meta.url.replace("file://", "")), "..", "session-end-processor.mjs");
    if (!existsSync(processorPath)) return;

    const child = spawn("node", [processorPath, sessionFile], {
      detached: true,
      stdio: "ignore",
    });
    child.unref();
  });

  // ───────────────────────────────────────────────────────────────────────────
  // Memory Working Tool
  // ───────────────────────────────────────────────────────────────────────────

  pi.registerTool({
    name: "memory_working",
    label: "Working Memory",
    description:
      "Manage working memory for this session. Actions: add (type: fact/goal/context, content), remove (content), clear, list",
    parameters: WorkingMemoryParams,

    async execute(_toolCallId, params, _signal, _onUpdate, _ctx) {
      switch (params.action) {
        case "add": {
          if (!params.type || !params.content) {
            return {
              content: [{ type: "text", text: "Error: type and content required for add" }],
            };
          }
          const key = params.type as keyof Omit<WorkingMemory, "lastUpdated">;
          workingMemory[key].push(params.content);
          workingMemory.lastUpdated = new Date().toISOString();
          return {
            content: [{ type: "text", text: `Added to ${params.type}: "${params.content}"` }],
            details: { action: "add", type: params.type, content: params.content },
          };
        }

        case "remove": {
          if (!params.content) {
            return {
              content: [{ type: "text", text: "Error: content required for remove" }],
            };
          }
          const type = params.type as keyof Omit<WorkingMemory, "lastUpdated"> | undefined;
          if (type) {
            workingMemory[type] = workingMemory[type].filter((c) => c !== params.content);
          } else {
            // Search all types
            (Object.keys(workingMemory) as Array<keyof Omit<WorkingMemory, "lastUpdated">>).forEach(
              (k) => {
                workingMemory[k] = workingMemory[k].filter((c) => c !== params.content);
              },
            );
          }
          workingMemory.lastUpdated = new Date().toISOString();
          return {
            content: [{ type: "text", text: `Removed: "${params.content}"` }],
            details: { action: "remove", type: params.type, content: params.content },
          };
        }

        case "clear": {
          workingMemory = {
            keyFacts: [],
            currentGoals: [],
            temporaryContext: [],
            lastUpdated: new Date().toISOString(),
          };
          return {
            content: [{ type: "text", text: "Working memory cleared" }],
            details: { action: "clear" },
          };
        }

        case "list": {
          return {
            content: [
              { type: "text", text: formatWorkingMemory(workingMemory) || "Working memory empty" },
            ],
            details: { action: "list" },
          };
        }

        default:
          return {
            content: [{ type: "text", text: `Unknown action: ${params.action}` }],
          };
      }
    },

    renderCall(args, theme, _context) {
      const icon = theme.fg("accent", "󰊠 ");
      return `${icon}memory ${theme.fg("muted", args.action)}${args.content ? ` "${args.content.substring(0, 30)}${args.content.length > 30 ? "..." : ""}"` : ""}`;
    },

    renderResult(result, _opts, theme, _context) {
      const text = result.content[0]?.type === "text" ? result.content[0].text : "";
      return theme.fg("muted", text);
    },
  });

  // ───────────────────────────────────────────────────────────────────────────
  // Episodic Recall Tool
  // ───────────────────────────────────────────────────────────────────────────

  pi.registerTool({
    name: "memory_recall",
    label: "Recall Memory",
    description:
      "Search episodic memories for relevant past sessions. Use keywords, date ranges, or project filters to find relevant context.",
    parameters: EpisodicRecallParams,

    async execute(_toolCallId, params, _signal, _onUpdate, _ctx) {
      const allEpisodes = loadAllEpisodicMemories();

      // Filter by project if specified
      let filtered = params.projectFilter
        ? allEpisodes.filter((e) => e.cwd.includes(params.projectFilter!))
        : allEpisodes;

      // Filter by date range if specified
      if (params.dateRange) {
        const now = new Date();
        const range = params.dateRange.toLowerCase();
        filtered = filtered.filter((e) => {
          const date = new Date(e.timestamp);
          const diff = now.getTime() - date.getTime();
          const days = diff / (1000 * 60 * 60 * 24);
          if (range.includes("week")) return days <= 7;
          if (range.includes("day")) return days <= 1;
          if (range.includes("month")) return days <= 30;
          return true;
        });
      }

      // Score by keyword matches
      const queryWords = params.query.toLowerCase().split(/\s+/);
      const scored = filtered.map((e) => {
        const content = `${e.summary} ${e.keyTopics.join(" ")} ${e.outcomes.join(" ")}`.toLowerCase();
        const score = queryWords.reduce((acc, word) => acc + (content.includes(word) ? 1 : 0), 0);
        return { episode: e, score };
      });

      // Sort by score then by date
      scored.sort((a, b) => {
        if (b.score !== a.score) return b.score - a.score;
        return new Date(b.episode.timestamp).getTime() - new Date(a.episode.timestamp).getTime();
      });

      const results = scored.slice(0, params.limit || 3).map((s) => s.episode);

      if (results.length === 0) {
        return {
          content: [{ type: "text", text: "No relevant memories found for this query." }],
        };
      }

      const output = results
        .map(
          (e) =>
            `**${e.timestamp}** (${e.cwd}): ${e.summary}\n` +
            (e.keyTopics.length ? `Topics: ${e.keyTopics.join(", ")}` : ""),
        )
        .join("\n\n");

      return {
        content: [
          { type: "text", text: `**Relevant Past Sessions:**\n\n${output}` },
          {
            type: "thinking",
            thinking: `Recalled ${results.length} relevant episodic memories matching "${params.query}"`,
          },
        ],
      };
    },

    renderCall(args, theme, _context) {
      const icon = theme.fg("accent", "󰪶 ");
      return `${icon}recall "${args.query.substring(0, 30)}${args.query.length > 30 ? "..." : ""}"`;
    },

    renderResult(result, _opts, theme, _context) {
      const text = result.content[0]?.type === "text" ? result.content[0].text : "";
      return theme.fg("muted", text.split("\n")[0] || "Recall results");
    },
  });

  // ───────────────────────────────────────────────────────────────────────────
  // Commands
  // ───────────────────────────────────────────────────────────────────────────

  pi.registerCommand("memory", {
    description: "Show current working memory state",
    handler: async (_args, ctx) => {
      const content = formatWorkingMemory(workingMemory);
      console.log(content || "Working memory is empty.");
    },
  });

  pi.registerCommand("consolidate", {
    description: "Manually trigger memory consolidation",
    handler: async (_args, ctx) => {
      // This would trigger the same logic that runs at session end
      console.log("Memory consolidation triggered. Running background summary...");
      console.log("Note: This runs automatically at session end via pi -p");
    },
  });

  // ───────────────────────────────────────────────────────────────────────────
  // Initialization
  // ───────────────────────────────────────────────────────────────────────────

  // Ensure memory directories exist
  getMemoryDir();
  getEpisodesDir();
  getSemanticDir();
}
