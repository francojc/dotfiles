import type { ExtensionAPI, ExtensionCommandContext, ExtensionContext } from "@mariozechner/pi-coding-agent";
import { Key } from "@mariozechner/pi-tui";

const ASIDE_MODE_TOOLS = ["read", "bash", "web_search"];
const ASIDE_STATE_TYPE = "aside-mode";
const ASIDE_CONTEXT_TYPE = "aside-mode-context";

const DESTRUCTIVE_PATTERNS = [
  /\brm\b/i,
  /\brmdir\b/i,
  /\bmv\b/i,
  /\bcp\b/i,
  /\bmkdir\b/i,
  /\btouch\b/i,
  /\bchmod\b/i,
  /\bchown\b/i,
  /\bchgrp\b/i,
  /\bln\b/i,
  /\btee\b/i,
  /\btruncate\b/i,
  /\bdd\b/i,
  /\binstall\b/i,
  /(^|[^<])>(?!>)/,
  />>/,
  /\bnpm\s+(install|uninstall|update|ci|link|publish)\b/i,
  /\byarn\s+(add|remove|install|publish)\b/i,
  /\bpnpm\s+(add|remove|install|publish)\b/i,
  /\bpip\s+(install|uninstall)\b/i,
  /\buv\s+(add|remove|sync|pip\s+install)\b/i,
  /\bapt(-get)?\s+(install|remove|purge|update|upgrade)\b/i,
  /\bbrew\s+(install|uninstall|upgrade)\b/i,
  /\bgit\s+(add|commit|push|pull|merge|rebase|reset|checkout|switch|branch\s+-[dD]|stash|cherry-pick|revert|tag|init|clone)\b/i,
  /\bsudo\b/i,
  /\bsu\b/i,
  /\bkill\b/i,
  /\bpkill\b/i,
  /\bkillall\b/i,
  /\breboot\b/i,
  /\bshutdown\b/i,
  /\bvim?\b/i,
  /\bnano\b/i,
  /\bemacs\b/i,
  /\bcode\b/i,
];

const SAFE_PATTERNS = [
  /^\s*pwd\b/i,
  /^\s*ls\b/i,
  /^\s*find\b/i,
  /^\s*grep\b/i,
  /^\s*rg\b/i,
  /^\s*fd\b/i,
  /^\s*tree\b/i,
  /^\s*file\b/i,
  /^\s*stat\b/i,
  /^\s*du\b/i,
  /^\s*df\b/i,
  /^\s*wc\b/i,
  /^\s*sort\b/i,
  /^\s*uniq\b/i,
  /^\s*cut\b/i,
  /^\s*awk\b/i,
  /^\s*sed\s+-n\b/i,
  /^\s*head\b/i,
  /^\s*tail\b/i,
  /^\s*git\s+(status|log|diff|show|branch|remote|config\s+--get|rev-parse|ls-files)\b/i,
  /^\s*which\b/i,
  /^\s*whereis\b/i,
  /^\s*type\b/i,
  /^\s*env\b/i,
  /^\s*printenv\b/i,
  /^\s*uname\b/i,
  /^\s*whoami\b/i,
  /^\s*id\b/i,
  /^\s*date\b/i,
  /^\s*ps\b/i,
  /^\s*top\b/i,
  /^\s*htop\b/i,
  /^\s*bat\b/i,
  /^\s*exa\b/i,
  /^\s*echo\b/i,
  /^\s*printf\b/i,
  /^\s*curl\b/i,
  /^\s*wget\s+-O\s*-\b/i,
  /^\s*jq\b/i,
];

interface AsideStateEntry {
  enabled: boolean;
  previousTools?: string[];
  timestamp: string;
}

function isSafeReadOnlyCommand(command: string): boolean {
  const isDestructive = DESTRUCTIVE_PATTERNS.some((pattern) => pattern.test(command));
  const isSafe = SAFE_PATTERNS.some((pattern) => pattern.test(command));
  return !isDestructive && isSafe;
}

function normalizeQuestion(args: string): string | undefined {
  const trimmed = args.trim();
  return trimmed.length > 0 ? trimmed : undefined;
}

function isExitCommand(args: string): boolean {
  const trimmed = args.trim().toLowerCase();
  return ["off", "exit", "leave", "end", "main", "resume"].includes(trimmed);
}

