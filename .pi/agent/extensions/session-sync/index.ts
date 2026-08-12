import { readFile } from "node:fs/promises";
import { hostname } from "node:os";
import { getAgentDir, type ExtensionAPI } from "@earendil-works/pi-coding-agent";

type Destination = {
	host: string;
	label?: string;
	sessionRoot: string;
	default?: boolean;
};

type Config = {
	destinations: Destination[];
};

type DestinationStatus = {
	ok: boolean;
	lines: string[];
};

const CONFIG_PATH = `${getAgentDir()}/session-sync.json`;
const SSH_TIMEOUT_MS = 8_000;
const SAFE_HOST = /^[A-Za-z0-9][A-Za-z0-9._-]*$/;
const SAFE_PATH = /^[A-Za-z0-9._-]+(?:\/[A-Za-z0-9._-]+)*$/;

function isRecord(value: unknown): value is Record<string, unknown> {
	return typeof value === "object" && value !== null && !Array.isArray(value);
}

function validateRelativePath(value: unknown, name: string): string {
	if (typeof value !== "string" || value.length === 0 || value.startsWith("/")) {
		throw new Error(`${name} must be a nonempty path relative to remote $HOME`);
	}
	if (!SAFE_PATH.test(value) || value.split("/").some((part) => part === "." || part === "..")) {
		throw new Error(`${name} contains unsafe path characters or traversal components`);
	}
	return value.replace(/\/$/, "");
}

function parseConfig(value: unknown): Config {
	if (!isRecord(value) || !Array.isArray(value.destinations) || value.destinations.length === 0) {
		throw new Error("destinations must be a nonempty array");
	}

	const hosts = new Set<string>();
	const destinations = value.destinations.map((raw, index): Destination => {
		if (!isRecord(raw)) throw new Error(`destinations[${index}] must be an object`);
		if (typeof raw.host !== "string" || !SAFE_HOST.test(raw.host)) {
			throw new Error(`destinations[${index}].host must be a safe SSH alias`);
		}
		if (hosts.has(raw.host)) throw new Error(`duplicate destination host: ${raw.host}`);
		hosts.add(raw.host);
		if (raw.label !== undefined && typeof raw.label !== "string") throw new Error(`destinations[${index}].label must be a string`);
		if (raw.default !== undefined && typeof raw.default !== "boolean") throw new Error(`destinations[${index}].default must be a boolean`);
		return {
			host: raw.host,
			label: raw.label,
			default: raw.default,
			sessionRoot: validateRelativePath(raw.sessionRoot, `destinations[${index}].sessionRoot`),
		};
	});
	return { destinations };
}

async function loadConfig(): Promise<Config> {
	try {
		return parseConfig(JSON.parse(await readFile(CONFIG_PATH, "utf8")));
	} catch (error) {
		const reason = error instanceof Error ? error.message : String(error);
		throw new Error(`Invalid ${CONFIG_PATH}: ${reason}`);
	}
}

async function isLocalDestination(pi: ExtensionAPI, destination: Destination): Promise<boolean> {
	const localHostname = hostname().toLowerCase();
	if (destination.host.toLowerCase() === localHostname) return true;

	const result = await pi.exec("ssh", ["-G", destination.host], { timeout: SSH_TIMEOUT_MS });
	const configuredHostname = /^hostname (.+)$/m.exec(result.stdout)?.[1]?.toLowerCase();
	return configuredHostname === localHostname;
}

async function checkDestination(pi: ExtensionAPI, destination: Destination): Promise<DestinationStatus> {
	const remoteScript = [
		`root="$HOME/${destination.sessionRoot}"`,
		'printf "home=%s\\n" "$HOME"',
		'printf "rsync=%s\\n" "$(command -v rsync || true)"',
		'if test -d "$root"; then printf "sessionRoot=%s\\n" "$root"; find "$root" -type f -name "*.jsonl" | wc -l | tr -d " " | xargs printf "sessions=%s\\n"; else printf "sessionRoot=missing:%s\\n" "$root"; exit 3; fi',
	].join("; ");
	const result = await pi.exec(
		"ssh",
		["-o", "BatchMode=yes", "-o", `ConnectTimeout=${Math.ceil(SSH_TIMEOUT_MS / 1_000)}`, destination.host, remoteScript],
		{ timeout: SSH_TIMEOUT_MS },
	);
	const output = `${result.stdout}\n${result.stderr}`.trim();
	const home = /^home=(.+)$/m.exec(output)?.[1];
	const rsync = /^rsync=(.+)$/m.exec(output)?.[1];
	const sessionRoot = /^sessionRoot=(.+)$/m.exec(output)?.[1];
	const sessions = /^sessions=(\d+)$/m.exec(output)?.[1];
	const label = destination.label ? `${destination.label} (${destination.host})` : destination.host;

	if (result.code !== 0 || !home || !rsync || !sessionRoot || sessionRoot.startsWith("missing:")) {
		const reason = output || `ssh exited ${result.code ?? "without a status"}`;
		return { ok: false, lines: [`✗ ${label}`, `  ${reason.replace(/\s+/g, " ")}`] };
	}
	return {
		ok: true,
		lines: [
			`✓ ${label}`,
			`  SSH connected · remote home: ${home}`,
			`  rsync: ${rsync}`,
			`  Session registry: ${sessionRoot}`,
			`  Sessions found: ${sessions ?? "unknown"}`,
		],
	};
}

export default function sessionSyncExtension(pi: ExtensionAPI) {
	pi.registerCommand("session-sync-status", {
		description: "Test trusted Pi session registries over SSH",
		handler: async (_args, ctx) => {
			let config: Config;
			try {
				config = await loadConfig();
			} catch (error) {
				await ctx.ui.select("Session Sync Status", [error instanceof Error ? error.message : String(error)]);
				return;
			}
			const destinationsWithLocation = await Promise.all(
				config.destinations.map(async (destination) => ({
					destination,
					isLocal: await isLocalDestination(pi, destination),
				})),
			);
			const remoteDestinations = destinationsWithLocation.filter(({ isLocal }) => !isLocal).map(({ destination }) => destination);
			if (remoteDestinations.length === 0) {
				await ctx.ui.select("Session Sync Status", ["No remote session-sync destinations configured."]);
				return;
			}
			const statuses = await Promise.all(remoteDestinations.map((destination) => checkDestination(pi, destination)));
			await ctx.ui.select("Session Sync Status", statuses.flatMap((status) => status.lines));
		},
	});
}
