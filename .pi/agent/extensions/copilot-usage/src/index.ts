/**
 * pi-copilot-usage
 *
 * A pi extension that uses the GitHub Copilot agents SDK (@github/copilot-sdk)
 * to surface your GitHub Copilot Pro plan usage directly inside pi.
 *
 * Features:
 *  - /copilot          – full usage dashboard: quota + sessions overview
 *  - /copilot-quota    – focused quota / premium-requests panel
 *  - /copilot-sessions – browse all sessions; select one to inspect details
 *  - /copilot-models   – model list with billing multipliers
 *  - copilot_usage     – LLM-callable tool that returns structured usage JSON
 *  - Footer status     – live premium-interactions remaining indicator
 *
 * Quota data comes from the GitHub API (/copilot_internal/user via `gh`).
 * Session data comes from the Copilot agents SDK (CopilotClient.listSessions()).
 */

import { execFile } from "node:child_process";
import { join } from "node:path";
import { promisify } from "node:util";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { StringEnum } from "@earendil-works/pi-ai";
import { Type } from "typebox";
import type {
	GetAuthStatusResponse,
	GetStatusResponse,
	ModelInfo,
	SessionMetadata,
} from "@github/copilot-sdk";

const execFileAsync = promisify(execFile);

// ---------------------------------------------------------------------------
// Types
// ---------------------------------------------------------------------------

interface QuotaSnapshot {
	quota_id: string;
	entitlement: number;
	remaining: number;
	quota_remaining: number;
	overage_count: number;
	overage_permitted: boolean;
	percent_remaining: number;
	unlimited: boolean;
	timestamp_utc: string;
	has_quota?: boolean;
	overage_entitlement?: number;
	quota_reset_at?: number;
	token_based_billing?: boolean;
}

interface CopilotUserInfo {
	login: string;
	copilot_plan: string;
	access_type_sku: string;
	quota_reset_date_utc: string;
	quota_snapshots: Record<string, QuotaSnapshot>;
	endpoints: Record<string, string>;
	token_based_billing?: boolean;
}

interface SessionSummary {
	sessionId: string;
	startTime: string;
	modifiedTime: string;
	durationMinutes: number;
	isActive: boolean;
	summary?: string;
	repository?: string;
	branch?: string;
	cwd?: string;
}

interface ModelBillingDisplay {
	id: string;
	name: string;
	multiplier?: number;
	free: boolean;
	tokenPricing?: {
		batchSize?: number;
		input?: number;
		output?: number;
		cache?: number;
	};
}

interface UsageStats {
	// Plan / quota
	login?: string;
	copilotPlan?: string;
	cliVersion?: string;
	quotaResetDate?: string;
	quotaSnapshots?: Record<string, QuotaSnapshot>;
	tokenBasedBilling?: boolean;
	// Models
	models?: ModelBillingDisplay[];
	// Session counts
	fetchedAt: string;
	total: number;
	today: number;
	thisWeek: number;
	thisMonth: number;
	byRepository: Record<string, number>;
	byDirectory: Record<string, number>;
	avgDurationMinutes: number;
	activeSessions: number;
	recentSessions: SessionSummary[];
}

