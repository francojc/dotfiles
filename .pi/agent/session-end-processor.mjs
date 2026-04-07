#!/usr/bin/env node
/**
 * Session End Memory Processor
 *
 * Runs at session end (spawned by memory.ts session_shutdown handler) to:
 * 1. Generate an episodic summary from the completed session
 * 2. Consolidate old episodic memories into semantic memory
 * 3. Prune episodic buffer to keep only the most recent episodes
 *
 * Usage: node session-end-processor.mjs <session-jsonl-path>
 */

import { existsSync, mkdirSync, readdirSync, readFileSync, writeFileSync, unlinkSync } from "fs";
import { join, basename } from "path";
import { homedir } from "os";

// ─────────────────────────────────────────────────────────────────────────────
// Configuration
// ─────────────────────────────────────────────────────────────────────────────

const MEMORY_DIR = join(homedir(), ".pi", "memory");
const EPISODES_DIR = join(MEMORY_DIR, "episodes");
const SEMANTIC_DIR = join(MEMORY_DIR, "semantic");
const EPISODE_LIMIT = 5;

// ─────────────────────────────────────────────────────────────────────────────
// Utilities
// ─────────────────────────────────────────────────────────────────────────────

function ensureDir(path) {
  if (!existsSync(path)) {
    mkdirSync(path, { recursive: true });
  }
}

function parseSessionFile(path) {
  const content = readFileSync(path, "utf-8");
  return content
    .trim()
    .split("\n")
    .map((line) => {
      try {
        return JSON.parse(line);
      } catch {
        return null;
      }
    })
    .filter((e) => e !== null);
}

/**
 * Generate a summary from session entries.
 *
 * This is a heuristic keyword-based summarizer. It scans user messages for
 * common action words and file references to build a brief description.
 * A proper LLM-based summarizer can replace this later.
 */
function generateSummary(entries) {
  // Collect user messages
  const userMessages = entries
    .filter((e) => e.type === "message" && e.message?.role === "user")
    .map((e) => {
      const content = e.message?.content;
      if (typeof content === "string") return content;
      if (Array.isArray(content)) {
        return content
          .filter((c) => c.type === "text")
          .map((c) => c.text)
          .join(" ");
      }
      return "";
    })
    .filter(Boolean);

  // Collect assistant messages for outcome detection
  const assistantMessages = entries
    .filter((e) => e.type === "message" && e.message?.role === "assistant")
    .map((e) => {
      const content = e.message?.content;
      if (typeof content === "string") return content;
      if (Array.isArray(content)) {
        return content
          .filter((c) => c.type === "text")
          .map((c) => c.text)
          .join(" ");
      }
      return "";
    })
    .filter(Boolean);

  // Collect tool names used
  const toolsUsed = entries
    .filter((e) => e.type === "message" && e.message?.role === "assistant")
    .flatMap((e) => {
      const content = e.message?.content;
      if (!Array.isArray(content)) return [];
      return content
        .filter((c) => c.type === "tool_use")
        .map((c) => c.name);
    })
    .filter(Boolean);

  const uniqueTools = [...new Set(toolsUsed)];

  if (userMessages.length === 0) {
    return { summary: "Empty session", topics: [], outcomes: [] };
  }

  const allUserText = userMessages.join(" ").toLowerCase();
  const topics = new Set();
  const outcomes = new Set();
  const actions = new Set();

  // File mentions across all messages
  const allText = [...userMessages, ...assistantMessages].join(" ");
  const fileMatches = allText.match(/(?:\/[\w./-]+\.\w+)/g);
  if (fileMatches) {
    const uniqueFiles = [...new Set(fileMatches.map((f) => basename(f)))].slice(0, 5);
    uniqueFiles.forEach((f) => topics.add(`file:${f}`));
  }

  // Keyword extraction
  const patterns = [
    { re: /\b(refactor|restructur)/i, topic: "refactoring", action: "refactored" },
    { re: /\b(fix|bug|issue|error|broken)/i, topic: "debugging", action: "fixed issues" },
    { re: /\b(add|creat|new|implement|build)/i, topic: null, action: "created new content" },
    { re: /\b(test|spec|assert)/i, topic: "testing", action: "worked on tests" },
    { re: /\b(config|setup|install)/i, topic: "configuration", action: null },
    { re: /\b(dotfiles?|nix|darwin|home-manager)/i, topic: "dotfiles/nix", action: null },
    { re: /\b(spa\d|spanish|class|course|teach)/i, topic: "teaching", action: null },
    { re: /\b(review|edit|revis|rewrit)/i, topic: null, action: "reviewed/revised" },
    { re: /\b(deploy|publish|release)/i, topic: "deployment", action: "deployed" },
    { re: /\b(document|readme|docs)/i, topic: "documentation", action: null },
    { re: /\b(style|theme|css|color)/i, topic: "styling", action: null },
    { re: /\b(memory|episod|semantic|recall)/i, topic: "memory system", action: null },
  ];

  for (const { re, topic, action } of patterns) {
    if (re.test(allUserText)) {
      if (topic) topics.add(topic);
      if (action) actions.add(action);
    }
  }

  // Tool-based outcomes
  if (uniqueTools.includes("Write") || uniqueTools.includes("write")) {
    outcomes.add("wrote files");
  }
  if (uniqueTools.includes("Edit") || uniqueTools.includes("edit")) {
    outcomes.add("edited files");
  }
  if (uniqueTools.includes("Bash") || uniqueTools.includes("bash")) {
    outcomes.add("ran commands");
  }

  // Build summary
  const topicList = [...topics].slice(0, 4);
  const actionList = [...actions].slice(0, 2);
  const outcomeList = [...outcomes].slice(0, 3);

  let summary = "";
  if (actionList.length > 0) {
    summary = actionList.join(", ");
    if (topicList.length > 0) {
      summary += ` involving ${topicList.join(", ")}`;
    }
  } else if (topicList.length > 0) {
    summary = `Worked on ${topicList.join(", ")}`;
  } else {
    summary = `Session with ${userMessages.length} message(s)`;
  }

  if (outcomeList.length > 0) {
    summary += ` (${outcomeList.join(", ")})`;
  }

  // Capitalize first letter
  summary = summary.charAt(0).toUpperCase() + summary.slice(1);

  return {
    summary,
    topics: [...topicList],
    outcomes: [...outcomeList],
  };
}

