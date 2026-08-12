import { access, mkdir, readFile } from "node:fs/promises";
import { hostname } from "node:os";
import { dirname, join } from "node:path";
import { DynamicBorder, getAgentDir, getSelectListTheme, type ExtensionAPI, type ExtensionCommandContext } from "@earendil-works/pi-coding-agent";
import { Container, Input, Key, matchesKey, SelectList, Text, type SelectItem } from "@earendil-works/pi-tui";

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

function isSafeSessionFile(value: string): boolean {
	return SAFE_PATH.test(value) && value.endsWith(".jsonl");
}

async function localFileExists(path: string): Promise<boolean> {
	try {
		await access(path);
		return true;
	} catch {
		return false;
	}
}

async function listRemoteSessions(pi: ExtensionAPI, destination: Destination): Promise<string[]> {
	const remoteScript = `cd "$HOME/${destination.sessionRoot}" && find . -type f -name "*.jsonl" -print`;
	const result = await pi.exec(
		"ssh",
		["-o", "BatchMode=yes", "-o", `ConnectTimeout=${Math.ceil(SSH_TIMEOUT_MS / 1_000)}`, destination.host, remoteScript],
		{ timeout: SSH_TIMEOUT_MS },
	);
	if (result.code !== 0) throw new Error(`${result.stdout}\n${result.stderr}`.trim() || `ssh exited ${result.code ?? "without a status"}`);

	const localSessionRoot = join(getAgentDir(), "sessions");
	return (await Promise.all(
		result.stdout.split("\n")
			.map((path) => path.replace(/^\.\//, ""))
			.filter(isSafeSessionFile)
			.map(async (path) => ({ path, exists: await localFileExists(join(localSessionRoot, path)) })),
	)).filter(({ exists }) => !exists).map(({ path }) => path).sort();
}

async function pullDestination(pi: ExtensionAPI, destination: Destination, sessionFile: string, dryRun: boolean) {
	const localSessionRoot = join(getAgentDir(), "sessions");
	const localSessionFile = join(localSessionRoot, sessionFile);
	await mkdir(dirname(localSessionFile), { recursive: true });
	return pi.exec(
		"rsync",
		[
			"--archive",
			"--ignore-existing",
			"--itemize-changes",
			"--out-format=%i %n",
			...(dryRun ? ["--dry-run"] : []),
			`${destination.host}:${destination.sessionRoot}/${sessionFile}`,
			localSessionFile,
		],
		{ timeout: 60_000 },
	);
}

function transferLines(result: { stdout: string; stderr: string }) {
	return `${result.stdout}\n${result.stderr}`.trim().split("\n").filter(Boolean);
}

async function selectSession(ctx: ExtensionCommandContext, host: string, sessions: string[]) {
	const items: SelectItem[] = sessions.map((session) => ({ value: session, label: session }));
	return ctx.ui.custom<string | undefined>((tui, theme, _keybindings, done) => {
		const container = new Container();
		const search = new Input();
		const sessionsList = new SelectList(items, 12, getSelectListTheme());
		search.focused = true;
		sessionsList.onSelect = (item) => done(item.value);
		sessionsList.onCancel = () => done(undefined);
		container.addChild(new DynamicBorder((text: string) => theme.fg("accent", text)));
		container.addChild(new Text(theme.fg("accent", theme.bold(`Pull session from ${host}`)), 1, 0));
		container.addChild(new Text(theme.fg("dim", "Search: type to filter"), 1, 0));
		container.addChild(search);
		container.addChild(sessionsList);
		container.addChild(new Text(theme.fg("dim", "↑↓ navigate · enter select · esc cancel"), 1, 0));
		container.addChild(new DynamicBorder((text: string) => theme.fg("accent", text)));
		return {
			render: (width) => container.render(width),
			invalidate: () => container.invalidate(),
			handleInput: (data) => {
				if (matchesKey(data, Key.up) || matchesKey(data, Key.down) || matchesKey(data, Key.enter) || matchesKey(data, Key.escape) || matchesKey(data, Key.ctrl("c"))) {
					sessionsList.handleInput(data);
				} else {
					search.handleInput(data);
					sessionsList.setFilter(search.getValue());
				}
				tui.requestRender();
			},
		};
	});
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
	pi.registerCommand("session-sync-pull", {
		description: "Pull new Pi session transcripts from a trusted SSH destination",
		handler: async (args, ctx) => {
			let config: Config;
			try {
				config = await loadConfig();
			} catch (error) {
				await ctx.ui.select("Session Sync Pull", [error instanceof Error ? error.message : String(error)]);
				return;
			}
			const destinations = (await Promise.all(
				config.destinations.map(async (destination) => ({
					destination,
					isLocal: await isLocalDestination(pi, destination),
				})),
			)).filter(({ isLocal }) => !isLocal).map(({ destination }) => destination);
			const requestedHost = args.trim();
			const destination = requestedHost
				? destinations.find(({ host }) => host === requestedHost)
				: destinations.find(({ default: isDefault }) => isDefault) ?? destinations[0];
			if (!destination) {
				await ctx.ui.select("Session Sync Pull", [requestedHost ? `Unknown or local destination: ${requestedHost}` : "No remote session-sync destinations configured."]);
				return;
			}

			let sessions: string[];
			try {
				sessions = await listRemoteSessions(pi, destination);
			} catch (error) {
				await ctx.ui.select("Session Sync Pull", [`✗ ${destination.host}`, error instanceof Error ? error.message : String(error)]);
				return;
			}
			if (sessions.length === 0) {
				await ctx.ui.select("Session Sync Pull", [`${destination.host}: no new session transcripts.`]);
				return;
			}
			const sessionFile = await selectSession(ctx, destination.host, sessions);
			if (!sessionFile) return;

			const preview = await pullDestination(pi, destination, sessionFile, true);
			const previewLines = transferLines(preview);
			if (preview.code !== 0) {
				await ctx.ui.select("Session Sync Pull", [`✗ ${destination.host}`, ...previewLines]);
				return;
			}
			const confirmed = await ctx.ui.confirm(
				"Pull Pi Session",
				`Copy ${sessionFile} from ${destination.host}? Existing local files stay unchanged.`,
			);
			if (!confirmed) return;

			const result = await pullDestination(pi, destination, sessionFile, false);
			const resultLines = transferLines(result);
			await ctx.ui.select("Session Sync Pull", result.code === 0
				? [`✓ Pulled ${sessionFile} from ${destination.host}.`, ...resultLines]
				: [`✗ ${destination.host}`, ...resultLines]);
		},
	});

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
