/**
 * Simon's Working Indicator
 *
 * Replaces the default Pi spinner with a characterful animated indicator.
 * Multiple presets, switchable via /indicator command.
 *
 * Modes:
 *   schwa    – ə breathes (default, for the linguistics prof)
 *   eye      – Simon blinks at you
 *   pulse    – dot grows/shrinks in accent color
 *   bounce   – ball bounce
 *   spinner  – colorful braille spinner
 *   none     – hidden
 *   default  – restore Pi's built-in spinner
 */

import type { ExtensionAPI, ExtensionContext, WorkingIndicatorOptions } from "@earendil-works/pi-coding-agent";

type IndicatorMode = "schwa" | "eye" | "pulse" | "bounce" | "spinner" | "none" | "default";

// Theme colors hardcoded to match ghostty-sync Gruvbox palette
const ACCENT = "\x1b[38;2;177;98;134m"; // #b16286 mauve
const RESET = "\x1b[39m";

function a(text: string): string {
  return `${ACCENT}${text}${RESET}`;
}

// ── Nerdy verb banks ──
const MSG_SCHWA = [
  "mulling…", "parsing…", "glossing…", "brooding…", "theorizing…",
  "musing…", "puzzling…", "deriving…", "surmising…", "deliberating…",
];
const MSG_EYE = [
  "watching…", "observing…", "scrutinizing…", "peering…", "blinking…",
  "gazing…", "squinting…", "monitoring…", "inspecting…", "ogling…",
];
const MSG_PULSE = [
  "throbbing…", "pulsing…", "beating…", "humming…", "vibrating…",
  "resonating…", "oscillating…", "reverberating…",
];
const MSG_BOUNCE = [
  "bouncing…", "boinging…", "springing…", "ricocheting…", "rebounding…",
  "pogoing…", "trampolining…", "careening…",
];
const MSG_SPINNER = [
  "cranking…", "churning…", "crunching…", "masticating…", "ruminating…",
  "cogitating…", "computing…", "processing…", "iterating…", "recursing…",
  "compiling…", "linking…", "optimizing…", "benchmarking…", "refactoring…",
  "debugging…", "tracing…", "profiling…", "binary-searching…", "backtracking…",
];

function msgFor(mode: IndicatorMode): string[] {
  switch (mode) {
    case "schwa":   return MSG_SCHWA;
    case "eye":     return MSG_EYE;
    case "pulse":   return MSG_PULSE;
    case "bounce":  return MSG_BOUNCE;
    case "spinner": return MSG_SPINNER;
    default:        return [];
  }
}

function getIndicator(mode: IndicatorMode): WorkingIndicatorOptions | undefined {
  switch (mode) {
    case "schwa":
      return {
        frames: [
          a("ə"),  // rest
          a("ə"),  // rest
          a("ə"),  // rest
          a("Ə"),  // inhale
          a("ə"),  // exhale
        ],
        intervalMs: 300,
      };

    case "eye":
      return {
        frames: [
          a("⊙"), // wide
          a("⊙"), // wide
          a("◉"), // narrowing
          a("●"), // blink
          a("◉"), // opening
        ],
        intervalMs: 200,
      };

    case "pulse":
      return {
        frames: [
          a("·"),
          a("•"),
          a("●"),
          a("•"),
        ],
        intervalMs: 150,
      };

    case "bounce":
      return {
        frames: [
          a("·"),
          a("•"),
          a("○"),
          a("●"),
          a("○"),
          a("•"),
        ],
        intervalMs: 120,
      };

    case "spinner":
      return {
        frames: ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"].map((f) => a(f)),
        intervalMs: 80,
      };

    case "none":
      return { frames: [] };

    case "default":
      return undefined;
  }
}

function describeMode(mode: IndicatorMode): string {
  const descriptions: Record<IndicatorMode, string> = {
    schwa: "ə breathing",
    eye: "Simon blinking",
    pulse: "dot pulse",
    bounce: "ball bounce",
    spinner: "braille spinner",
    none: "hidden",
    default: "Pi default",
  };
  return descriptions[mode];
}

// ── Per-session state (module-level; only one session active at a time) ─────

type SessionState = {
  mode: IndicatorMode;
  msgTimer: ReturnType<typeof setInterval> | null;
};

let current: SessionState = { mode: "schwa", msgTimer: null };

function clearTimer(): void {
  if (current.msgTimer) {
    clearInterval(current.msgTimer);
    current.msgTimer = null;
  }
}

export default function (pi: ExtensionAPI) {
  const startCycling = (ctx: ExtensionContext) => {
    const messages = msgFor(current.mode);
    if (messages.length === 0) {
      ctx.ui.setWorkingMessage(); // restore default
      return;
    }
    let i = 0;
    ctx.ui.setWorkingMessage(messages[0]);
    current.msgTimer = setInterval(() => {
      i = (i + 1) % messages.length;
      // Guard against stale ctx after session replacement
      try {
        ctx.ui.setWorkingMessage(messages[i]);
      } catch {
        clearTimer();
      }
    }, 1600); // rotate every ~1.6s for readability
  };

  const stopCycling = (ctx: ExtensionContext) => {
    clearTimer();
    ctx.ui.setWorkingMessage(); // restore default
  };

  const apply = (ctx: ExtensionContext) => {
    clearTimer();
    ctx.ui.setWorkingIndicator(getIndicator(current.mode));
    startCycling(ctx);
    ctx.ui.setStatus("indicator", undefined);
  };

  pi.on("session_start", async (_event, ctx) => {
    apply(ctx);
  });

  pi.on("session_shutdown", async (_event, ctx) => {
    clearTimer();
    ctx.ui.setWorkingMessage();
  });

  pi.registerCommand("indicator", {
    description: "Switch working indicator: schwa, eye, pulse, bounce, spinner, none, default",
    handler: async (args, ctx) => {
      const next = args.trim().toLowerCase() as IndicatorMode;
      const valid: IndicatorMode[] = ["schwa", "eye", "pulse", "bounce", "spinner", "none", "default"];

      if (!next) {
        ctx.ui.notify(`Current indicator: ${describeMode(current.mode)}`, "info");
        return;
      }

      if (!valid.includes(next)) {
        ctx.ui.notify(`Usage: /indicator [${valid.join("|")}]`, "error");
        return;
      }

      current.mode = next;
      apply(ctx);
      ctx.ui.notify(`Indicator → ${describeMode(current.mode)}`, "info");
    },
  });
}
