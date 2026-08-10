import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { existsSync, readFileSync, readdirSync, statSync, writeFileSync } from "node:fs";
import { join } from "node:path";

const HOME = process.env.HOME || "/tmp";
const AGENT_DIR = process.env.PI_CODING_AGENT_DIR || join(HOME, ".pi", "agent");
const SETTINGS_FILE = join(AGENT_DIR, "settings.json");
const NPM_PACKAGE_FILE = join(AGENT_DIR, "npm", "package.json");
const EXTENSIONS_DIR = join(AGENT_DIR, "extensions");
const INVENTORY_FILE = join(AGENT_DIR, "PI-INVENTORY.local.md");

type Settings = {
  defaultModel?: string;
  defaultProvider?: string;
  enabledModels?: string[];
  lastChangelogVersion?: string;
  packages?: string[];
};

type PackageManifest = {
  dependencies?: Record<string, string>;
};

function readJson<T>(path: string): T | null {
  try {
    return JSON.parse(readFileSync(path, "utf8")) as T;
  } catch {
    return null;
  }
}

function packageName(entry: string): string {
  return entry.startsWith("npm:") ? entry.slice("npm:".length).replace(/@[^@/]+$/, "") : entry;
}

function installedVersion(name: string): string {
  const manifest = readJson<{ version?: string }>(join(AGENT_DIR, "npm", "node_modules", name, "package.json"));
  return manifest?.version || "not installed";
}

function localExtensions(): string[] {
  try {
    return readdirSync(EXTENSIONS_DIR)
      .filter((name) => {
        const path = join(EXTENSIONS_DIR, name);
        const stat = statSync(path);
        return stat.isDirectory() || /\.(ts|js|mjs|cjs)$/.test(name);
      })
      .sort();
  } catch {
    return [];
  }
}

function bulletList(items: string[], empty = "None"): string[] {
  return items.length ? items.map((item) => `- \`${item}\``) : [`- ${empty}`];
}

function writeInventory(ctx: ExtensionContext): void {
  const settings = readJson<Settings>(SETTINGS_FILE) || {};
  const manifest = readJson<PackageManifest>(NPM_PACKAGE_FILE) || {};
  const packages = settings.packages || [];
  const lines = [
    "# Local Pi inventory",
    "",
    "Generated automatically on interactive Pi startup. Machine-local state only; do not commit.",
    "",
    "## Runtime",
    "",
    `- Pi version: \`${settings.lastChangelogVersion || "unknown"}\``,
    `- Default model: \`${settings.defaultProvider || "unknown"}/${settings.defaultModel || "unknown"}\``,
    "",
    "## Packages",
    "",
    "| Package | Requested | Installed |",
    "| --- | --- | --- |",
    ...packages.map((entry) => {
      const name = packageName(entry);
      return `| \`${name}\` | \`${manifest.dependencies?.[name] || "not declared"}\` | \`${installedVersion(name)}\` |`;
    }),
    "",
    "## Enabled models",
    "",
    ...bulletList(settings.enabledModels || []),
    "",
    "## Local extensions",
    "",
    ...bulletList(localExtensions()),
    "",
  ];

  try {
    writeFileSync(INVENTORY_FILE, lines.join("\n"));
    ctx.ui.setStatus("pi-inventory", "inventory: refreshed");
    setTimeout(() => ctx.ui.setStatus("pi-inventory", undefined), 10_000).unref?.();
  } catch {
    ctx.ui.setStatus("pi-inventory", "inventory: refresh failed");
  }
}

export default function (pi: ExtensionAPI) {
  pi.on("session_start", async (_event, ctx) => {
    if (process.env.PI_GUIDE_AUTOUPDATE === "0") return;
    if (ctx.mode !== "tui") return;
    writeInventory(ctx);
  });
}
