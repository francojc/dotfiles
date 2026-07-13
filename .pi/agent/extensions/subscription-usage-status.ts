export type SubscriptionUsageWindow = {
	remainingPercent: number;
	resetAt?: Date;
};

export type SubscriptionUsageSnapshot = {
	fiveHour?: SubscriptionUsageWindow;
	weekly?: SubscriptionUsageWindow;
	monthly?: SubscriptionUsageWindow;
	fetchedAt: Date;
};

export type CompactSubscriptionStatus = {
	label: string;
	fiveHourRemaining: number;
	weeklyRemaining?: number;
};

export function clampPercent(percent: number): number {
	return Math.max(0, Math.min(100, Number.isFinite(percent) ? percent : 0));
}

export function usedPercentToRemaining(usedPercent: number): number {
	return clampPercent(100 - clampPercent(usedPercent));
}

export function quotaGlyph(percentRemaining: number): string {
	const percent = clampPercent(percentRemaining);
	if (percent > 25) return "";
	if (percent > 10) return "";
	return "";
}

export function remainingBar(percentRemaining: number, width = 10): string {
	const filled = Math.round((clampPercent(percentRemaining) / 100) * width);
	return `[${"█".repeat(filled)}${"░".repeat(width - filled)}]`;
}

export function formatResetDuration(resetAt: Date | undefined, now = Date.now()): string | undefined {
	if (!resetAt || !Number.isFinite(resetAt.getTime())) return undefined;
	const seconds = Math.max(0, Math.ceil((resetAt.getTime() - now) / 1_000));
	const days = Math.floor(seconds / 86_400);
	const hours = Math.floor((seconds % 86_400) / 3_600);
	const minutes = Math.floor((seconds % 3_600) / 60);
	if (days > 0) return `${days}d ${hours}h`;
	if (hours > 0) return `${hours}h ${minutes}m`;
	return `${minutes}m`;
}

/**
 * Codex is an external package and publishes this undocumented compact grammar:
 *   codex [variant] <remaining>% 5h <remaining>% wk
 * OpenCode Go deliberately publishes the compatible form:
 *   opencode-go <remaining>% 5h <remaining>% wk
 */
export function parseCompactSubscriptionStatus(status: string): CompactSubscriptionStatus | undefined {
	const codex = status.match(/^codex(?:\s+(.+?))?\s+(\d{1,3})%\s+5h\s+(\d{1,3})%\s+wk$/i);
	if (codex) {
		const [, variant, fiveHour, weekly] = codex;
		return {
			label: variant ? `Codex ${variant}` : "Codex",
			fiveHourRemaining: clampPercent(Number(fiveHour)),
			weeklyRemaining: clampPercent(Number(weekly)),
		};
	}

	const go = status.match(/^opencode-go\s+(\d{1,3})%\s+5h(?:\s+(\d{1,3})%\s+wk)?$/i);
	if (!go) return undefined;
	return {
		label: "OpenCode Go",
		fiveHourRemaining: clampPercent(Number(go[1])),
		weeklyRemaining: go[2] === undefined ? undefined : clampPercent(Number(go[2])),
	};
}

export function formatCompactSubscriptionStatus(status: CompactSubscriptionStatus): string {
	const weekly = status.weeklyRemaining === undefined ? "" : ` · wk ${status.weeklyRemaining.toFixed(0)}%`;
	return `${quotaGlyph(status.fiveHourRemaining)} ${status.label} ${remainingBar(status.fiveHourRemaining)} ${status.fiveHourRemaining.toFixed(0)}%${weekly}`;
}

export function formatRawCompactSubscriptionStatus(label: "opencode-go", snapshot: SubscriptionUsageSnapshot): string | undefined {
	if (!snapshot.fiveHour) return undefined;
	const weekly = snapshot.weekly ? ` ${snapshot.weekly.remainingPercent.toFixed(0)}% wk` : "";
	return `${label} ${snapshot.fiveHour.remainingPercent.toFixed(0)}% 5h${weekly}`;
}
