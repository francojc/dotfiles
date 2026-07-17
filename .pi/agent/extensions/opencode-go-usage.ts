import { execFile } from "node:child_process";
import { promisify } from "node:util";
import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import {
	formatRawCompactSubscriptionStatus,
	formatResetDuration,
	usedPercentToRemaining,
	type SubscriptionUsageSnapshot,
	type SubscriptionUsageWindow,
} from "./subscription-usage-status";

const execFileAsync = promisify(execFile);

const STATUS_KEY = "opencode-go-usage";
const DASHBOARD_BASE_URL = "https://opencode.ai";
const PASS_WORKSPACE_ENTRY = "USER/OPENCODE_GO_WORKSPACE_ID";
const PASS_AUTH_COOKIE_ENTRY = "COOKIE/OPENCODE_GO_AUTH_COOKIE";
const FRESH_CACHE_MS = 60_000;
const STALE_CACHE_MS = 10 * 60_000;
const REQUEST_TIMEOUT_MS = 3_000;
const POLL_INTERVAL_MS = 60_000;
const START_DELAY_MS = 3_000;

type CachedSnapshot = {
	snapshot: SubscriptionUsageSnapshot;
	freshUntil: number;
	staleUntil: number;
};

type FetchResult =
	| { ok: true; snapshot: SubscriptionUsageSnapshot; stale: boolean }
	| { ok: false; error: string };

let cache: CachedSnapshot | undefined;
let inflight: Promise<FetchResult> | undefined;

async function readPassSecret(entry: string): Promise<string | undefined> {
	try {
		const { stdout } = await execFileAsync("pass", ["show", entry], { timeout: REQUEST_TIMEOUT_MS });
		return stdout.split(/\r?\n/).map((line) => line.trim()).find(Boolean);
	} catch {
		return undefined;
	}
}

async function configuredValue(environmentName: "OPENCODE_GO_WORKSPACE_ID" | "OPENCODE_GO_AUTH_COOKIE", passEntry: string): Promise<string | undefined> {
	const environmentValue = process.env[environmentName]?.trim();
	return environmentValue || readPassSecret(passEntry);
}

function isOpenCodeGoProvider(provider: string | undefined): boolean {
	return provider === "opencode-go";
}

async function dashboardCredentials(): Promise<{ workspaceID: string; authCookie: string } | undefined> {
	const [workspaceID, authCookie] = await Promise.all([
		configuredValue("OPENCODE_GO_WORKSPACE_ID", PASS_WORKSPACE_ENTRY),
		configuredValue("OPENCODE_GO_AUTH_COOKIE", PASS_AUTH_COOKIE_ENTRY),
	]);
	return workspaceID && authCookie ? { workspaceID, authCookie } : undefined;
}

function parseWindow(html: string, name: "rollingUsage" | "weeklyUsage" | "monthlyUsage"): SubscriptionUsageWindow | undefined {
	const number = String.raw`(-?\d+(?:\.\d+)?)`;
	const usageFirst = new RegExp(String.raw`${name}:\$R\[\d+\]=\{[^}]*usagePercent:${number}[^}]*resetInSec:${number}[^}]*\}`);
	const resetFirst = new RegExp(String.raw`${name}:\$R\[\d+\]=\{[^}]*resetInSec:${number}[^}]*usagePercent:${number}[^}]*\}`);
	const usageMatch = usageFirst.exec(html);
	const resetMatch = resetFirst.exec(html);
	const usedPercent = Number(usageMatch?.[1] ?? resetMatch?.[2]);
	const resetInSec = Number(usageMatch?.[2] ?? resetMatch?.[1]);
	if (!Number.isFinite(usedPercent) || !Number.isFinite(resetInSec)) return undefined;
	return {
		remainingPercent: usedPercentToRemaining(usedPercent),
		resetAt: new Date(Date.now() + Math.max(0, resetInSec) * 1_000),
	};
}

function parseDashboard(html: string): SubscriptionUsageSnapshot | undefined {
	const snapshot: SubscriptionUsageSnapshot = {
		fiveHour: parseWindow(html, "rollingUsage"),
		weekly: parseWindow(html, "weeklyUsage"),
		monthly: parseWindow(html, "monthlyUsage"),
		fetchedAt: new Date(),
	};
	return snapshot.fiveHour || snapshot.weekly || snapshot.monthly ? snapshot : undefined;
}

