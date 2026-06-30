import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { spawn } from "node:child_process";
import { createHash } from "node:crypto";
import { closeSync, existsSync, openSync, readFileSync, readdirSync, rmSync, statSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";

const HOME = process.env.HOME || "/tmp";
const AGENT_DIR = process.env.PI_CODING_AGENT_DIR || join(HOME, ".pi", "agent");
const SETTINGS_FILE = join(AGENT_DIR, "settings.json");
const NPM_PACKAGE_FILE = join(AGENT_DIR, "npm", "package.json");
const NPM_LOCK_FILE = join(AGENT_DIR, "npm", "package-lock.json");
const EXTENSIONS_DIR = join(AGENT_DIR, "extensions");
const SKILL_DIR = join(AGENT_DIR, "skills", "pi-guide-maintainer");
const STATE_FILE = join(AGENT_DIR, "pi-guide-autoupdate-state.json");
const LOCK_FILE = join(AGENT_DIR, "pi-guide-autoupdate.lock");
const LOG_FILE = join(AGENT_DIR, "pi-guide-maintainer.log");
const DEFAULT_GUIDE_MODEL = "github-copilot/claude-haiku-4.5";
const LOCK_STALE_MS = 60 * 60 * 1000;
const STATUS_CLEAR_MS = 10_000;

function readText(path: string): string {
  try {
    return readFileSync(path, "utf8");
  } catch {
    return "";
  }
}

function readJson<T = unknown>(path: string): T | null {
  try {
    return JSON.parse(readText(path)) as T;
  } catch {
    return null;
  }
}

function hashText(hash: ReturnType<typeof createHash>, label: string, text: string): void {
  hash.update(`\n--- ${label} ---\n`);
  hash.update(text);
}

function walkFiles(dir: string): string[] {
  if (!existsSync(dir)) return [];

  const files: string[] = [];
  for (const name of readdirSync(dir).sort()) {
    const path = join(dir, name);
    let stat;
    try {
      stat = statSync(path);
    } catch {
      continue;
    }

    if (stat.isDirectory()) {
      if (name === "node_modules" || name === ".git") continue;
      files.push(...walkFiles(path));
      continue;
    }

    if (!stat.isFile()) continue;
    if (!/\.(ts|js|mjs|cjs)$/.test(name)) continue;
    files.push(path);
  }

  return files;
}

function currentFingerprint(): string {
  const hash = createHash("sha256");
  const settings = readJson<{ packages?: unknown[] }>(SETTINGS_FILE);
  hashText(hash, "settings.packages", JSON.stringify(settings?.packages ?? [], null, 2));
  hashText(hash, "npm/package.json", readText(NPM_PACKAGE_FILE));
  hashText(hash, "npm/package-lock.json", readText(NPM_LOCK_FILE));

  for (const file of walkFiles(EXTENSIONS_DIR)) {
    hashText(hash, `extension:${file.slice(AGENT_DIR.length + 1)}`, readText(file));
  }

  return hash.digest("hex");
}

function shQuote(value: string): string {
  return `'${value.replace(/'/g, `'\\''`)}'`;
}

function getPiBinary(): string {
  return process.env.PI_GUIDE_PI_BIN || process.env.PI_BIN || "pi";
}

function getGuideModel(): string {
  return process.env.PI_GUIDE_MODEL || DEFAULT_GUIDE_MODEL;
}

function readLastFingerprint(): string | null {
  const state = readJson<{ fingerprint?: string }>(STATE_FILE);
  return typeof state?.fingerprint === "string" ? state.fingerprint : null;
}

function writeState(fingerprint: string): void {
  writeFileSync(
    STATE_FILE,
    JSON.stringify(
      {
        fingerprint,
        lastRunAt: new Date().toISOString(),
        scope: "packages+local-extensions",
        model: getGuideModel(),
      },
      null,
      2,
    ),
  );
}

function isLockFresh(): boolean {
  if (!existsSync(LOCK_FILE)) return false;
  try {
    const stat = statSync(LOCK_FILE);
    if (Date.now() - stat.mtimeMs <= LOCK_STALE_MS) return true;
    rmSync(LOCK_FILE, { force: true });
    return false;
  } catch {
    return false;
  }
}

function tryCreateLock(fingerprint: string): boolean {
  if (isLockFresh()) return false;
  try {
    writeFileSync(
      LOCK_FILE,
      JSON.stringify({ fingerprint, startedAt: new Date().toISOString() }, null, 2),
      { flag: "wx" },
    );
    return true;
  } catch {
    return false;
  }
}

function setTemporaryStatus(ctx: ExtensionContext, message: string): void {
  ctx.ui.setStatus("pi-guide", message);
  setTimeout(() => {
    try {
      ctx.ui.setStatus("pi-guide", undefined);
    } catch {
      // Session may be gone.
    }
  }, STATUS_CLEAR_MS).unref?.();
}

function spawnGuideUpdate(ctx: ExtensionContext, fingerprint: string): boolean {
  if (!tryCreateLock(fingerprint)) {
    setTemporaryStatus(ctx, "guide: update already running");
    return false;
  }

  const prompt = [
    "/skill:pi-guide-maintainer",
    "Update PI-GUIDE.md because installed Pi packages or local extensions changed.",
    "Scope: packages and local extensions only. Do not document skill-only or keybinding-only changes unless needed for package/extension behavior.",
    "Auto-edit the guide. Keep output concise and report changed sections only.",
  ].join(" ");

  const args = [
    "-p",
    "--no-session",
    "--no-extensions",
    "--no-skills",
    "--skill",
    SKILL_DIR,
    "--model",
    getGuideModel(),
    "--thinking",
    "off",
    "--tools",
    "read,grep,find,ls,edit,write,bash",
    prompt,
  ];

  const command = [
    `trap 'rm -f ${shQuote(LOCK_FILE)}' EXIT`,
    `cd ${shQuote(AGENT_DIR)}`,
    `PI_GUIDE_AUTORUN=1 PI_SKIP_VERSION_CHECK=1 PI_MODEL_DISCOVERY_DEBUG=0 ${shQuote(getPiBinary())} ${args.map(shQuote).join(" ")}`,
  ].join("; ");

  let logFd: number | undefined;
  try {
    logFd = openSync(LOG_FILE, "a");
    const child = spawn("/bin/sh", ["-lc", command], {
      cwd: AGENT_DIR,
      detached: true,
      env: {
        ...process.env,
        PI_GUIDE_AUTORUN: "1",
        PI_SKIP_VERSION_CHECK: "1",
        PI_MODEL_DISCOVERY_DEBUG: "0",
      },
      stdio: ["ignore", logFd, logFd],
    });

    child.unref();
    writeState(fingerprint);
    setTemporaryStatus(ctx, "guide: updating in background");
    return true;
  } catch (error) {
    rmSync(LOCK_FILE, { force: true });
    setTemporaryStatus(ctx, "guide: update failed to start");
    try {
      writeFileSync(LOG_FILE, `[${new Date().toISOString()}] Failed to spawn guide update: ${String(error)}\n`, { flag: "a" });
    } catch {
      // Ignore logging failure.
    }
    return false;
  } finally {
    if (logFd !== undefined) {
      try {
        closeSync(logFd);
      } catch {
        // Ignore close failure.
      }
    }
  }
}

export default function (pi: ExtensionAPI) {
  pi.on("session_start", async (_event, ctx) => {
    if (process.env.PI_GUIDE_AUTOUPDATE === "0") return;
    if (process.env.PI_GUIDE_AUTORUN === "1") return;
    if (ctx.mode !== "tui") return;

    const fingerprint = currentFingerprint();
    if (fingerprint === readLastFingerprint()) return;

    spawnGuideUpdate(ctx, fingerprint);
  });
}
