import type { AssistantMessage } from "@earendil-works/pi-ai";
import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";

type GitStats = {
	staged: number;
	unstaged: number;
	untracked: number;
};

async function getGitStats(pi: ExtensionAPI): Promise<GitStats | null> {
	const { stdout, code } = await pi.exec("git", ["status", "--porcelain=v1"]);
	if (code !== 0) return null;

	let staged = 0;
	let unstaged = 0;
	let untracked = 0;

	for (const rawLine of stdout.split("\n")) {
		const line = rawLine.trimEnd();
		if (!line) continue;

		const x = line[0];
		const y = line[1];
		if (x === "?" && y === "?") {
			untracked++;
			continue;
		}
		if (x && x !== " ") staged++;
		if (y && y !== " ") unstaged++;
	}

	return { staged, unstaged, untracked };
}

function formatTokens(count: number): string {
	if (count < 1000) return count.toString();
	if (count < 10000) return `${(count / 1000).toFixed(1)}k`;
	if (count < 1000000) return `${Math.round(count / 1000)}k`;
	if (count < 10000000) return `${(count / 1000000).toFixed(1)}M`;
	return `${Math.round(count / 1000000)}M`;
}

function sanitizeStatusText(text: string): string {
	return text.replace(/[\r\n\t]/g, " ").replace(/ +/g, " ").trim();
}

function formatBranchLabel(branch: string, stats: GitStats | null, theme: ExtensionContext["ui"]["theme"]): string {
	if (!stats) return theme.fg("accent", branch);

	const parts: string[] = [];
	if (stats.staged > 0) parts.push(theme.fg("success", `+${stats.staged}`));
	const dirty = stats.unstaged + stats.untracked;
	if (dirty > 0) parts.push(theme.fg("warning", `-${dirty}`));
	parts.push(theme.fg("accent", branch));
	return parts.join(theme.fg("dim", " "));
}

// -- Cache for footer usage totals to avoid O(n) scans on every render frame --
type UsageCache = {
	totalInput: number;
	totalOutput: number;
	totalCacheRead: number;
	totalCacheWrite: number;
	totalCost: number;
	lastEntryCount: number;
};

let usageCache: UsageCache = {
	totalInput: 0,
	totalOutput: 0,
	totalCacheRead: 0,
	totalCacheWrite: 0,
	totalCost: 0,
	lastEntryCount: 0,
};

function resetUsageCache() {
	usageCache = {
		totalInput: 0,
		totalOutput: 0,
		totalCacheRead: 0,
		totalCacheWrite: 0,
		totalCost: 0,
		lastEntryCount: 0,
	};
}

function getFooterUsage(ctx: ExtensionContext) {
	const entries = ctx.sessionManager.getEntries();
	const currentCount = entries.length;

	// Branch switch or tree navigation may reduce entry count — reset
	if (currentCount < usageCache.lastEntryCount) {
		resetUsageCache();
	}

	// Only scan new entries since last call
	for (let i = usageCache.lastEntryCount; i < currentCount; i++) {
		const entry = entries[i];
		if (entry?.type === "message" && entry.message.role === "assistant") {
			const msg = entry.message as AssistantMessage;
			usageCache.totalInput += msg.usage.input;
			usageCache.totalOutput += msg.usage.output;
			usageCache.totalCacheRead += msg.usage.cacheRead;
			usageCache.totalCacheWrite += msg.usage.cacheWrite;
			usageCache.totalCost += msg.usage.cost.total;
		}
	}

	usageCache.lastEntryCount = currentCount;

	return {
		totalInput: usageCache.totalInput,
		totalOutput: usageCache.totalOutput,
		totalCacheRead: usageCache.totalCacheRead,
		totalCacheWrite: usageCache.totalCacheWrite,
		totalCost: usageCache.totalCost,
	};
}