async function fetchDashboardSnapshot(): Promise<FetchResult> {
	const credentials = await dashboardCredentials();
	if (!credentials) return { ok: false, error: "OpenCode Go usage credentials are unavailable" };

	const controller = new AbortController();
	const timeout = setTimeout(() => controller.abort(), REQUEST_TIMEOUT_MS);
	try {
		const workspaceID = encodeURIComponent(credentials.workspaceID);
		const response = await fetch(`${DASHBOARD_BASE_URL}/workspace/${workspaceID}/go`, {
			headers: {
				Accept: "text/html",
				Cookie: `auth=${credentials.authCookie}`,
				"User-Agent": "Mozilla/5.0 (Pi OpenCode Go usage status)",
			},
			signal: controller.signal,
		});
		if (!response.ok) return { ok: false, error: "OpenCode Go dashboard authentication or request failed" };
		const snapshot = parseDashboard(await response.text());
		if (!snapshot) return { ok: false, error: "OpenCode Go dashboard usage data is unavailable" };
		return { ok: true, snapshot, stale: false };
	} catch {
		return { ok: false, error: "OpenCode Go usage request failed" };
	} finally {
		clearTimeout(timeout);
	}
}

async function getSnapshot(force = false): Promise<FetchResult> {
	const now = Date.now();
	if (!force && cache && now < cache.freshUntil) return { ok: true, snapshot: cache.snapshot, stale: false };
	if (!force && inflight) return inflight;

	const request = fetchDashboardSnapshot().then((result): FetchResult => {
		if (result.ok) {
			cache = {
				snapshot: result.snapshot,
				freshUntil: Date.now() + FRESH_CACHE_MS,
				staleUntil: Date.now() + STALE_CACHE_MS,
			};
			return result;
		}
		if (cache && Date.now() < cache.staleUntil) return { ok: true, snapshot: cache.snapshot, stale: true };
		return result;
	});
	inflight = request;
	try {
		return await request;
	} finally {
		if (inflight === request) inflight = undefined;
	}
}

function detailLines(snapshot: SubscriptionUsageSnapshot, stale: boolean): string[] {
	const line = (label: string, window: SubscriptionUsageWindow | undefined): string => {
		if (!window) return `  ${label.padEnd(8)} unavailable`;
		const reset = formatResetDuration(window.resetAt) ?? "unknown";
		return `  ${label.padEnd(8)} ${window.remainingPercent.toFixed(0)}% remaining · resets in ${reset}`;
	};
	return [
		stale ? "Cached OpenCode Go usage (refresh failed):" : "OpenCode Go usage:",
		line("5-hour", snapshot.fiveHour),
		line("Weekly", snapshot.weekly),
		line("Monthly", snapshot.monthly),
		`  Fetched  ${snapshot.fetchedAt.toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" })}`,
	];
}

export default function (pi: ExtensionAPI) {
	let pollTimer: ReturnType<typeof setTimeout> | undefined;
	let pollGeneration = 0;
	let setStatus: ((id: string, text: string | undefined) => void) | undefined;

	function stopPolling(): void {
		pollGeneration += 1;
		setStatus = undefined;
		if (pollTimer) clearTimeout(pollTimer);
		pollTimer = undefined;
	}

	async function refreshStatus(generation: number): Promise<void> {
		if (generation !== pollGeneration || !setStatus) return;
		const result = await getSnapshot();
		// stopPolling bumps pollGeneration, so a stale generation check alone
		// covers cancellation that happened during the await.
		if (generation === pollGeneration) {
			if (result.ok) {
				setStatus?.(STATUS_KEY, formatRawCompactSubscriptionStatus("opencode-go", result.snapshot) ?? "OpenCode Go unavailable");
			} else {
				setStatus?.(STATUS_KEY, "OpenCode Go unavailable");
			}
		}
		if (generation === pollGeneration) {
			pollTimer = setTimeout(() => void refreshStatus(generation), POLL_INTERVAL_MS);
		}
	}

	function startPolling(statusWriter: (id: string, text: string | undefined) => void): void {
		stopPolling();
		setStatus = statusWriter;
		const generation = ++pollGeneration;
		pollTimer = setTimeout(() => void refreshStatus(generation), START_DELAY_MS);
	}

	function syncStatus(ctx: ExtensionContext, provider: string | undefined): void {
		stopPolling();
		if (!isOpenCodeGoProvider(provider)) {
			ctx.ui.setStatus(STATUS_KEY, undefined);
			return;
		}
		ctx.ui.setStatus(STATUS_KEY, "OpenCode Go loading…");
		startPolling(ctx.ui.setStatus.bind(ctx.ui));
	}

	pi.on("session_start", async (_event, ctx) => {
		syncStatus(ctx, ctx.model?.provider);
	});

	pi.on("model_select", async (event, ctx) => {
		syncStatus(ctx, event.model.provider);
	});

	pi.on("session_shutdown", async (_event, ctx) => {
		stopPolling();
		ctx.ui.setStatus(STATUS_KEY, undefined);
	});

	pi.registerCommand("opencode-go-status", {
		description: "Show OpenCode Go subscription usage from the authenticated dashboard",
		handler: async (args, ctx) => {
		const force = args.trim() === "--refresh";
		const result = await getSnapshot(force);
		if (!result.ok) {
			await ctx.ui.select("OpenCode Go Usage", [result.error]);
			return;
		}
		await ctx.ui.select("OpenCode Go Usage", detailLines(result.snapshot, result.stale));
		},
	});
}