// Shared shape returned by fetchAll — used to type the TTL cache (fix #3)
interface FetchResult {
	sessions: SessionMetadata[];
	userInfo?: CopilotUserInfo;
	status?: GetStatusResponse;
	auth?: GetAuthStatusResponse;
	models?: ModelInfo[];
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

const MS_PER_MIN = 60_000;
const ACTIVE_THRESHOLD_MS = 15 * MS_PER_MIN;

const GLYPH_LOADING = "";
const GLYPH_CONNECTED = "";
const GLYPH_WARNING = "";
const GLYPH_ERROR = "";

type QuotaThreshold = "healthy" | "warning" | "critical";

function startOfDay(d: Date): Date {
	return new Date(d.getFullYear(), d.getMonth(), d.getDate());
}
function startOfWeek(d: Date): Date {
	const s = startOfDay(d);
	s.setDate(s.getDate() - s.getDay());
	return s;
}
function startOfMonth(d: Date): Date {
	return new Date(d.getFullYear(), d.getMonth(), 1);
}
function shortPath(cwd: string): string {
	const parts = cwd.replace(/\\/g, "/").split("/").filter(Boolean);
	return parts.length > 2 ? parts.slice(-2).join("/") : cwd;
}
function fmtDate(iso: string): string {
	return new Date(iso).toLocaleDateString(undefined, { month: "short", day: "numeric" });
}
function fmtTime(iso: string): string {
	return new Date(iso).toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" });
}
function fmtDuration(minutes: number): string {
	if (minutes < 1) return "<1m";
	if (minutes < 60) return `${minutes}m`;
	return `${Math.floor(minutes / 60)}h ${minutes % 60}m`;
}
function bar(label: string, width = 40): string {
	return `── ${label} ${"─".repeat(Math.max(0, width - label.length - 4))}`;
}
function pad(s: string, n: number): string {
	return s.padEnd(n);
}

function billingDisplayForModel(m: ModelInfo): ModelBillingDisplay {
	type RuntimeBilling = {
		multiplier?: number;
		token_prices?: {
			batch_size?: number;
			input_price?: number;
			output_price?: number;
			cache_price?: number;
		};
	};

	const billing = m.billing as RuntimeBilling | undefined;
	const multiplier = billing?.multiplier;
	const prices = billing?.token_prices;
	const hasTokenCost = !!prices && [prices.input_price, prices.output_price, prices.cache_price].some((price) => typeof price === "number" && price > 0);
	return {
		id: m.id,
		name: (m as { name?: string }).name ?? m.id,
		multiplier,
		free: multiplier === 0 || (!multiplier && !hasTokenCost),
		tokenPricing: hasTokenCost ? {
			batchSize: prices?.batch_size,
			input: prices?.input_price,
			output: prices?.output_price,
			cache: prices?.cache_price,
		} : undefined,
	};
}

function modelCostLabel(m: ModelBillingDisplay): string {
	if (m.multiplier !== undefined) return m.multiplier === 1 ? "1×" : `${m.multiplier}×`;
	if (m.tokenPricing) return "tokens";
	return "included";
}

function clampPercent(percent: number): number {
	return Math.max(0, Math.min(100, Number.isFinite(percent) ? percent : 0));
}

function quotaThreshold(percentRemaining: number): QuotaThreshold {
	const pct = clampPercent(percentRemaining);
	if (pct > 25) return "healthy";
	if (pct > 10) return "warning";
	return "critical";
}

function quotaThresholdGlyph(percentRemaining: number): string {
	const threshold = quotaThreshold(percentRemaining);
	if (threshold === "healthy") return GLYPH_CONNECTED;
	if (threshold === "warning") return GLYPH_WARNING;
	return GLYPH_ERROR;
}

function remainingBar(percentRemaining: number, width = 10): string {
	const pct = clampPercent(percentRemaining);
	const filled = Math.round((pct / 100) * width);
	const empty = width - filled;
	return `[${"█".repeat(filled)}${"░".repeat(empty)}]`;
}

// ---------------------------------------------------------------------------
// GitHub API – quota data
// ---------------------------------------------------------------------------

async function fetchCopilotUserInfo(): Promise<CopilotUserInfo> {
	const { stdout } = await execFileAsync("gh", ["api", "/copilot_internal/user"]);
	return JSON.parse(stdout) as CopilotUserInfo;
}

// ---------------------------------------------------------------------------
// Stats computation
// ---------------------------------------------------------------------------

function computeStats(
	sessions: SessionMetadata[],
	userInfo?: CopilotUserInfo,
	status?: GetStatusResponse,
	auth?: GetAuthStatusResponse,
	models?: ModelInfo[],
): UsageStats {
	const now = new Date();
	const todayStart = startOfDay(now).getTime();
	const weekStart = startOfWeek(now).getTime();
	const monthStart = startOfMonth(now).getTime();

	let today = 0, thisWeek = 0, thisMonth = 0, activeSessions = 0, totalDurationMs = 0;
	const byRepository: Record<string, number> = {};
	const byDirectory: Record<string, number> = {};

	const sorted = [...sessions].sort((a, b) => b.modifiedTime.getTime() - a.modifiedTime.getTime());

	for (const s of sessions) {
		const start = s.startTime.getTime();
		if (start >= todayStart) today++;
		if (start >= weekStart) thisWeek++;
		if (start >= monthStart) thisMonth++;
		totalDurationMs += Math.max(0, s.modifiedTime.getTime() - s.startTime.getTime());
		if (now.getTime() - s.modifiedTime.getTime() < ACTIVE_THRESHOLD_MS) activeSessions++;
		if (s.context?.repository) {
			const r = s.context.repository;
			byRepository[r] = (byRepository[r] ?? 0) + 1;
		}
		if (s.context?.cwd) {
			const d = shortPath(s.context.cwd);
			byDirectory[d] = (byDirectory[d] ?? 0) + 1;
		}
	}

	const recentSessions: SessionSummary[] = sorted.slice(0, 20).map((s) => ({
		sessionId: s.sessionId,
		startTime: s.startTime.toISOString(),
		modifiedTime: s.modifiedTime.toISOString(),
		durationMinutes: Math.round(Math.max(0, s.modifiedTime.getTime() - s.startTime.getTime()) / MS_PER_MIN),
		isActive: now.getTime() - s.modifiedTime.getTime() < ACTIVE_THRESHOLD_MS,
		summary: s.summary,
		repository: s.context?.repository,
		branch: s.context?.branch,
		cwd: s.context?.cwd,
	}));

	const modelList = models?.map(billingDisplayForModel);

	return {
		login: auth?.login ?? userInfo?.login,
		copilotPlan: userInfo?.copilot_plan ?? "unknown",
		cliVersion: status?.version,
		quotaResetDate: userInfo?.quota_reset_date_utc,
		quotaSnapshots: userInfo?.quota_snapshots,
		tokenBasedBilling: userInfo?.token_based_billing ?? userInfo?.quota_snapshots?.premium_interactions?.token_based_billing,
		models: modelList,
		fetchedAt: now.toISOString(),
		total: sessions.length,
		today,
		thisWeek,
		thisMonth,
		byRepository,
		byDirectory,
		avgDurationMinutes: sessions.length > 0 ? Math.round(totalDurationMs / sessions.length / MS_PER_MIN) : 0,
		activeSessions,
		recentSessions,
	};
}

// ---------------------------------------------------------------------------
// TUI line formatters
// ---------------------------------------------------------------------------

function quotaUnitLabel(stats: UsageStats): string {
	return stats.tokenBasedBilling ? "premium units" : "premium interactions";
}

function quotaValue(q: QuotaSnapshot): number {
	return typeof q.quota_remaining === "number" ? q.quota_remaining : q.remaining;
}

function formatNumber(value: number, digits = 1): string {
	return Number.isInteger(value) ? String(value) : value.toFixed(digits);
}

function quotaPercentText(percent: number, digits = 0): string {
	return `${clampPercent(percent).toFixed(digits)}%`;
}

function formatQuotaStatus(q?: QuotaSnapshot, fallback = "Copilot"): string {
	if (!q) return `${GLYPH_CONNECTED} ${fallback}`;
	const pct = clampPercent(q.percent_remaining);
	return `${quotaThresholdGlyph(pct)} Copilot ${remainingBar(pct)} ${quotaPercentText(pct)}`;
}

function quotaLines(stats: UsageStats): string[] {
	const lines: string[] = [];
	const snap = stats.quotaSnapshots ?? {};
	const resetDate = stats.quotaResetDate ? fmtDate(stats.quotaResetDate) : "unknown";
	const unit = quotaUnitLabel(stats);

	lines.push(bar("Copilot Pro Plan Quota"));
	if (stats.login) lines.push(`  User         ${stats.login}`);
	if (stats.copilotPlan) lines.push(`  Plan         ${stats.copilotPlan}`);
	if (stats.cliVersion) lines.push(`  CLI          v${stats.cliVersion}`);
	lines.push(`  Resets       ${resetDate}`);
	lines.push(`  Fetched      ${fmtDate(stats.fetchedAt)} at ${fmtTime(stats.fetchedAt)}`);
	lines.push("");

	// Premium interactions/units (metered bucket for premium models)
	const pi = snap["premium_interactions"];
	if (pi) {
		const remaining = quotaValue(pi);
		const used = Math.max(0, pi.entitlement - remaining);
		const pctUsed = 100 - pi.percent_remaining;
		const remainingText = Number.isInteger(remaining) ? String(remaining) : remaining.toFixed(1);
		lines.push(bar(`${unit}  (metered)`));
		lines.push(`  Entitlement  ${pi.entitlement} / month`);
		lines.push(`  Used         ${used.toFixed(1)}  (${pctUsed.toFixed(1)}%)`);
		lines.push(`  Remaining    ${remainingText}  (${pi.percent_remaining.toFixed(1)}%)`);
		lines.push(`  Billing      ${stats.tokenBasedBilling ? "token-based" : "request-based"}`);
		lines.push(`  Overage      ${pi.overage_permitted ? `allowed (${pi.overage_count} used, ${pi.overage_entitlement ?? 0} available)` : "not permitted"}`);
		lines.push(`               ${remainingBar(pi.percent_remaining, 30)}  ${remainingText} left`);
		lines.push("");
	}

	// Chat
	const chat = snap["chat"];
	if (chat) {
		lines.push(bar("Chat"));
		lines.push(`  ${chat.unlimited ? "✓ Unlimited" : `${chat.remaining} remaining`}`);
	}

	// Completions (inline code)
	const completions = snap["completions"];
	if (completions) {
		lines.push(bar("Completions (inline)"));
		lines.push(`  ${completions.unlimited ? "✓ Unlimited" : `${completions.remaining} remaining`}`);
	}

	// Any other quota buckets
	for (const [key, q] of Object.entries(snap)) {
		if (["premium_interactions", "chat", "completions"].includes(key)) continue;
		lines.push("");
		lines.push(bar(key));
		lines.push(`  ${q.unlimited ? "✓ Unlimited" : `${q.remaining} / ${q.entitlement} remaining`}`);
	}

	return lines;
}

function modelLines(stats: UsageStats): string[] {
	const lines: string[] = [];
	const models = stats.models ?? [];
	const free = models.filter((m) => m.free).sort((a, b) => a.id.localeCompare(b.id));
	const premium = models.filter((m) => !m.free).sort((a, b) => modelSortKey(a) - modelSortKey(b) || a.id.localeCompare(b.id));

	lines.push(bar("Model billing  (relative account hit)"));
	lines.push(`  ${pad("Included", 12)} ${free.length} models`);
	lines.push(`  ${pad("Metered", 12)} ${premium.length} models`);
	lines.push("");
	lines.push(bar("Included / 0×"));
	if (free.length === 0) {
		lines.push("  (none)");
	} else {
		for (const m of free) {
			lines.push(`  ${pad(modelCostLabel(m), 12)} ${modelDisplayName(m)}`);
		}
	}
	lines.push("");
	lines.push(bar("Metered / relative account hit"));
	if (premium.length === 0) {
		lines.push("  (none)");
	} else {
		lines.push(`  ${modelCostIndexNote(premium)}`);
		lines.push(...meteredModelLines(premium, "  "));
	}
	return lines;
}

function quotaBucketStatus(q: QuotaSnapshot): string {
	if (q.unlimited) return "✓ unlimited";
	const remaining = quotaValue(q);
	const entitlement = q.entitlement || q.remaining || remaining;
	const pct = typeof q.percent_remaining === "number"
		? q.percent_remaining
		: entitlement > 0 ? (remaining / entitlement) * 100 : 0;
	return `${remainingBar(pct, 12)} ${quotaPercentText(pct, 1)} · ${formatNumber(remaining)} / ${entitlement} left`;
}

function compactNumber(value: number): string {
	const abs = Math.abs(value);
	const units: Array<[number, string]> = [
		[1_000_000_000_000, "T"],
		[1_000_000_000, "B"],
		[1_000_000, "M"],
		[1_000, "K"],
	];
	for (const [factor, suffix] of units) {
		if (abs >= factor) {
			const compact = value / factor;
			return `${Number.isInteger(compact) ? compact.toFixed(0) : compact.toFixed(1).replace(/\.0$/, "")}${suffix}`;
		}
	}
	return String(value);
}

type ModelCostSource = "multiplier" | "output" | "blended";

interface ModelCostBasis {
	score: number;
	source: ModelCostSource;
}

function modelCostBasis(m: ModelBillingDisplay): ModelCostBasis | undefined {
	if (typeof m.multiplier === "number" && m.multiplier > 0) {
		return { score: m.multiplier, source: "multiplier" };
	}
	const prices = m.tokenPricing;
	if (!prices) return undefined;
	if (typeof prices.output === "number" && prices.output > 0) {
		return { score: prices.output, source: "output" };
	}
	const blended = [prices.input, prices.output, prices.cache]
		.filter((price): price is number => typeof price === "number" && price > 0)
		.reduce((sum, price) => sum + price, 0);
	return blended > 0 ? { score: blended, source: "blended" } : undefined;
}

function modelTokenPriceSummary(m: ModelBillingDisplay): string {
	const prices = m.tokenPricing;
	if (!prices) return typeof m.multiplier === "number" ? `GitHub multiplier ${formatRelativeCost(m.multiplier)}` : "no price details";
	const parts: string[] = [];
	if (typeof prices.input === "number" && prices.input > 0) parts.push(`input ${compactNumber(prices.input)}`);
	if (typeof prices.output === "number" && prices.output > 0) parts.push(`output ${compactNumber(prices.output)}`);
	if (typeof prices.cache === "number" && prices.cache > 0) parts.push(`cache ${compactNumber(prices.cache)}`);
	if (parts.length === 0) return "no price details";
	const basis = typeof prices.batchSize === "number" && prices.batchSize > 0 ? `per ${compactNumber(prices.batchSize)} tokens: ` : "";
	return `${basis}${parts.join(" · ")}`;
}

function modelSortKey(m: ModelBillingDisplay): number {
	if (m.free) return 0;
	return modelCostBasis(m)?.score ?? Number.MAX_SAFE_INTEGER;
}

function modelDisplayName(m: ModelBillingDisplay): string {
	return m.name === m.id ? m.id : `${m.name} (${m.id})`;
}

function formatRelativeCost(relative: number): string {
	return `${relative.toFixed(1)}×`;
}

function relativeCostGlyph(relative: number): string {
	if (relative <= 3) return GLYPH_CONNECTED;
	if (relative <= 8) return GLYPH_WARNING;
	return GLYPH_ERROR;
}

function relativeCostBar(relative: number, maxRelative: number, width = 10): string {
	const pct = maxRelative > 0 ? clampPercent((relative / maxRelative) * 100) : 0;
	const filled = Math.max(1, Math.round((pct / 100) * width));
	const empty = Math.max(0, width - filled);
	return `[${"█".repeat(filled)}${"░".repeat(empty)}]`;
}

function modelCostIndexNote(models: ModelBillingDisplay[]): string {
	const sources = new Set(models.map((m) => modelCostBasis(m)?.source).filter(Boolean));
	if (sources.size === 1 && sources.has("multiplier")) return "Cost index = GitHub multiplier relative to cheapest metered model";
	if (sources.size === 1 && sources.has("output")) return "Cost index = output token price relative to cheapest metered model";
	if (sources.size === 1 && sources.has("blended")) return "Cost index = blended token price relative to cheapest metered model";
	return "Cost index = relative from available GitHub billing metadata; token models prefer output price";
}

function meteredModelLines(models: ModelBillingDisplay[], indent = "  "): string[] {
	const priced = models
		.map((model) => ({ model, basis: modelCostBasis(model) }))
		.filter((entry): entry is { model: ModelBillingDisplay; basis: ModelCostBasis } => !!entry.basis)
		.sort((a, b) => a.basis.score - b.basis.score || a.model.id.localeCompare(b.model.id));
	const unpriced = models
		.filter((model) => !modelCostBasis(model))
		.sort((a, b) => a.id.localeCompare(b.id));
	if (priced.length === 0) return unpriced.map((model) => `${indent}${GLYPH_WARNING} ?     [░░░░░░░░░░] ${modelDisplayName(model)}  no comparable price metadata`);
	const minScore = Math.max(1, Math.min(...priced.map((entry) => entry.basis.score)));
	const comparisons = priced.map((entry) => ({ ...entry, relative: entry.basis.score / minScore }));
	const maxRelative = Math.max(...comparisons.map((entry) => entry.relative));
	const lines = comparisons.map(({ model, relative }) => {
		const rel = formatRelativeCost(relative);
		return `${indent}${relativeCostGlyph(relative)} ${pad(rel, 5)} ${relativeCostBar(relative, maxRelative)} ${modelDisplayName(model)}  ${modelTokenPriceSummary(model)}`;
	});
	for (const model of unpriced) {
		lines.push(`${indent}${GLYPH_WARNING} ?     [░░░░░░░░░░] ${modelDisplayName(model)}  no comparable price metadata`);
	}
	return lines;
}

function overviewLines(stats: UsageStats): string[] {
	const lines: string[] = [];
	const snap = stats.quotaSnapshots ?? {};
	const pi = snap["premium_interactions"];
	const unit = quotaUnitLabel(stats);

	lines.push(bar("Copilot dashboard", 58));
	if (pi) {
		const pct = clampPercent(pi.percent_remaining);
		const glyph = quotaThresholdGlyph(pct);
		const remaining = quotaValue(pi);
		const used = Math.max(0, pi.entitlement - remaining);
		const overage = pi.overage_permitted
			? `allowed (${pi.overage_count} used, ${pi.overage_entitlement ?? 0} available)`
			: "not permitted";
		lines.push(`${glyph} Copilot quota ${remainingBar(pct, 18)} ${quotaPercentText(pct, 1)} remaining`);
		lines.push(`  ${pad("Plan", 12)} ${stats.copilotPlan ?? "unknown"}`);
		if (stats.login) lines.push(`  ${pad("User", 12)} ${stats.login}`);
		if (stats.cliVersion) lines.push(`  ${pad("CLI", 12)} v${stats.cliVersion}`);
		lines.push(`  ${pad("Billing", 12)} ${stats.tokenBasedBilling ? "token-based" : "request-based"}`);
		lines.push(`  ${pad("Units", 12)} ${formatNumber(remaining)} / ${pi.entitlement} ${unit} left`);
		lines.push(`  ${pad("Used", 12)} ${formatNumber(used)} ${unit}`);
		lines.push(`  ${pad("Reset", 12)} ${stats.quotaResetDate ? fmtDate(stats.quotaResetDate) : "unknown"}`);
		lines.push(`  ${pad("Overage", 12)} ${overage}`);
	} else {
		lines.push(`${GLYPH_WARNING} Copilot quota unavailable`);
		if (stats.login) lines.push(`  ${pad("User", 12)} ${stats.login}`);
		if (stats.copilotPlan) lines.push(`  ${pad("Plan", 12)} ${stats.copilotPlan}`);
	}
	lines.push(`  ${pad("Fetched", 12)} ${fmtDate(stats.fetchedAt)} ${fmtTime(stats.fetchedAt)}`);

	lines.push("");
	lines.push(bar("Included buckets", 58));
	const includedRows: Array<[string, QuotaSnapshot | undefined]> = [
		["Chat", snap["chat"]],
		["Completions", snap["completions"]],
	];
	for (const [label, bucket] of includedRows) {
		lines.push(`  ${pad(label, 14)} ${bucket ? quotaBucketStatus(bucket) : "unknown"}`);
	}
	for (const [key, bucket] of Object.entries(snap)) {
		if (["premium_interactions", "chat", "completions"].includes(key)) continue;
		lines.push(`  ${pad(key, 14)} ${quotaBucketStatus(bucket)}`);
	}

	lines.push("");
	lines.push(bar("Models", 58));
	const models = stats.models ?? [];
	if (models.length === 0) {
		lines.push("  Model billing metadata unavailable");
	} else {
		const included = models.filter((m) => m.free).sort((a, b) => a.id.localeCompare(b.id));
		const metered = models.filter((m) => !m.free).sort((a, b) => modelSortKey(a) - modelSortKey(b) || a.id.localeCompare(b.id));
		lines.push(`  ${pad("Included", 12)} ${included.length} models`);
		lines.push(`  ${pad("Metered", 12)} ${metered.length} models`);
		if (included.length > 0) {
			lines.push("");
			lines.push("  Included / 0×");
			for (const m of included) lines.push(`    ${pad(modelCostLabel(m), 12)} ${modelDisplayName(m)}`);
		}
		if (metered.length > 0) {
			lines.push("");
			lines.push("  Metered / relative account hit");
			lines.push(`    ${modelCostIndexNote(metered)}`);
			lines.push(...meteredModelLines(metered, "    "));
		}
	}

	lines.push("");
	lines.push(bar("Sessions", 58));
	lines.push(`  ${pad("Total", 10)} ${pad(String(stats.total), 6)} ${pad("Today", 10)} ${stats.today}`);
	lines.push(`  ${pad("Week", 10)} ${pad(String(stats.thisWeek), 6)} ${pad("Month", 10)} ${stats.thisMonth}`);
	lines.push(`  ${pad("Active", 10)} ${pad(String(stats.activeSessions), 6)} ${pad("Avg", 10)} ${fmtDuration(stats.avgDurationMinutes)}`);

	lines.push("");
	lines.push(bar("Recent sessions", 58));
	const recent = stats.recentSessions.slice(0, 6);
	if (recent.length === 0) {
		lines.push("  No recent Copilot sessions found");
	} else {
		for (const s of recent) {
			const active = s.isActive ? GLYPH_CONNECTED : " ";
			const when = `${fmtDate(s.modifiedTime)} ${fmtTime(s.modifiedTime)}`;
			const dur = fmtDuration(s.durationMinutes);
			const repo = s.repository ? s.repository : s.cwd ? shortPath(s.cwd) : "unknown";
			const summary = s.summary ? `  ${s.summary.slice(0, 54)}` : "";
			lines.push(`${active} ${when}  ${pad(dur, 8)} ${repo}${summary}`);
		}
	}

	return lines;
}

// Expects a pre-sorted array — caller owns the sort order (fix #2: was sorted internally too)
function sessionListLines(sessions: SessionMetadata[]): string[] {
	const now = Date.now();
	return sessions.map((s) => {
		const active = now - s.modifiedTime.getTime() < ACTIVE_THRESHOLD_MS ? `${GLYPH_CONNECTED} ` : "  ";
		const when = `${fmtDate(s.modifiedTime.toISOString())} ${fmtTime(s.modifiedTime.toISOString())}`;
		const dur = fmtDuration(Math.round(Math.max(0, s.modifiedTime.getTime() - s.startTime.getTime()) / MS_PER_MIN));
		const repo = s.context?.repository ?? (s.context?.cwd ? shortPath(s.context.cwd) : "");
		const label = repo ? ` [${repo}]` : "";
		const summary = s.summary ? `  ${s.summary.slice(0, 45)}…` : "";
		return `${active}${when}  (${dur})${label}${summary}`;
	});
}

function sessionDetailLines(s: SessionMetadata): string[] {
	const lines: string[] = [];
	const dur = fmtDuration(Math.round(Math.max(0, s.modifiedTime.getTime() - s.startTime.getTime()) / MS_PER_MIN));
	lines.push(bar("Session details"));
	lines.push(`  ID           ${s.sessionId}`);
	lines.push(`  Started      ${fmtDate(s.startTime.toISOString())} ${fmtTime(s.startTime.toISOString())}`);
	lines.push(`  Last active  ${fmtDate(s.modifiedTime.toISOString())} ${fmtTime(s.modifiedTime.toISOString())}`);
	lines.push(`  Duration     ${dur}`);
	lines.push(`  Remote       ${s.isRemote}`);
	if (s.context) {
		lines.push("");
		lines.push(bar("Context"));
		if (s.context.repository) lines.push(`  Repository   ${s.context.repository}`);
		if (s.context.branch) lines.push(`  Branch       ${s.context.branch}`);
		if (s.context.gitRoot) lines.push(`  Git root     ${s.context.gitRoot}`);
		if (s.context.cwd) lines.push(`  Directory    ${s.context.cwd}`);
	}
	if (s.summary) {
		lines.push("");
		lines.push(bar("Summary"));
		const words = s.summary.split(" ");
		let line = "  ";
		for (const w of words) {
			if (line.length + w.length > 62) { lines.push(line); line = "  "; }
			line += w + " ";
		}
		if (line.trim()) lines.push(line);
	}
	return lines;
}

function statusLabel(stats: UsageStats): string {
	const pi = stats.quotaSnapshots?.["premium_interactions"];
	if (!pi) return `${GLYPH_CONNECTED} Copilot ${stats.total} sessions`;
	return formatQuotaStatus(pi);
}

// ---------------------------------------------------------------------------
// Extension entry point
// ---------------------------------------------------------------------------

const POLL_INTERVAL_MS = 60_000; // refresh footer every 60s
const SDK_CHILD_TIMEOUT_MS = 30_000;

function reviveSessionDates(sessions: Array<Omit<SessionMetadata, "startTime" | "modifiedTime"> & { startTime: string; modifiedTime: string }>): SessionMetadata[] {
	return sessions.map((session) => ({
		...session,
		startTime: new Date(session.startTime),
		modifiedTime: new Date(session.modifiedTime),
	})) as SessionMetadata[];
}

async function fetchCopilotSdkSnapshot(): Promise<Omit<FetchResult, "userInfo">> {
	const extensionRoot = join(__dirname, "..");
	const script = String.raw`
const { CopilotClient } = require("@github/copilot-sdk");
const timeout = (promise, ms, label) => Promise.race([
  promise,
  new Promise((_, reject) => setTimeout(() => reject(new Error(label + " timed out")), ms)),
]);
(async () => {
  const client = new CopilotClient({ logLevel: "none" });
  try {
    await timeout(client.start(), 10000, "start");
    const [sessions, status, auth, models] = await Promise.all([
      timeout(client.listSessions(), 15000, "listSessions"),
      timeout(client.getStatus(), 10000, "getStatus").catch(() => undefined),
      timeout(client.getAuthStatus(), 10000, "getAuthStatus").catch(() => undefined),
      timeout(client.listModels(), 15000, "listModels").catch(() => undefined),
    ]);
    process.stdout.write(JSON.stringify({ sessions, status, auth, models }));
  } finally {
    await timeout(client.forceStop(), 3000, "forceStop").catch(() => undefined);
    process.exit(0);
  }
})().catch((error) => {
  console.error(error && error.stack ? error.stack : String(error));
  process.exit(1);
});
`;
	const { stdout } = await execFileAsync(process.execPath, ["-e", script], {
		cwd: extensionRoot,
		timeout: SDK_CHILD_TIMEOUT_MS,
		maxBuffer: 20 * 1024 * 1024,
	});
	const result = JSON.parse(stdout) as Omit<FetchResult, "userInfo" | "sessions"> & { sessions: Array<Omit<SessionMetadata, "startTime" | "modifiedTime"> & { startTime: string; modifiedTime: string }> };
	return { ...result, sessions: reviveSessionDates(result.sessions) };
}

export default function (pi: ExtensionAPI) {
	// fix #3: TTL cache — avoids redundant full API round-trips on repeat commands
	let fetchCache: { data: FetchResult; ts: number } | null = null;
	let pollTimer: ReturnType<typeof setTimeout> | null = null;
	let isPolling = false; // guard against re-entrant polling calls
	// Store only the one function we need — not the whole ExtensionContext
	let setStatus: ((id: string, text: string) => void) | null = null;

	async function stopClient(): Promise<void> {
		fetchCache = null;
	}

	/** Fetch all data sources in parallel; userInfo failures are non-fatal. */
	async function fetchAll(): Promise<FetchResult> {
		const [sdk, userInfo] = await Promise.all([
			fetchCopilotSdkSnapshot(),
			fetchCopilotUserInfo().catch(() => undefined),
		]);
		return { ...sdk, userInfo };
	}

	// fix #3: cached wrapper — returns fresh data at most every 30 s
	const FETCH_CACHE_TTL_MS = 30_000;
	async function fetchAllCached(): Promise<FetchResult> {
		if (fetchCache && Date.now() - fetchCache.ts < FETCH_CACHE_TTL_MS) return fetchCache.data;
		const data = await fetchAll();
		fetchCache = { data, ts: Date.now() };
		return data;
	}

	/**
	 * Lightweight quota-only fetch (no SDK needed, just gh CLI).
	 * Uses recursive setTimeout so the next poll only schedules *after*
	 * this one completes — prevents overlapping gh processes.
	 */
	async function refreshQuotaStatus(): Promise<void> {
		if (isPolling || !setStatus) return; // already running or shut down
		isPolling = true;
		try {
			const userInfo = await fetchCopilotUserInfo();
			const pi_q = userInfo.quota_snapshots?.["premium_interactions"];
			if (pi_q && setStatus) {
				setStatus("copilot-usage", formatQuotaStatus(pi_q));
			}
		} catch {
			// Silently ignore – will retry next cycle
		} finally {
			isPolling = false;
			// Schedule next poll only after this one fully completes
			if (setStatus !== null) {
				pollTimer = setTimeout(refreshQuotaStatus, POLL_INTERVAL_MS);
			}
		}
	}

	// fix #6: delay first fetch by 3 s to avoid blocking session startup
	function startPolling(fn: (id: string, text: string) => void): void {
		stopPolling();
		setStatus = fn;
		// Delay the first gh call so it doesn't slow down session startup;
		// subsequent calls chain via setTimeout inside refreshQuotaStatus finally block
		pollTimer = setTimeout(refreshQuotaStatus, 3_000);
	}

	function stopPolling(): void {
		setStatus = null; // signals refreshQuotaStatus not to reschedule
		if (pollTimer) {
			clearTimeout(pollTimer);
			pollTimer = null;
		}
		fetchCache = null; // invalidate cached data on session end (fix #3)
	}

	// ── Lifecycle ─────────────────────────────────────────────────────────────

	pi.on("session_start", async (_event, ctx) => {
		ctx.ui.setStatus("copilot-usage", `${GLYPH_LOADING} Copilot loading…`);
		startPolling(ctx.ui.setStatus.bind(ctx.ui));
	});

	pi.on("session_shutdown", async () => {
		stopPolling();
		await stopClient();
	});

	// ── /copilot – full overview ───────────────────────────────────────────────

	pi.registerCommand("copilot", {
		description: "Show GitHub Copilot usage dashboard (quota, models, sessions)",
		handler: async (_args, ctx) => {
			ctx.ui.setStatus("copilot-usage", `${GLYPH_LOADING} Copilot fetching…`);
			try {
				const { sessions, userInfo, status, auth, models } = await fetchAllCached();
				const stats = computeStats(sessions, userInfo, status, auth, models);
				ctx.ui.setStatus("copilot-usage", statusLabel(stats));
				await ctx.ui.select("GitHub Copilot Usage", overviewLines(stats));
			} catch (err) {
				await stopClient(); // fix #4: stop + clear cache; don't orphan old client
				const msg = err instanceof Error ? err.message : String(err);
				ctx.ui.setStatus("copilot-usage", `${GLYPH_ERROR} Copilot error`);
				ctx.ui.notify(`Copilot error: ${msg}`, "error");
			}
		},
	});

	// ── /copilot-quota – focused quota panel ──────────────────────────────────

	pi.registerCommand("copilot-quota", {
		description: "Secondary focused Copilot quota and model billing view",
		handler: async (_args, ctx) => {
			ctx.ui.setStatus("copilot-usage", `${GLYPH_LOADING} Copilot fetching quota…`);
			try {
				// fix #3: use shared cache — no separate listModels/getStatus calls
				const { userInfo, status, auth, models } = await fetchAllCached();
				const stats = computeStats([], userInfo, status, auth, models);
				ctx.ui.setStatus("copilot-usage", statusLabel(stats));
				// Combine quota + model billing in one view
				const lines = [
					...quotaLines(stats),
					"",
					...modelLines(stats),
				];
				await ctx.ui.select("Copilot Pro Quota", lines);
			} catch (err) {
				await stopClient(); // fix #4
				const msg = err instanceof Error ? err.message : String(err);
				ctx.ui.setStatus("copilot-usage", `${GLYPH_ERROR} Copilot error`);
				ctx.ui.notify(`Copilot error: ${msg}`, "error");
			}
		},
	});

	// ── /copilot-sessions – session browser ───────────────────────────────────

	pi.registerCommand("copilot-sessions", {
		description: "Browse GitHub Copilot sessions",
		handler: async (_args, ctx) => {
			ctx.ui.setStatus("copilot-usage", `${GLYPH_LOADING} Copilot fetching sessions…`);
			try {
				const { sessions } = await fetchAllCached(); // fix #3
				if (sessions.length === 0) {
					ctx.ui.notify("No Copilot sessions found.", "info");
					ctx.ui.setStatus("copilot-usage", `${GLYPH_CONNECTED} Copilot 0 sessions`);
					return;
				}
				ctx.ui.setStatus("copilot-usage", `${GLYPH_CONNECTED} Copilot ${sessions.length} sessions`);

				// fix #2: sort once here and pass to sessionListLines (was sorted twice)
				const sorted = [...sessions].sort((a, b) => b.modifiedTime.getTime() - a.modifiedTime.getTime());
				const lines = sessionListLines(sorted);
				const chosen = await ctx.ui.select(
					`Copilot sessions (${sessions.length} total – pick one for details)`,
					lines,
				);
				if (!chosen) return;
				const idx = lines.indexOf(chosen);
				if (idx < 0 || idx >= sorted.length) return;
				await ctx.ui.select(`Session detail – ${sorted[idx].sessionId.slice(0, 12)}…`, sessionDetailLines(sorted[idx]));
			} catch (err) {
				await stopClient(); // fix #4
				const msg = err instanceof Error ? err.message : String(err);
				ctx.ui.setStatus("copilot-usage", `${GLYPH_ERROR} Copilot error`);
				ctx.ui.notify(`Copilot error: ${msg}`, "error");
			}
		},
	});

	// ── /copilot-models – model billing table ─────────────────────────────────

	pi.registerCommand("copilot-models", {
		description: "Secondary focused Copilot model billing view",
		handler: async (_args, ctx) => {
			ctx.ui.setStatus("copilot-usage", `${GLYPH_LOADING} Copilot fetching models…`);
			try {
				const { auth, models } = await fetchAllCached(); // fix #3
				const stats = computeStats([], undefined, undefined, auth, models);
				ctx.ui.setStatus("copilot-usage", `${GLYPH_CONNECTED} Copilot ${(models ?? []).length} models`);
				await ctx.ui.select("Copilot Models & Billing", modelLines(stats));
			} catch (err) {
				await stopClient(); // fix #4
				const msg = err instanceof Error ? err.message : String(err);
				ctx.ui.setStatus("copilot-usage", `${GLYPH_ERROR} Copilot error`);
				ctx.ui.notify(`Copilot error: ${msg}`, "error");
			}
		},
	});

	// ── copilot_usage tool – LLM-callable ─────────────────────────────────────

	pi.registerTool({
		name: "copilot_usage",
		label: "Copilot Usage",
		description:
			"Fetch GitHub Copilot plan usage: premium quota remaining, " +
			"model billing metadata, session counts by period, and recent sessions.",
		promptSnippet: "Fetch GitHub Copilot quota, model billing, and session usage statistics",
		parameters: Type.Object({
			period: Type.Optional(StringEnum(["today", "week", "month", "all"] as const)),
		}),
		async execute(_toolCallId, params, _signal, onUpdate, _ctx) {
			onUpdate?.({ content: [{ type: "text", text: "Fetching Copilot usage data…" }], details: {} });

			const { sessions: rawSessions, userInfo, status, auth, models } = await fetchAllCached();

			// fix #1: filter by period BEFORE calling computeStats — single call instead of two
			const period = params.period ?? "all";
			const now = new Date();
			const cutoff =
				period === "today" ? startOfDay(now) :
				period === "week"  ? startOfWeek(now) :
				period === "month" ? startOfMonth(now) : null;
			const sessions = cutoff ? rawSessions.filter((s) => s.startTime >= cutoff) : rawSessions;
			const result = computeStats(sessions, userInfo, status, auth, models);

			const text = JSON.stringify(result, null, 2);
			return {
				content: [{ type: "text", text }],
				details: { stats: result },
			};
		},
	});
}
