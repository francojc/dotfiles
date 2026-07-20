import { readdir, readFile } from "node:fs/promises";
import { dirname, join } from "node:path";
import type { ExtensionAPI, ExtensionCommandContext } from "@earendil-works/pi-coding-agent";

const COMMAND_NAME = "opencode-go-costs";
const PROVIDER = "opencode-go";
const BAR_WIDTH = 16;

type Period = "day" | "week" | "30d" | "all";

type Usage = {
	input?: number;
	output?: number;
	cacheRead?: number;
	cacheWrite?: number;
	cost?: { total?: number };
};

type StoredEntry = {
	type?: string;
	id?: string;
	timestamp?: string;
	message?: {
		role?: string;
		provider?: string;
		model?: string;
		responseId?: string;
		usage?: Usage;
	};
};

type Turn = {
	id: string;
	timestamp: Date;
	model: string;
	cost: number;
	tokens: number;
};

type ModelSummary = {
	model: string;
	cost: number;
	requests: number;
	tokens: number;
};

function numberOrZero(value: number | undefined): number {
	return typeof value === "number" && Number.isFinite(value) ? value : 0;
}

function parseTurn(entry: StoredEntry): Turn | undefined {
	const message = entry.message;
	if (entry.type !== "message" || message?.role !== "assistant" || message.provider !== PROVIDER || !message.model) return undefined;
	const timestamp = new Date(entry.timestamp ?? "");
	if (Number.isNaN(timestamp.getTime())) return undefined;
	const usage = message.usage;
	const tokens = numberOrZero(usage?.input) + numberOrZero(usage?.output) + numberOrZero(usage?.cacheRead) + numberOrZero(usage?.cacheWrite);
	return {
		id: message.responseId ?? entry.id ?? `${entry.timestamp}:${message.model}`,
		timestamp,
		model: message.model,
		cost: numberOrZero(usage?.cost?.total),
		tokens,
	};
}

async function findSessionFiles(directory: string): Promise<string[]> {
	try {
		const entries = await readdir(directory, { withFileTypes: true });
		const nested = await Promise.all(entries.map(async (entry) => {
			const path = join(directory, entry.name);
			if (entry.isDirectory()) return findSessionFiles(path);
			return entry.isFile() && entry.name.endsWith(".jsonl") ? [path] : [];
		}));
		return nested.flat();
	} catch {
		return [];
	}
}

async function readTurns(sessionRoot: string): Promise<Turn[]> {
	const files = await findSessionFiles(sessionRoot);
	const contents = await Promise.all(files.map(async (file) => {
		try {
			return await readFile(file, "utf8");
		} catch {
			return "";
		}
	}));
	const turns: Turn[] = [];
	const seen = new Set<string>();
	for (const content of contents) {
		for (const line of content.split("\n")) {
			if (!line) continue;
			try {
				const turn = parseTurn(JSON.parse(line) as StoredEntry);
				// Forked sessions can contain copied history. responseId is stable across copies.
				if (turn && !seen.has(turn.id)) {
					seen.add(turn.id);
					turns.push(turn);
				}
			} catch {
				// A session may be written while this command scans it. Ignore partial JSONL lines.
			}
		}
	}
	return turns;
}

function dayStart(date: Date): Date {
	const result = new Date(date);
	result.setHours(0, 0, 0, 0);
	return result;
}

function periodStart(period: Period, now: Date): Date | undefined {
	if (period === "all") return undefined;
	const days = period === "day" ? 1 : period === "week" ? 7 : 30;
	const start = dayStart(now);
	start.setDate(start.getDate() - (days - 1));
	return start;
}

function periodLabel(period: Period): string {
	return period === "day" ? "today" : period === "week" ? "last 7 days" : period === "30d" ? "last 30 days" : "all recorded sessions";
}

function formatCurrency(value: number): string {
	return value < 0.01 ? `$${value.toFixed(4)}` : `$${value.toFixed(2)}`;
}

function formatTokens(value: number): string {
	if (value < 1_000) return `${Math.round(value)}`;
	if (value < 1_000_000) return `${(value / 1_000).toFixed(value < 10_000 ? 1 : 0)}k`;
	return `${(value / 1_000_000).toFixed(1)}M`;
}

