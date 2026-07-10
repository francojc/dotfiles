import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { appendFileSync, mkdirSync, renameSync, writeFileSync } from "node:fs";
import { execFileSync } from "node:child_process";
import { basename, dirname, join } from "node:path";

const HOME = process.env.HOME || "/tmp";
const AGENT_DIR = process.env.PI_CODING_AGENT_DIR || join(HOME, ".pi", "agent");
const EVENTS_FILE = join(AGENT_DIR, "pi-waiting-events.jsonl");
const LAST_FILE = join(AGENT_DIR, "pi-last-notification.json");
const PI_WAITING_BIN = process.env.PI_WAITING_BIN || join(HOME, ".local", "bin", "pi-waiting");

const NOTIFY_TITLE = "Pi";

interface TmuxInfo {
  paneId: string;
  session: string;
  windowIndex: string;
  paneIndex: string;
  target: string;
}

interface WaitingRecord extends TmuxInfo {
  action: "waiting";
  id: string;
  cwd: string;
  project: string;
  sessionFile?: string;
  sessionName?: string;
  updatedAt: number;
  updatedAtIso: string;
}

interface ClearRecord {
  action: "clear";
  id: string;
  reason: string;
  updatedAt: number;
  updatedAtIso: string;
}

function ensureStateDir(): void {
  mkdirSync(dirname(EVENTS_FILE), { recursive: true });
}

function appendEvent(record: WaitingRecord | ClearRecord): void {
  ensureStateDir();
  appendFileSync(EVENTS_FILE, `${JSON.stringify(record)}\n`, "utf8");
}

function writeJsonAtomic(path: string, value: unknown): void {
  ensureStateDir();
  const tmp = `${path}.${process.pid}.tmp`;
  writeFileSync(tmp, `${JSON.stringify(value, null, 2)}\n`, "utf8");
  renameSync(tmp, path);
}

function cleanNotifyText(text: string): string {
  return text.replace(/[\x00-\x1f\x7f;]/g, " ").replace(/ +/g, " ").trim();
}

function notifyOSC777(title: string, body: string): void {
  process.stdout.write(`\x1b]777;notify;${cleanNotifyText(title)};${cleanNotifyText(body)}\x07`);
}

function notifyOSC99(title: string, body: string): void {
  const cleanTitle = cleanNotifyText(title);
  const cleanBody = cleanNotifyText(body);
  process.stdout.write(`\x1b]99;i=pi-ready:d=0;${cleanTitle}\x1b\\`);
  process.stdout.write(`\x1b]99;i=pi-ready:p=body;${cleanBody}\x1b\\`);
}

function terminalNotify(title: string, body: string): void {
  if (process.env.KITTY_WINDOW_ID) {
    notifyOSC99(title, body);
    return;
  }

  notifyOSC777(title, body);
}

function getTmuxInfo(): TmuxInfo | null {
  const paneId = process.env.TMUX_PANE;
  if (!paneId) return null;

  try {
    const format = "#{pane_id}\t#{session_name}\t#{window_index}\t#{pane_index}";
    const output = execFileSync("tmux", ["display-message", "-p", "-t", paneId, format], {
      encoding: "utf8",
      stdio: ["ignore", "pipe", "ignore"],
    }).trim();

    const [livePaneId, session, windowIndex, paneIndex] = output.split("\t");
    if (!livePaneId || !session || !windowIndex || !paneIndex) return null;

    return {
      paneId: livePaneId,
      session,
      windowIndex,
      paneIndex,
      target: `${session}:${windowIndex}.${paneIndex}`,
    };
  } catch {
    return null;
  }
}

function nowFields() {
  const updatedAt = Date.now();
  return {
    updatedAt,
    updatedAtIso: new Date(updatedAt).toISOString(),
  };
}

function formatAge(updatedAt: number): string {
  const seconds = Math.max(0, Math.floor((Date.now() - updatedAt) / 1000));
  if (seconds < 60) return `${seconds}s ago`;
  const minutes = Math.floor(seconds / 60);
  if (minutes < 60) return `${minutes}m ago`;
  const hours = Math.floor(minutes / 60);
  return `${hours}h ago`;
}

export default function (pi: ExtensionAPI) {
  let currentPaneId: string | undefined;

  function clearWaiting(reason: string): void {
    const id = currentPaneId || getTmuxInfo()?.paneId;
    if (!id) return;

    appendEvent({
      action: "clear",
      id,
      reason,
      ...nowFields(),
    });
  }

  pi.on("session_start", async () => {
    currentPaneId = getTmuxInfo()?.paneId;
  });

  pi.on("agent_start", async () => {
    clearWaiting("agent_start");
  });

  pi.on("agent_settled", async (_event, ctx) => {
    if (ctx.mode !== "tui") return;

    const tmux = getTmuxInfo();
    const project = basename(ctx.cwd) || ctx.cwd;
    terminalNotify(NOTIFY_TITLE, `Ready for input: ${project}`);

    if (!tmux) return;
    currentPaneId = tmux.paneId;

    const record: WaitingRecord = {
      action: "waiting",
      id: tmux.paneId,
      ...tmux,
      cwd: ctx.cwd,
      project,
      sessionFile: ctx.sessionManager.getSessionFile(),
      sessionName: pi.getSessionName(),
      ...nowFields(),
    };

    appendEvent(record);
    writeJsonAtomic(LAST_FILE, record);
  });

  pi.on("session_shutdown", async (event) => {
    clearWaiting(event.reason);
  });

  pi.registerCommand("waiting", {
    description: "List awaiting Pi agents and jump via tmux",
    handler: async (_args, ctx) => {
      if (!ctx.hasUI) return;

      const list = await pi.exec(PI_WAITING_BIN, ["--list"], { timeout: 5000 });
      if (list.code !== 0) {
        ctx.ui.notify(`pi-waiting failed: ${list.stderr || list.stdout}`.trim(), "error");
        return;
      }

      let records: WaitingRecord[] = [];
      try {
        records = JSON.parse(list.stdout) as WaitingRecord[];
      } catch {
        ctx.ui.notify("pi-waiting returned invalid JSON", "error");
        return;
      }

      if (records.length === 0) {
        ctx.ui.notify("No awaiting Pi agents", "info");
        return;
      }

      const labels = records.map((record) => `${record.project} · ${record.target} · ${formatAge(record.updatedAt)} · ${record.cwd}`);
      const choice = await ctx.ui.select("Awaiting Pi agents", labels);
      if (!choice) return;

      const index = labels.indexOf(choice);
      const record = records[index];
      if (!record) return;

      const jump = await pi.exec(PI_WAITING_BIN, ["--jump-id", record.id], { timeout: 5000 });
      if (jump.code !== 0) {
        ctx.ui.notify(`Jump failed: ${jump.stderr || jump.stdout}`.trim(), "error");
      }
    },
  });
}