export default function (pi: ExtensionAPI) {
	let refreshFooter: (() => Promise<void>) | undefined;

	const installFooter = (ctx: ExtensionContext) => {
		resetUsageCache();
		ctx.ui.setFooter((tui, theme, footerData) => {
			let stats: GitStats | null = null;

			const refresh = async () => {
				stats = await getGitStats(pi);
				tui.requestRender();
			};

			refreshFooter = refresh;
			void refresh();

			const unsub = footerData.onBranchChange(() => {
				void refresh();
			});

			return {
				dispose() {
					unsub();
					if (refreshFooter === refresh) refreshFooter = undefined;
				},
				invalidate() {},
				render(width: number): string[] {
					const { totalInput, totalOutput, totalCacheRead, totalCacheWrite, totalCost } = getFooterUsage(ctx);
					const contextUsage = ctx.getContextUsage();
					const contextWindow = contextUsage?.contextWindow ?? ctx.model?.contextWindow ?? 0;
					const contextPercentValue = contextUsage?.percent ?? 0;
					const contextPercent = contextUsage?.percent !== null ? contextPercentValue.toFixed(1) : "?";

					let pwd = ctx.sessionManager.getCwd();
					const home = process.env.HOME || process.env.USERPROFILE;
					if (home && pwd.startsWith(home)) pwd = `~${pwd.slice(home.length)}`;

					const branch = footerData.getGitBranch();
					if (branch) pwd = `${pwd} (${formatBranchLabel(branch, stats, theme)})`;

					const sessionName = ctx.sessionManager.getSessionName();
					if (sessionName) pwd = `${pwd}${theme.fg("dim", " • ")}${sessionName}`;

					const metric = (label: string, value: string, color: "accent" | "success" | "warning" | "muted" = "muted") =>
						`${theme.fg(color, label)}${theme.fg("dim", value)}`;

					const statsParts: string[] = [];
					if (totalInput) statsParts.push(metric("↑", formatTokens(totalInput), "accent"));
					if (totalOutput) statsParts.push(metric("↓", formatTokens(totalOutput), "success"));
					if (totalCacheRead) statsParts.push(metric("R", formatTokens(totalCacheRead), "muted"));
					if (totalCacheWrite) statsParts.push(metric("W", formatTokens(totalCacheWrite), "muted"));

					const usingSubscription = ctx.model ? ctx.modelRegistry.isUsingOAuth(ctx.model) : false;
					if (totalCost || usingSubscription) {
						statsParts.push(metric("$", `${totalCost.toFixed(3)}${usingSubscription ? " sub" : ""}`, "warning"));
					}

					const contextDisplay =
						contextPercent === "?" ? `?/${formatTokens(contextWindow)}` : `${contextPercent}%/${formatTokens(contextWindow)}`;
					if (contextPercentValue > 90) statsParts.push(theme.fg("error", contextDisplay));
					else if (contextPercentValue > 70) statsParts.push(theme.fg("warning", contextDisplay));
					else statsParts.push(metric("ctx ", contextDisplay, "accent"));

					let left = statsParts.join(" ");
					let leftWidth = visibleWidth(left);
					if (leftWidth > width) {
						left = truncateToWidth(left, width, "...");
						leftWidth = visibleWidth(left);
					}

					const sessionContext = ctx.sessionManager.buildSessionContext();
					const modelName = ctx.model?.id || "no-model";
					let right = theme.fg("muted", modelName);
					if (ctx.model?.reasoning) {
						const thinkingLevel = sessionContext.thinkingLevel || "off";
						right = `${theme.fg("muted", modelName)}${theme.fg("dim", ":")}${theme.fg("accent", thinkingLevel)}`;
					}
					if (footerData.getAvailableProviderCount() > 1 && ctx.model) {
						const withProvider = `${theme.fg("dim", "(")}${theme.fg("accent", ctx.model.provider)}${theme.fg("dim", ") ")}${right}`;
						if (leftWidth + 2 + visibleWidth(withProvider) <= width) right = withProvider;
					}

					const availableForRight = width - leftWidth - 2;
					let statsLine = left;
					if (availableForRight > 0) {
						const fittedRight = visibleWidth(right) <= availableForRight ? right : truncateToWidth(right, availableForRight, "");
						const padding = " ".repeat(Math.max(0, width - leftWidth - visibleWidth(fittedRight)));
						statsLine = left + padding + fittedRight;
					}

					const lines = [
						truncateToWidth(theme.fg("dim", pwd), width, theme.fg("dim", "...")),
						statsLine,
					];

					const extensionStatuses = [...footerData.getExtensionStatuses().entries()]
						.sort(([a], [b]) => a.localeCompare(b))
						.map(([key, text]) => {
							const status = sanitizeStatusText(text);
							if (!status) return "";
							if (key === "idle") return `${theme.fg("dim", "voice: ")}${status}`;
							return status;
						})
						.filter(Boolean);
					if (extensionStatuses.length > 0) {
						lines.push(truncateToWidth(extensionStatuses.join(" "), width, theme.fg("dim", "...")));
					}

					return lines;
				},
			};
		});
	};

	const triggerRefresh = async () => {
		if (refreshFooter) await refreshFooter();
	};

	pi.on("session_start", async (_event, ctx) => {
		installFooter(ctx);
	});

	pi.on("session_tree", async (_event, ctx) => {
		installFooter(ctx);
	});

	pi.on("tool_result", async () => {
		await triggerRefresh();
	});

	pi.on("turn_end", async () => {
		await triggerRefresh();
	});
}