function localDayKey(date: Date): string {
	return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, "0")}-${String(date.getDate()).padStart(2, "0")}`;
}

function formatDay(key: string): string {
	const [year, month, day] = key.split("-").map(Number);
	return new Date(year, (month ?? 1) - 1, day).toLocaleDateString(undefined, { month: "short", day: "numeric" });
}

function makeBar(value: number, maximum: number): string {
	if (value <= 0 || maximum <= 0) return "";
	return "█".repeat(Math.max(1, Math.round((value / maximum) * BAR_WIDTH)));
}

function summarizeModels(turns: Turn[]): ModelSummary[] {
	const byModel = new Map<string, ModelSummary>();
	for (const turn of turns) {
		const summary = byModel.get(turn.model) ?? { model: turn.model, cost: 0, requests: 0, tokens: 0 };
		summary.cost += turn.cost;
		summary.requests += 1;
		summary.tokens += turn.tokens;
		byModel.set(turn.model, summary);
	}
	return [...byModel.values()].sort((a, b) => b.cost - a.cost);
}

function reportLines(turns: Turn[], period: Period): string[] {
	const totalCost = turns.reduce((total, turn) => total + turn.cost, 0);
	const totalTokens = turns.reduce((total, turn) => total + turn.tokens, 0);
	const lines = [
		`OpenCode Go recorded cost – ${periodLabel(period)}`,
		`  ${formatCurrency(totalCost)} · ${turns.length} responses · ${formatTokens(totalTokens)} tokens`,
		"  Costs use Pi's provider price recorded with each response.",
	];

	const daily = new Map<string, number>();
	for (const turn of turns) daily.set(localDayKey(turn.timestamp), (daily.get(localDayKey(turn.timestamp)) ?? 0) + turn.cost);
	const maxDailyCost = Math.max(0, ...daily.values());
	lines.push("Daily spend");
	for (const [day, cost] of [...daily.entries()].sort(([a], [b]) => a.localeCompare(b))) {
		lines.push(`  ${formatDay(day).padEnd(7)} ${formatCurrency(cost).padStart(8)}  ${makeBar(cost, maxDailyCost)}`);
	}

	const models = summarizeModels(turns);
	lines.push("", "Model spend");
	for (const model of models.slice(0, 6)) {
		const average = model.cost / model.requests;
		const share = totalCost > 0 ? Math.round((model.cost / totalCost) * 100) : 0;
		lines.push(`  ${model.model.padEnd(20)} ${formatCurrency(model.cost).padStart(8)}  ${model.requests} req  avg ${formatCurrency(average)}  ${share}%`);
	}

	const byCost = [...turns].sort((a, b) => b.cost - a.cost);
	lines.push("", "Highest-cost responses");
	for (const turn of byCost.slice(0, 4)) {
		lines.push(`  ${turn.timestamp.toLocaleString([], { month: "short", day: "numeric", hour: "2-digit", minute: "2-digit" })}  ${turn.model.padEnd(18)} ${formatCurrency(turn.cost).padStart(8)}  ${formatTokens(turn.tokens)} tok`);
	}

	const lowestCost = byCost.filter((turn) => turn.cost > 0).slice().reverse().slice(0, 4);
	if (lowestCost.length > 0) {
		lines.push("", "Lowest-cost responses");
		for (const turn of lowestCost) {
			lines.push(`  ${turn.timestamp.toLocaleString([], { month: "short", day: "numeric", hour: "2-digit", minute: "2-digit" })}  ${turn.model.padEnd(18)} ${formatCurrency(turn.cost).padStart(8)}  ${formatTokens(turn.tokens)} tok`);
		}
	}
	return lines;
}

function parsePeriod(args: string): Period | undefined {
	const value = args.trim() || "week";
	return value === "day" || value === "week" || value === "30d" || value === "all" ? value : undefined;
}

export default function (pi: ExtensionAPI) {
	pi.registerCommand(COMMAND_NAME, {
		description: "Show OpenCode Go recorded cost by day, model, and response: [day|week|30d|all]",
		handler: async (args, ctx: ExtensionCommandContext) => {
			const period = parsePeriod(args);
			if (!period) {
				await ctx.ui.select("OpenCode Go Costs", ["Usage: /opencode-go-costs [day|week|30d|all]"]);
				return;
			}
			const sessionRoot = dirname(ctx.sessionManager.getSessionDir());
			const start = periodStart(period, new Date());
			const turns = (await readTurns(sessionRoot)).filter((turn) => !start || turn.timestamp >= start);
			if (turns.length === 0) {
				await ctx.ui.select("OpenCode Go Costs", [`No recorded OpenCode Go responses for ${periodLabel(period)}.`]);
				return;
			}
			await ctx.ui.select("OpenCode Go Costs", reportLines(turns, period));
		},
	});
}