export default function asideModeExtension(pi: ExtensionAPI) {
  let asideEnabled = false;
  let previousTools: string[] | undefined;

  function getAvailableAsideTools(): string[] {
    const allToolNames = new Set(pi.getAllTools().map((tool) => tool.name));
    return ASIDE_MODE_TOOLS.filter((tool) => allToolNames.has(tool));
  }

  function updateStatus(ctx: ExtensionContext): void {
    if (asideEnabled) {
      ctx.ui.setStatus("aside-mode", ctx.ui.theme.fg("warning", ctx.ui.theme.bold("◉ ASIDE")));
    } else {
      ctx.ui.setStatus("aside-mode", undefined);
    }
  }

  function persistState(): void {
    pi.appendEntry<AsideStateEntry>(ASIDE_STATE_TYPE, {
      enabled: asideEnabled,
      previousTools,
      timestamp: new Date().toISOString(),
    });
  }

  function activateAside(ctx: ExtensionContext): void {
    if (asideEnabled) {
      updateStatus(ctx);
      return;
    }

    previousTools = pi.getActiveTools();
    asideEnabled = true;
    pi.setActiveTools(getAvailableAsideTools());
    persistState();
    updateStatus(ctx);
    ctx.ui.notify("Aside mode on. Read-only chat. No writes. No memory consolidation.", "info");
  }

  function deactivateAside(ctx: ExtensionContext): void {
    if (!asideEnabled) {
      updateStatus(ctx);
      return;
    }

    asideEnabled = false;
    const allToolNames = new Set(pi.getAllTools().map((tool) => tool.name));
    const restoreTools = previousTools && previousTools.length > 0 ? previousTools : ["read", "bash", "edit", "write"];
    pi.setActiveTools(restoreTools.filter((tool) => allToolNames.has(tool)));
    persistState();
    updateStatus(ctx);
    ctx.ui.notify("Aside mode off. Main workflow restored.", "info");
  }

  async function handleAsideCommand(args: string, ctx: ExtensionCommandContext): Promise<void> {
    await ctx.waitForIdle();

    if (isExitCommand(args)) {
      deactivateAside(ctx);
      return;
    }

    const question = normalizeQuestion(args);

    if (!asideEnabled) {
      activateAside(ctx);
    }

    if (question) {
      pi.sendUserMessage(question);
    }
  }

  pi.registerCommand("aside", {
    description: "Toggle aside mode. Read-only chat with no write access and no memory consolidation.",
    handler: async (args, ctx) => {
      await handleAsideCommand(args, ctx);
    },
  });

  pi.registerCommand("main", {
    description: "Exit aside mode and return to normal workflow.",
    handler: async (_args, ctx) => {
      await ctx.waitForIdle();
      deactivateAside(ctx);
    },
  });

  pi.registerShortcut(Key.ctrlAlt("a"), {
    description: "Toggle aside mode",
    handler: async (ctx) => {
      if (asideEnabled) {
        deactivateAside(ctx);
      } else {
        activateAside(ctx);
      }
    },
  });

  pi.on("session_start", async (_event, ctx) => {
    const entries = ctx.sessionManager.getBranch();
    const lastAsideEntry = entries
      .filter((entry: { type: string; customType?: string }) => entry.type === "custom" && entry.customType === ASIDE_STATE_TYPE)
      .pop() as { data?: AsideStateEntry } | undefined;

    if (lastAsideEntry?.data) {
      asideEnabled = Boolean(lastAsideEntry.data.enabled);
      previousTools = lastAsideEntry.data.previousTools;
    }

    if (asideEnabled) {
      pi.setActiveTools(getAvailableAsideTools());
    }

    updateStatus(ctx);
  });

  pi.on("context", async (event) => {
    if (asideEnabled) return;

    return {
      messages: event.messages.filter((message) => {
        const candidate = message as { customType?: string };
        return candidate.customType !== ASIDE_CONTEXT_TYPE;
      }),
    };
  });

  pi.on("before_agent_start", async (event) => {
    if (!asideEnabled) return;

    return {
      message: {
        customType: ASIDE_CONTEXT_TYPE,
        content: `[ASIDE MODE ACTIVE]\nYou are in aside mode. Treat this as off-record exploratory chat.\n\nRules:\n- Hard lock: no write-capable tools.\n- Available tools: read, bash, web_search.\n- Bash must stay read-only. No file mutation. No installs. No git writes.\n- Do not update memory or create durable session knowledge from aside content.\n- Focus on explanation, exploration, comparison, brainstorming, and learning.\n- If user wants implementation, tell them to exit aside mode with /main or /aside off first.`,
        display: false,
      },
      systemPrompt: `${event.systemPrompt}\n\n# Aside Mode\n\nYou are in temporary aside mode. Explore ideas, answer questions, and help user think. Do not perform any write action or any mutating command. Treat aside content as excluded from memory consolidation.`,
    };
  });

  pi.on("tool_call", async (event, ctx) => {
    if (!asideEnabled) return;

    if (!ASIDE_MODE_TOOLS.includes(event.toolName)) {
      return {
        block: true,
        reason: `Aside mode blocks tool \"${event.toolName}\". Exit with /main or /aside off for write access.`,
      };
    }

    if (event.toolName === "bash") {
      const command = String(event.input.command ?? "");
      if (!isSafeReadOnlyCommand(command)) {
        return {
          block: true,
          reason: `Aside mode allows read-only bash only. Blocked command: ${command}`,
        };
      }
    }

    if (ctx.hasUI) {
      updateStatus(ctx);
    }
  });
}
