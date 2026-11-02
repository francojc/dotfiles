/**
 * Bifrost Context Guard
 *
 * Pi sizes compaction from the declared `contextWindow` of the model it selected.
 * Behind a routing provider that number is a guess about what the gateway will
 * pick, so a route to a model with a smaller window silently over-sends and the
 * upstream truncates or 400s. This extension watches the model the gateway
 * actually resolved (x-bifrost-routing-info-model) and checks the worst case
 * before the route can overflow:
 *
 *   1. over-send — the declared window is larger than the routed model's.
 *   2. overflow  — this conversation no longer fits the routed model.
 *
 * The routed model's real limits come from the `bifrost` provider, which
 * pi-bifrost patches from models.dev, so the comparison is against measured
 * metadata rather than the routing provider's hand-written declaration.
 *
 * Warns once per (provider, model) pair and again on a new high-water mark, so a
 * long session does not repeat itself every turn. Status key: "bifrost-ctx" —
 * clear it with /bifrost-context.
 */

import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";

const STATUS_KEY = "bifrost-ctx";

/** Routing providers whose declared window is an estimate: provider id → logical model id. */
interface RoutingProvider {
	provider: string;
	model: string;
	/** The provider whose patched catalog holds per-model metadata. */
	catalog: string;
}

interface Resolution {
	model: string;
	contextWindow: number;
	maxTokens?: number;
}

interface Warning {
	kind: "oversend" | "overflow" | "unknown";
	text: string;
}

/** Where each routing provider's declared window is an estimate, and where to look up the truth. */
function routingProviders(): RoutingProvider[] {
	return [
		{ provider: "bifrost-auto", model: "auto", catalog: "bifrost" },
		{ provider: "bifrost-fast", model: "auto", catalog: "bifrost" },
		{ provider: "bifrost-frontier", model: "auto", catalog: "bifrost" },
	];
}

/**
 * The routed model as the gateway named it, plus its real limits.
 *
 * Bifrost reports the model ID without the provider prefix
 * (x-bifrost-routing-info-model: "glm-5.3"); the catalog keys full gateway IDs
 * ("opencode-zen/glm-5.3"). Try the reported provider first, then any provider,
 * preferring an exact contextWindow match when several share a name.
 */
function resolveRouted(
	ctx: ExtensionContext,
	catalog: string,
	model: string,
	provider: string | undefined
): Resolution | undefined {
	const candidates = ctx.modelRegistry
		.getAll()
		.filter((entry) => entry.provider === catalog && entry.id.split("/").pop() === model);
	if (candidates.length === 0) return undefined;

	const preferred =
		(provider ? candidates.find((entry) => entry.id.startsWith(`${provider}/`)) : undefined) ??
		candidates[0];

	return {
		model: preferred.id,
		contextWindow: preferred.contextWindow,
		maxTokens: preferred.maxTokens,
	};
}

function formatTokens(value: number): string {
	if (value >= 1_000_000) return `${Number((value / 1_000_000).toFixed(2))}M`;
	if (value >= 1000) return `${Math.round(value / 1000)}k`;
	return String(value);
}

export default function (pi: ExtensionAPI) {
	/** `${provider}/${model}` → highest overflow ratio already reported. */
	const reported = new Map<string, number>();
	/** `${routingProvider}/${routedModel}` → true once the over-send was reported. */
	const oversendReported = new Set<string>();

	function isRouting(ctx: ExtensionContext, spec: RoutingProvider): boolean {
		return ctx.model?.provider === spec.provider && ctx.model.id === spec.model;
	}

	async function check(ctx: ExtensionContext, headers: Record<string, string>): Promise<Warning | undefined> {
		const routedName =
			headers["x-bifrost-routing-info-model"] ?? headers["x-bifrost-resolved-model"];
		if (!routedName) return undefined;

		const spec = routingProviders().find((entry) => isRouting(ctx, entry));
		if (!spec) return undefined;

		const routed = resolveRouted(
			ctx,
			spec.catalog,
			routedName,
			headers["x-bifrost-routing-info-provider"] ?? headers["x-bifrost-provider"]
		);
		if (!routed) {
			// The catalog never saw this model, so nothing downstream can size it.
			const key = `${spec.provider}/*`;
			if (oversendReported.has(key)) return undefined;
			oversendReported.add(key);
			return {
				kind: "unknown",
				text: `routed to ${routedName}, which the ${spec.catalog} catalog does not list — its context window is unknown`,
			};
		}

		const declared = ctx.model?.contextWindow ?? 0;
		const key = `${spec.provider}/${routed.model}`;

		if (declared > routed.contextWindow && !oversendReported.has(key)) {
			oversendReported.add(key);
			return {
				kind: "oversend",
				text:
					`${spec.provider} declares ${formatTokens(declared)} but routed to ${routed.model} ` +
					`(${formatTokens(routed.contextWindow)}). Compaction can over-send by ` +
					`${formatTokens(declared - routed.contextWindow)}. Narrow the tier pools or lower contextWindow.`,
			};
		}

		const usage = ctx.getContextUsage();
		if (!usage || usage.tokens === null) return undefined;

		const ratio = usage.tokens / routed.contextWindow;
		const previous = reported.get(key) ?? 0;
		if (ratio >= 0.9 && ratio > previous) {
			reported.set(key, ratio);
			return {
				kind: "overflow",
				text:
					`${formatTokens(usage.tokens)} of the ${formatTokens(routed.contextWindow)} ` +
					`${routed.model} window is in use (${Math.round(ratio * 100)}%)`,
			};
		}
		return undefined;
	}

	pi.on("after_provider_response", async (event, ctx: ExtensionContext) => {
		const warning = await check(ctx, event.headers);
		if (!warning) return;

		const prefix = warning.kind === "overflow" ? "⚠" : "✖";
		ctx.ui.setStatus(STATUS_KEY, `${prefix} ${formatTokens(ctx.model?.contextWindow ?? 0)} declared`);
		if (warning.kind === "overflow") {
			// A warning, not a stop: the request already succeeded.
			ctx.ui.notify(warning.text, "warning");
			return;
		}
		ctx.ui.notify(`[bifrost] ${warning.text}`, "warning");
	});

	// After a compaction the conversation fits again; clear the high-water marks so
	// a later approach to the limit still reports once.
	pi.on("session_compact", async (_event, ctx) => {
		reported.clear();
		ctx.ui.setStatus(STATUS_KEY, undefined);
	});

	pi.registerCommand("bifrost-context", {
		description: "Show the routed model's limits against what this provider declares",
		handler: async (_args, ctx) => {
			const spec = routingProviders().find((entry) => isRouting(ctx, entry));
			if (!spec) {
				ctx.ui.notify("Not on a routing provider (bifrost-auto/fast/frontier).", "info");
				return;
			}
			const usage = ctx.getContextUsage();
			const declared = ctx.model?.contextWindow ?? 0;
			const lines = [
				`${spec.provider}/${spec.model} declares ${formatTokens(declared)} in, ${formatTokens(ctx.model?.maxTokens ?? 0)} out`,
				usage && usage.tokens !== null
					? `in use: ${formatTokens(usage.tokens)}${usage.percent === null ? "" : ` (${Math.round(usage.percent)}% of declared)`}`
					: "in use: unknown until the next response",
			];
			ctx.ui.notify(lines.join("\n"), "info");
			ctx.ui.setStatus(STATUS_KEY, undefined);
			reported.clear();
		},
	});
}
