import { readFile } from "node:fs/promises";
import { getAgentDir, type ExtensionAPI } from "@earendil-works/pi-coding-agent";

type ProjectMapping = {
	localPath: string;
	remotePath: string;
};

type Destination = {
	host: string;
	label?: string;
	sessionRoot: string;
	default?: boolean;
	projects: ProjectMapping[];
};

type Config = {
	destinations: Destination[];
};

type DestinationStatus = {
	destination: Destination;
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

function validatePath(value: unknown, name: string, absolute: boolean): string {
	if (typeof value !== "string" || value.length === 0) throw new Error(`${name} must be a nonempty string`);
	if (absolute ? !value.startsWith("/") : value.startsWith("/")) throw new Error(`${name} has invalid absolute-path form`);
	const normalized = absolute ? value.slice(1) : value;
	if (!SAFE_PATH.test(normalized) || normalized.split("/").some((part) => part === "." || part === "..")) {
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
		const host = raw.host;
		if (typeof host !== "string" || !SAFE_HOST.test(host)) {
			throw new Error(`destinations[${index}].host must be a safe SSH alias`);
		}
		if (hosts.has(host)) throw new Error(`duplicate destination host: ${host}`);
		hosts.add(host);
		if (raw.label !== undefined && typeof raw.label !== "string") throw new Error(`destinations[${index}].label must be a string`);
		if (raw.default !== undefined && typeof raw.default !== "boolean") throw new Error(`destinations[${index}].default must be a boolean`);
		if (!Array.isArray(raw.projects)) throw new Error(`destinations[${index}].projects must be an array`);

		const projects = raw.projects.map((project, projectIndex): ProjectMapping => {
			if (!isRecord(project)) throw new Error(`destinations[${index}].projects[${projectIndex}] must be an object`);
			return {
				localPath: validatePath(project.localPath, `destinations[${index}].projects[${projectIndex}].localPath`, true),
				remotePath: validatePath(project.remotePath, `destinations[${index}].projects[${projectIndex}].remotePath`, true),
			};
		});

		return {
			host,
			label: raw.label,
			default: raw.default,
			sessionRoot: validatePath(raw.sessionRoot, `destinations[${index}].sessionRoot`, false),
			projects,
		};
	});

	return { destinations };
}

async function loadConfig(): Promise<Config> {
	let content: string;
	try {
		content = await readFile(CONFIG_PATH, "utf8");
	} catch (error) {
		const reason = error instanceof Error ? error.message : String(error);
		throw new Error(`Cannot read ${CONFIG_PATH}: ${reason}`);
	}
	try {
		return parseConfig(JSON.parse(content));
	} catch (error) {
		const reason = error instanceof Error ? error.message : String(error);
		throw new Error(`Invalid ${CONFIG_PATH}: ${reason}`);
	}
}

async function checkDestination(pi: ExtensionAPI, destination: Destination, cwd: string): Promise<DestinationStatus> {
	const remoteScript = [
		`root="$HOME/${destination.sessionRoot}"`,
		'printf "home=%s\\n" "$HOME"',
		'printf "rsync=%s\\n" "$(command -v rsync || true)"',
		'if test -d "$root"; then printf "sessionRoot=%s\\n" "$root"; else printf "sessionRoot=missing:%s\\n" "$root"; exit 3; fi',
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
	const label = destination.label ? `${destination.label} (${destination.host})` : destination.host;

	if (result.code !== 0 || !home || !rsync || !sessionRoot || sessionRoot.startsWith("missing:")) {
		const reason = output || `ssh exited ${result.code ?? "without a status"}`;
		return { destination, ok: false, lines: [`✗ ${label}`, `  ${reason.replace(/\s+/g, " ")}`] };
	}

	const mapping = destination.projects
		.filter((project) => cwd === project.localPath || cwd.startsWith(`${project.localPath}/`))
		.sort((left, right) => right.localPath.length - left.localPath.length)[0];
	const mappingLine = mapping
		? `  Current cwd mapping: ${mapping.localPath} → ${mapping.remotePath}`
		: `  Current cwd not mapped: ${cwd}`;
	return {
		destination,
		ok: true,
		lines: [
			`✓ ${label}`,
			`  SSH connected · remote home: ${home}`,
			`  rsync: ${rsync}`,
			`  Session root: ${sessionRoot}`,
			mappingLine,
		],
	};
}

export default function sessionSyncExtension(pi: ExtensionAPI) {
	pi.registerCommand("session-sync-status", {
		description: "Test trusted Pi session-sync SSH destinations",
		handler: async (_args, ctx) => {
			let config: Config;
			try {
				config = await loadConfig();
			} catch (error) {
				await ctx.ui.select("Session Sync Status", [error instanceof Error ? error.message : String(error)]);
				return;
			}

			const statuses = await Promise.all(config.destinations.map((destination) => checkDestination(pi, destination, ctx.cwd)));
			const lines = statuses.flatMap((status) => status.lines);
			await ctx.ui.select("Session Sync Status", lines);
		},
	});
}
