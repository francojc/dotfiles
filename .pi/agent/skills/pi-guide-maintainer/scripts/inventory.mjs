#!/usr/bin/env node
import { existsSync, readdirSync, readFileSync, statSync } from "node:fs";
import { join, resolve } from "node:path";

const agentDir = resolve(process.env.PI_AGENT_DIR || join(process.env.HOME || "", ".pi", "agent"));

function readJson(path) {
  try {
    return JSON.parse(readFileSync(path, "utf8"));
  } catch {
    return null;
  }
}

function listFiles(dir, predicate) {
  if (!existsSync(dir)) return [];
  return readdirSync(dir)
    .map((name) => join(dir, name))
    .filter((path) => {
      try {
        return predicate(path, statSync(path));
      } catch {
        return false;
      }
    })
    .sort();
}

function extensionName(path) {
  const rel = path.startsWith(agentDir) ? path.slice(agentDir.length + 1) : path;
  return rel;
}

const settings = readJson(join(agentDir, "settings.json")) ?? {};
const npmPkg = readJson(join(agentDir, "npm", "package.json")) ?? {};
const keybindings = readJson(join(agentDir, "keybindings.json")) ?? {};

const extensionFiles = [
  ...listFiles(join(agentDir, "extensions"), (path, st) => st.isFile() && /\.[cm]?[jt]s$/.test(path)),
  ...listFiles(join(agentDir, "extensions"), (path, st) => st.isDirectory() && existsSync(join(path, "index.ts"))).map((path) => join(path, "index.ts")),
];

const skillDirs = listFiles(join(agentDir, "skills"), (path, st) => st.isDirectory() && existsSync(join(path, "SKILL.md")));

console.log(`# Pi inventory`);
console.log(`agentDir: ${agentDir}`);
console.log("");
console.log("## settings.packages");
for (const pkg of settings.packages ?? []) console.log(`- ${typeof pkg === "string" ? pkg : JSON.stringify(pkg)}`);
console.log("");
console.log("## npm dependencies");
for (const [name, version] of Object.entries(npmPkg.dependencies ?? {})) console.log(`- ${name}: ${version}`);
console.log("");
console.log("## local extensions");
for (const file of extensionFiles) console.log(`- ${extensionName(file)}`);
console.log("");
console.log("## skills");
for (const dir of skillDirs) console.log(`- ${extensionName(join(dir, "SKILL.md"))}`);
console.log("");
console.log("## keybindings");
for (const [id, keys] of Object.entries(keybindings)) console.log(`- ${id}: ${Array.isArray(keys) ? keys.join(", ") : keys}`);
