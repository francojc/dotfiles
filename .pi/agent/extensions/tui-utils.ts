/**
 * Shared TUI layout helpers for Pi extensions.
 *
 * Pure functions. No side effects. Theme-agnostic (accepts any theme object).
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { truncateToWidth } from "@earendil-works/pi-tui";

/**
 * No-op extension factory so Pi doesn't reject this file as a utility module
 * living in extensions/. Other extensions import the named exports below.
 */
export default function (_pi: ExtensionAPI): void {
	// Utility module — no extension registration needed.
}

// eslint-disable-next-line @typescript-eslint/no-explicit-any
type AnyTheme = any;

/**
 * Push a line into the array, truncating to width.
 */
export function addLine(lines: string[], text: string, width: number): void {
	lines.push(truncateToWidth(text, width));
}

/**
 * Horizontal border line.
 * With label: centers it between border-muted dashes.
 * Without label: full-width accent dashes.
 */
export function borderLine(width: number, theme: AnyTheme, label?: string): string {
	const dash = "─";
	if (!label) {
		return theme.fg("accent", dash.repeat(width));
	}
	const pad = Math.max(0, width - label.length);
	const left = Math.floor(pad / 2);
	const right = pad - left;
	return (
		theme.fg("borderMuted", dash.repeat(left)) +
		label +
		theme.fg("borderMuted", dash.repeat(right))
	);
}

/**
 * Dim help/hint text for footer lines.
 */
export function dimHint(text: string, theme: AnyTheme): string {
	return theme.fg("dim", text);
}