// ─────────────────────────────────────────────────────────────────────────────
// Consolidation
// ─────────────────────────────────────────────────────────────────────────────

function consolidateEpisodes(toConsolidate) {
  // Group by project directory
  const byProject = new Map();
  for (const ep of toConsolidate) {
    const project = ep.cwd.split("/").pop() || "unknown";
    if (!byProject.has(project)) {
      byProject.set(project, []);
    }
    byProject.get(project).push(ep);
  }

  ensureDir(join(SEMANTIC_DIR, "projects"));

  for (const [project, episodes] of byProject) {
    const projectPath = join(SEMANTIC_DIR, "projects", `${project}.md`);

    // Load existing content (if any)
    let existing = "";
    if (existsSync(projectPath)) {
      existing = readFileSync(projectPath, "utf-8").trim();
    }

    // Build new entries
    const newEntries = episodes
      .map(
        (ep) =>
          `### ${new Date(ep.timestamp).toLocaleDateString()}\n\n` +
          `- ${ep.summary}\n` +
          (ep.keyTopics.length ? `- Topics: ${ep.keyTopics.join(", ")}\n` : "") +
          (ep.outcomes.length ? `- Outcomes: ${ep.outcomes.join(", ")}\n` : ""),
      )
      .join("\n");

    // If the file already has a "## Consolidated Sessions" section, append to it.
    // Otherwise create the section.
    if (existing.includes("## Consolidated Sessions")) {
      writeFileSync(projectPath, `${existing}\n\n${newEntries}\n`);
    } else if (existing) {
      writeFileSync(projectPath, `${existing}\n\n## Consolidated Sessions\n\n${newEntries}\n`);
    } else {
      writeFileSync(projectPath, `# ${project}\n\n## Consolidated Sessions\n\n${newEntries}\n`);
    }

    console.log(`Updated semantic memory: ${project}`);
  }

  // Remove consolidated episode files
  for (const ep of toConsolidate) {
    const path = join(EPISODES_DIR, `${ep.sessionId}.json`);
    if (existsSync(path)) {
      unlinkSync(path);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Main
// ─────────────────────────────────────────────────────────────────────────────

function processSessionEnd(sessionPath) {
  const sessionId = basename(sessionPath, ".jsonl");
  const entries = parseSessionFile(sessionPath);

  if (entries.length === 0) {
    console.log("No entries in session file, skipping.");
    return;
  }

  // Extract session metadata
  const sessionEntry = entries.find((e) => e.type === "session");
  const cwd = sessionEntry?.cwd || process.cwd();
  const timestamp = sessionEntry?.timestamp || new Date().toISOString();

  // Generate summary
  const { summary, topics, outcomes } = generateSummary(entries);

  // Skip trivially short sessions (e.g., accidental opens)
  const userMsgCount = entries.filter(
    (e) => e.type === "message" && e.message?.role === "user",
  ).length;
  if (userMsgCount === 0) {
    console.log("No user messages, skipping episodic save.");
    return;
  }

  // Save episodic memory
  const episodic = {
    sessionId,
    timestamp,
    cwd,
    summary,
    keyTopics: topics,
    actionItems: [],
    outcomes,
  };

  ensureDir(EPISODES_DIR);
  const episodicPath = join(EPISODES_DIR, `${sessionId}.json`);
  writeFileSync(episodicPath, JSON.stringify(episodic, null, 2));
  console.log(`Saved episodic memory: ${basename(episodicPath)}`);

  // Load all episodes sorted newest-first
  const allEpisodes = readdirSync(EPISODES_DIR)
    .filter((f) => f.endsWith(".json"))
    .map((f) => {
      try {
        return JSON.parse(readFileSync(join(EPISODES_DIR, f), "utf-8"));
      } catch {
        return null;
      }
    })
    .filter((e) => e !== null)
    .sort((a, b) => new Date(b.timestamp).getTime() - new Date(a.timestamp).getTime());

  // Consolidate if over limit
  if (allEpisodes.length > EPISODE_LIMIT) {
    const toConsolidate = allEpisodes.slice(EPISODE_LIMIT);
    console.log(`Consolidating ${toConsolidate.length} old episode(s) to semantic memory...`);
    consolidateEpisodes(toConsolidate);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Entry Point
// ─────────────────────────────────────────────────────────────────────────────

const sessionPath = process.argv[2];

if (!sessionPath) {
  console.error("Usage: node session-end-processor.mjs <session-jsonl-path>");
  process.exit(1);
}

if (!existsSync(sessionPath)) {
  console.error(`Session file not found: ${sessionPath}`);
  process.exit(1);
}

processSessionEnd(sessionPath);
console.log("Memory processing complete.");
