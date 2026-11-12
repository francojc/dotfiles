/**
 * Omarchy theme sync (host-conditional)
 *
 * On Omarchy hosts, `omarchy-theme-set-pi` writes the current system palette to
 * `~/.pi/agent/themes/omarchy-system.json`. When that file exists, this
 * extension applies it for the session; elsewhere (macOS) it does nothing and
 * the shared `settings.json` theme ("dark") applies.
 *
 * Why not `"theme": "omarchy-system"` in settings.json? settings.json is shared
 * via stow across hosts, and `ctx.ui.setTheme(name)` persists the name back
 * into it. Applying a loaded Theme *instance* does not persist, so the shared
 * file stays host-neutral.
 *
 * The file is watched so Omarchy theme switches recolor Pi live.
 *
 * Environment:
 *   PI_OMARCHY_THEME=0  – disable
 */

import { existsSync, watch, type FSWatcher } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";
import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";

const THEME_NAME = "omarchy-system";
const THEME_DIR = join(process.env.PI_CODING_AGENT_DIR ?? join(homedir(), ".pi", "agent"), "themes");
const THEME_FILE = `${THEME_NAME}.json`;

export default function (pi: ExtensionAPI) {
  let watcher: FSWatcher | undefined;
  let debounce: ReturnType<typeof setTimeout> | undefined;

  const apply = (ctx: ExtensionContext) => {
    if (!existsSync(join(THEME_DIR, THEME_FILE))) return;
    const theme = ctx.ui.getTheme(THEME_NAME);
    if (!theme) return; // invalid/half-written file; keep current theme
    ctx.ui.setTheme(theme);
  };

  pi.on("session_start", async (_event, ctx) => {
    if (process.env.PI_OMARCHY_THEME === "0" || !ctx.hasUI) return;
    if (!existsSync(join(THEME_DIR, THEME_FILE))) return;

    apply(ctx);

    watcher?.close();
    try {
      // Watch the directory: omarchy replaces the file via mv, which breaks file watches.
      watcher = watch(THEME_DIR, (_type, filename) => {
        if (filename && filename !== THEME_FILE) return;
        clearTimeout(debounce);
        debounce = setTimeout(() => apply(ctx), 150);
      });
    } catch {
      watcher = undefined;
    }
  });

  pi.on("session_shutdown", async () => {
    clearTimeout(debounce);
    watcher?.close();
    watcher = undefined;
  });
}
