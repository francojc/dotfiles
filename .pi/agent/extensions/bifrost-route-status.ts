/**
 * Bifrost Route Status
 *
 * Shows which model the Bifrost gateway actually routed a request to in the
 * footer status bar. Pi sends a logical model ("auto") and the gateway's
 * complexity classifier picks the physical model; the answer arrives in
 * x-bifrost-* response headers (see docs.getbifrost.ai/providers/response-headers).
 *
 * Header-presence keyed, not provider-keyed: any response carrying
 * x-bifrost-routing-info-model updates the status, so new gateway tiers or
 * virtual-key providers need no changes here.
 *
 * Status key: "bifrost" — clear it with /bifrost-clear if it ever goes stale.
 */

import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";

const STATUS_KEY = "bifrost";

/** Request id → status text, so out-of-order responses can't clobber newer routing info. */
const recent = new Map<string, string>();

function formatRoute(headers: Record<string, string>): string | undefined {
	const model = headers["x-bifrost-routing-info-model"] ?? headers["x-bifrost-resolved-model"];
	if (!model) return undefined;

	const requested = headers["x-bifrost-routing-info-requested-model"];
	const provider = headers["x-bifrost-routing-info-provider"] ?? headers["x-bifrost-provider"];
	const fallback = headers["x-bifrost-routing-info-is-fallback"] === "true";
	const latency = Number.parseFloat(headers["x-bifrost-upstream-latency-ms"] ?? "");
	const key = headers["x-bifrost-routing-info-key"];

	// Show the hop only when the gateway actually translated the model name.
	const routed = requested && requested !== model ? `${requested} → ${model}` : model;
	const parts = [provider, routed].filter(Boolean).join("/");
	if (!parts) return undefined;

	let text = `⇢ ${parts}`;
	if (fallback) text += " ↩fallback";
	if (Number.isFinite(latency)) text += ` ${Math.round(latency)}ms`;
	// Only shown when it differs from the key the whole session uses, else noise.
	const vk = process.env.BIFROST_VK_KEY;
	if (key && vk && key !== vk) text += ` · ${key}`;
	return text;
}

export default function (pi: ExtensionAPI) {
	pi.on("after_provider_response", async (event, ctx: ExtensionContext) => {
		if (ctx.mode !== "tui") return;

		const requestId = event.headers["x-bifrost-request-id"];
		const text = formatRoute(event.headers);
		if (!text) return; // non-Bifrost provider: leave status alone

		// Monotonic per request id: header set arrives before the stream starts,
		// so the last emit for a request wins and older concurrent ones are ignored.
		if (requestId) {
			const previous = recent.get(requestId);
			if (previous === text) return;
			recent.set(requestId, text);
			if (recent.size > 8) {
				const oldest = recent.keys().next().value;
				if (oldest !== undefined) recent.delete(oldest);
			}
		}

		ctx.ui.setStatus(STATUS_KEY, text);
	});

	pi.registerCommand("bifrost-clear", {
		description: "Clear the Bifrost route status in the footer",
		handler: (_args, ctx) => {
			recent.clear();
			ctx.ui.setStatus(STATUS_KEY, undefined);
		},
	});
}
