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
// Secret Scrubbing
// ─────────────────────────────────────────────────────────────────────────────

/**
 * Patterns that match common secret/token formats.
 * Each match is replaced with "[REDACTED]" before writing to memory.
 */
const SECRET_PATTERNS = [
  // Provider-prefixed API keys
  /sk-[a-zA-Z0-9_-]{20,}/g,                       // OpenAI / Anthropic
  /sk-ant-[a-zA-Z0-9_-]{20,}/g,                    // Anthropic
  /ghp_[a-zA-Z0-9]{20,}/g,                         // GitHub PAT
  /github_pat_[a-zA-Z0-9_]{20,}/g,                 // GitHub fine-grained PAT
  /gho_[a-zA-Z0-9]{20,}/g,                         // GitHub OAuth
  /ghs_[a-zA-Z0-9]{20,}/g,                         // GitHub App
  /ghr_[a-zA-Z0-9]{20,}/g,                         // GitHub Refresh
  /npm_[a-zA-Z0-9]{20,}/g,                         // npm token
  /pplx-[a-zA-Z0-9]{20,}/g,                        // Perplexity
  /AKIA[A-Z0-9]{16}/g,                             // AWS access key
  /xox[bsapr]-[a-zA-Z0-9-]{20,}/g,                 // Slack tokens
  /AIzaSy[a-zA-Z0-9_-]{30,}/g,                     // Google API key

  // Generic high-entropy tokens (hex ≥32 chars, base64-ish ≥40 chars)
  /(?<=[=:\s'"])[a-f0-9]{32,}(?=[\s'"\n,;]|$)/gi,
  /(?<=[=:\s'"])[A-Za-z0-9+/]{40,}={0,2}(?=[\s'"\n,;]|$)/g,

  // key=value patterns for known env var names
  /(?:API_KEY|SECRET|TOKEN|PASSWORD|PASSWD|PRIVATE_KEY|CLIENT_SECRET|AUTH_TOKEN)\s*[=:]\s*\S+/gi,

  // Inline export assignments: export VAR_WITH_KEY_OR_SECRET=value
  /export\s+\w*(?:KEY|SECRET|TOKEN|PASSWORD|CREDENTIAL)\w*\s*=\s*\S+/gi,
];

/**
 * Remove secrets from a string, replacing each match with [REDACTED].
 */
function scrubSecrets(text) {
  let scrubbed = text;
  for (const pattern of SECRET_PATTERNS) {
    // Reset lastIndex for global regexes
    pattern.lastIndex = 0;
    scrubbed = scrubbed.replace(pattern, "[REDACTED]");
  }
  return scrubbed;
}

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
 * Remove entries created while aside mode was active.
 *
 * aside.ts persists custom entries with customType="aside-mode" and
 * data.enabled=true|false. Everything between an enable marker and the next
 * disable marker is treated as off-record and excluded from episodic and
 * semantic memory generation.
 */
function filterAsideEntries(entries) {
  const filtered = [];
  let asideActive = false;

  for (const entry of entries) {
    if (entry.type === "custom" && entry.customType === "aside-mode") {
      asideActive = Boolean(entry.data?.enabled);
      continue;
    }

    if (asideActive) {
      continue;
    }

    filtered.push(entry);
  }

  return filtered;
}

/**
 * Extract text content from a message entry.
 */
function extractText(entry) {
  const content = entry.message?.content;
  if (typeof content === "string") return content;
  if (Array.isArray(content)) {
    return content
      .filter((c) => c.type === "text")
      .map((c) => c.text)
      .join(" ");
  }
  return "";
}

/**
 * Generate a structured summary from session entries.
 *
 * Uses a template approach anchored on the user's actual messages,
 * supplemented by file paths from tool calls and keyword-based topics.
 */
function generateSummary(entries) {
  // Collect user messages
  const userMessages = entries
    .filter((e) => e.type === "message" && e.message?.role === "user")
    .map(extractText)
    .filter(Boolean);

  // Collect assistant messages
  const assistantMessages = entries
    .filter((e) => e.type === "message" && e.message?.role === "assistant")
    .map(extractText)
    .filter(Boolean);

  // Collect tool calls with their arguments
  const toolCalls = entries
    .filter((e) => e.type === "message" && e.message?.role === "assistant")
    .flatMap((e) => {
      const content = e.message?.content;
      if (!Array.isArray(content)) return [];
      return content
        .filter((c) => c.type === "tool_use")
        .map((c) => ({ name: c.name, input: c.input }));
    })
    .filter(Boolean);

  const uniqueTools = [...new Set(toolCalls.map((t) => t.name))];

  if (userMessages.length === 0) {
    return { summary: "Empty session", topics: [], outcomes: [], actionItems: [], context: "" };
  }

  // ── Context: first user message (truncated) ──────────────────────────
  const context = userMessages[0].substring(0, 300).trim();

  // ── Files touched: extract from tool call arguments ──────────────────
  const filesTouched = new Set();
  for (const tc of toolCalls) {
    const input = tc.input || {};
    // Read, Edit, Write tools have a 'path' argument
    if (input.path && typeof input.path === "string") {
      filesTouched.add(input.path);
    }
  }
  const fileList = [...filesTouched].map((f) => basename(f));
  const uniqueFiles = [...new Set(fileList)].slice(0, 8);

  // ── Keyword-based topics ─────────────────────────────────────────────
  const allUserText = userMessages.join(" ").toLowerCase();
  const topics = new Set();

  const patterns = [
    { re: /\b(refactor|restructur)/i, topic: "refactoring" },
    { re: /\b(fix|bug|issue|error|broken|debug)/i, topic: "debugging" },
    { re: /\b(test|spec|assert)/i, topic: "testing" },
    { re: /\b(config|setup|install)/i, topic: "configuration" },
    { re: /\b(dotfiles?|nix|darwin|home-manager|flake)/i, topic: "dotfiles/nix" },
    { re: /\b(spa\d|spanish|class|course|teach)/i, topic: "teaching" },
    { re: /\b(deploy|publish|release)/i, topic: "deployment" },
    { re: /\b(document|readme|docs)/i, topic: "documentation" },
    { re: /\b(style|theme|css|color)/i, topic: "styling" },
    { re: /\b(memory|episod|semantic|recall)/i, topic: "memory system" },
    { re: /\b(review|audit|assess)/i, topic: "review" },
    { re: /\b(plan|design|architect)/i, topic: "planning" },
    { re: /\b(script|automat|cron|systemd)/i, topic: "automation" },
    { re: /\b(git|commit|branch|merge|pr)/i, topic: "git" },
    { re: /\b(network|dns|ping|ssh|vpn|proxy)/i, topic: "networking" },
  ];

  for (const { re, topic } of patterns) {
    if (re.test(allUserText)) {
      topics.add(topic);
    }
  }

  // ── Outcomes: what tools did ─────────────────────────────────────────
  const outcomes = [];
  if (uniqueTools.includes("Write") || uniqueTools.includes("write")) {
    outcomes.push("wrote files");
  }
  if (uniqueTools.includes("Edit") || uniqueTools.includes("edit")) {
    outcomes.push("edited files");
  }
  if (uniqueTools.includes("Bash") || uniqueTools.includes("bash")) {
    outcomes.push("ran commands");
  }

  // ── Action items: scan for TODO-like forward references ──────────────
  const actionItems = extractActionItems(userMessages, assistantMessages);

  // ── Build summary ───────────────────────────────────────────────────
  const topicList = [...topics].slice(0, 5);

  // Start with the user's opening request (truncated)
  let summary = context.length > 200
    ? context.substring(0, 200) + "..."
    : context;

  // Append file and tool context
  const parts = [];
  if (uniqueFiles.length > 0) {
    parts.push(`Files: ${uniqueFiles.join(", ")}`);
  }
  if (outcomes.length > 0) {
    parts.push(`Actions: ${outcomes.join(", ")}`);
  }
  if (parts.length > 0) {
    summary += ` [${parts.join(". ")}]`;
  }

  return {
    summary,
    topics: topicList,
    outcomes,
    actionItems,
    context,
  };
}

/**
 * Extract action items from session messages.
 *
 * Scans for TODO-like phrases, forward-looking statements, and
 * explicit next-step language in both user and assistant messages.
 */
function extractActionItems(userMessages, assistantMessages) {
  const items = new Set();
  const allMessages = [...userMessages, ...assistantMessages];

  const actionPatterns = [
    // Explicit TODOs
    /TODO[:\s]+(.{10,80})/gi,
    // Forward-looking statements
    /(?:next time|later|still need to|should also|need to|will need to|don't forget to|make sure to)\s+(.{10,80})/gi,
    // "We should" / "I should" patterns
    /(?:we|i) should\s+(.{10,80})/gi,
    // "Remains to" / "left to do"
    /(?:remains to|left to|pending|outstanding)[:\s]+(.{10,80})/gi,
  ];

  for (const msg of allMessages) {
    for (const pattern of actionPatterns) {
      pattern.lastIndex = 0;
      let match;
      while ((match = pattern.exec(msg)) !== null) {
        const item = match[1].trim().replace(/[.;,]$/, "");
        if (item.length >= 10) {
          items.add(item);
        }
      }
    }
  }

  return [...items].slice(0, 5);
}

// ─────────────────────────────────────────────────────────────────────────────
// Consolidation
// ─────────────────────────────────────────────────────────────────────────────

const MAX_CONSOLIDATED_ENTRIES = 50;

/**
 * Derive a meaningful project name from a cwd path.
 *
 * Uses the last 2 significant path segments (skipping the home directory),
 * e.g. "/Users/francojc/.dotfiles/.config/nix" → "dotfiles/nix"
 */
function projectNameFromCwd(cwd) {
  const home = homedir();
  const relative = cwd.startsWith(home) ? cwd.slice(home.length) : cwd;
  const segments = relative.split("/").filter(Boolean);
  // Take last 2 segments, strip leading dots for readability
  const meaningful = segments.slice(-2).map((s) => s.replace(/^\./, ""));
  return meaningful.join("/") || "unknown";
}

/**
 * Check if two episodes overlap significantly in topics.
 */
function topicsOverlap(existingTopics, newTopics) {
  if (existingTopics.length === 0 || newTopics.length === 0) return false;
  const shared = newTopics.filter((t) => existingTopics.includes(t));
  return shared.length / Math.max(existingTopics.length, newTopics.length) >= 0.8;
}

function consolidateEpisodes(toConsolidate) {
  // Group by project directory
  const byProject = new Map();
  for (const ep of toConsolidate) {
    const project = projectNameFromCwd(ep.cwd);
    if (!byProject.has(project)) {
      byProject.set(project, []);
    }
    byProject.get(project).push(ep);
  }

  ensureDir(join(SEMANTIC_DIR, "projects"));

  for (const [project, episodes] of byProject) {
    // Use sanitized filename (replace / with --)
    const safeFilename = project.replace(/\//g, "--");
    const projectPath = join(SEMANTIC_DIR, "projects", `${safeFilename}.md`);

    // Load existing content and parse existing entries
    let header = `# ${project}\n\n## Consolidated Sessions`;
    let existingEntries = [];

    if (existsSync(projectPath)) {
      const content = readFileSync(projectPath, "utf-8").trim();
      // Extract the header (everything before the first ### entry)
      const firstEntry = content.indexOf("### ");
      if (firstEntry >= 0) {
        header = content.substring(0, firstEntry).trim();
        // Parse existing entries by splitting on ### boundaries
        const entriesSection = content.substring(firstEntry);
        existingEntries = entriesSection
          .split(/(?=^### )/m)
          .filter((e) => e.trim());
      } else {
        header = content;
      }
    }

    // Build new entries, skipping if topics overlap >80% with existing
    const newEntries = [];
    for (const ep of episodes) {
      // Check for dedup against existing entries (by topic overlap)
      const isDuplicate = existingEntries.some((existing) => {
        const topicMatch = existing.match(/- Topics: (.+)/);
        if (!topicMatch) return false;
        const existingTopics = topicMatch[1].split(", ").map((t) => t.trim());
        return topicsOverlap(existingTopics, ep.keyTopics);
      });

      if (isDuplicate) {
        console.log(`Skipping duplicate entry for ${project}: ${ep.keyTopics.join(", ")}`);
        continue;
      }

      let entry = `### ${new Date(ep.timestamp).toLocaleDateString()}\n\n`;
      entry += `- ${scrubSecrets(ep.summary)}\n`;
      if (ep.keyTopics.length) entry += `- Topics: ${ep.keyTopics.join(", ")}\n`;
      if (ep.outcomes.length) entry += `- Outcomes: ${ep.outcomes.join(", ")}\n`;
      if (ep.actionItems && ep.actionItems.length) {
        entry += `- Action items: ${ep.actionItems.join("; ")}\n`;
      }
      newEntries.push(entry);
    }

    // Merge and enforce rolling window cap
    const allEntries = [...existingEntries, ...newEntries];
    const capped = allEntries.slice(-MAX_CONSOLIDATED_ENTRIES);

    if (capped.length < allEntries.length) {
      console.log(`Capped ${project}: dropped ${allEntries.length - capped.length} oldest entries`);
    }

    // Write the file
    writeFileSync(projectPath, `${header}\n\n${capped.join("\n")}\n`);
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
  const rawEntries = parseSessionFile(sessionPath);

  if (rawEntries.length === 0) {
    console.log("No entries in session file, skipping.");
    return;
  }

  const entries = filterAsideEntries(rawEntries);

  // Extract session metadata
  const sessionEntry = rawEntries.find((e) => e.type === "session");
  const cwd = sessionEntry?.cwd || process.cwd();
  const timestamp = sessionEntry?.timestamp || new Date().toISOString();

  // Generate summary
  const { summary, topics, outcomes, actionItems, context } = generateSummary(entries);

  // Skip trivially short sessions or sessions that only contained aside content
  const userMsgCount = entries.filter(
    (e) => e.type === "message" && e.message?.role === "user",
  ).length;
  if (userMsgCount === 0) {
    console.log("No non-aside user messages, skipping episodic save.");
    return;
  }

  // Save episodic memory (scrub secrets from all text fields)
  const episodic = {
    sessionId,
    timestamp,
    cwd,
    summary: scrubSecrets(summary),
    keyTopics: topics,
    actionItems: actionItems.map(scrubSecrets),
    outcomes,
    context: scrubSecrets(context),
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
