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
import { Text } from "@mariozechner/pi-tui";
import { Type } from "@sinclair/typebox";
import { existsSync, mkdirSync, openSync, readdirSync, readFileSync, writeFileSync } from "fs";
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
  const home = homedir();
  const relative = cwd.startsWith(home) ? cwd.slice(home.length) : cwd;
  const segments = relative.split("/").filter(Boolean);
  const meaningful = segments.slice(-2).map((s) => s.replace(/^\./, ""));
  const projectName = meaningful.join("--") || "default";
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

  // Build memory context string for system prompt injection
  const buildMemoryContext = (cwd: string): string => {
    const episodes = loadEpisodicMemories();
    const recentProjects = [...new Set(episodes.slice(0, 3).map((e) => e.cwd))].filter(Boolean);

    const semanticContent = loadProjectSemantic(cwd);
    const workingContent = formatWorkingMemory(workingMemory);

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

    return memorySections.join("\n\n");
  };

  // ───────────────────────────────────────────────────────────────────────────
  // Event Handlers
  // ───────────────────────────────────────────────────────────────────────────

  pi.on("session_start", async (event, ctx) => {
    reconstructState(ctx);

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

  // Inject memory context into system prompt before each agent turn
  pi.on("before_agent_start", async (event, ctx) => {
    const memoryContext = buildMemoryContext(ctx.cwd);
    if (memoryContext) {
      return {
        systemPrompt: event.systemPrompt + "\n\n# Memory Context\n\n" + memoryContext,
      };
    }
  });

  pi.on("session_shutdown", async (_event, ctx) => {
    const sessionFile = ctx.sessionManager.getSessionFile();
    if (!sessionFile) return; // ephemeral session, nothing to summarize

    // Spawn the session-end processor in the background so it doesn't block exit
    const processorPath = join(dirname(import.meta.url.replace("file://", "")), "..", "session-end-processor.mjs");
    if (!existsSync(processorPath)) return;

    // Log stderr to a file so processor errors are visible
    const logPath = join(MEMORY_DIR, "processor.log");
    ensureDir(MEMORY_DIR);
    const logFd = openSync(logPath, "a");

    const child = spawn("node", [processorPath, sessionFile], {
      detached: true,
      stdio: ["ignore", logFd, logFd],
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
      const label = `${icon}memory ${theme.fg("muted", args.action)}${args.content ? ` "${args.content.substring(0, 30)}${args.content.length > 30 ? "..." : ""}"` : ""}`;
      return new Text(label, 0, 0);
    },

    renderResult(result, _opts, theme, _context) {
      const text = result.content[0]?.type === "text" ? result.content[0].text : "";
      return new Text(theme.fg("muted", text), 0, 0);
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
        const content = `${e.summary} ${e.keyTopics.join(" ")} ${e.outcomes.join(" ")} ${(e as any).context || ""} ${(e as any).actionItems?.join(" ") || ""}`.toLowerCase();
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
        ],
      };
    },

    renderCall(args, theme, _context) {
      const icon = theme.fg("accent", "󰪶 ");
      return new Text(`${icon}recall "${args.query.substring(0, 30)}${args.query.length > 30 ? "..." : ""}"`, 0, 0);
    },

    renderResult(result, _opts, theme, _context) {
      const text = result.content[0]?.type === "text" ? result.content[0].text : "";
      return new Text(theme.fg("muted", text.split("\n")[0] || "Recall results"), 0, 0);
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
    description: "Manually trigger memory consolidation for the current session",
    handler: async (_args, ctx) => {
      const sessionFile = ctx.sessionManager.getSessionFile();
      if (!sessionFile) {
        console.log("No session file (ephemeral session). Nothing to consolidate.");
        return;
      }

      const processorPath = join(dirname(import.meta.url.replace("file://", "")), "..", "session-end-processor.mjs");
      if (!existsSync(processorPath)) {
        console.log("Error: session-end-processor.mjs not found.");
        return;
      }

      console.log("Running memory processor...");
      const logPath = join(MEMORY_DIR, "processor.log");
      ensureDir(MEMORY_DIR);
      const logFd = openSync(logPath, "a");

      const child = spawn("node", [processorPath, sessionFile], {
        detached: true,
        stdio: ["ignore", logFd, logFd],
      });
      child.unref();
      console.log("Consolidation started in background. Check ~/.pi/memory/processor.log for output.");
    },
  });

  pi.registerCommand("memory-status", {
    description: "Show memory system health: episode count, semantic files, recent log",
    handler: async (_args, _ctx) => {
      const episodes = loadAllEpisodicMemories();
      const semanticDir = join(getSemanticDir(), "projects");
      const semanticFiles = existsSync(semanticDir)
        ? readdirSync(semanticDir).filter((f) => f.endsWith(".md"))
        : [];
      const logPath = join(MEMORY_DIR, "processor.log");
      const logTail = existsSync(logPath)
        ? readFileSync(logPath, "utf-8").trim().split("\n").slice(-5).join("\n")
        : "(no log file)";

      console.log(`Episodes in buffer: ${episodes.length} / ${EPISODE_LIMIT}`);
      console.log(`Semantic project files: ${semanticFiles.length}`);
      if (semanticFiles.length > 0) {
        console.log(`  ${semanticFiles.map((f) => f.replace(".md", "").replace(/--/g, "/")).join(", ")}`);
      }
      console.log(`\nRecent processor log:`);
      console.log(logTail);
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
