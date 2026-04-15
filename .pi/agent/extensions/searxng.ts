/**
 * SearXNG Web Search Extension
 *
 * Registers a `web_search` tool that queries a self-hosted SearXNG instance.
 * Override the instance URL by setting the SEARXNG_URL environment variable.
 *
 * SearXNG must have JSON format enabled in settings.yml:
 *   search.formats: [html, json]
 *
 * Supported categories (depends on your engine configuration):
 *   general  — web search engines (default)
 *   science  — arxiv, google scholar, pubmed, semantic scholar
 *   news     — news sources
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { Text } from "@mariozechner/pi-tui";
import { Type } from "@sinclair/typebox";

// ---------------------------------------------------------------------------
// Configuration
// ---------------------------------------------------------------------------

const DEFAULT_SEARXNG_URL = "https://search.gerbil-matrix.ts.net";
const MAX_RESULTS = 8;

// ---------------------------------------------------------------------------
// Types
// ---------------------------------------------------------------------------

interface SearXNGResult {
  url: string;
  title: string;
  content?: string;
  engine?: string;
  engines?: string[];
  score?: number;
  category?: string;
  publishedDate?: string;
}

interface SearXNGResponse {
  query: string;
  number_of_results: number;
  results: SearXNGResult[];
  answers?: string[];
  infoboxes?: Array<{ infobox: string; content?: string }>;
  suggestions?: string[];
  unresponsive_engines?: string[];
}

interface FormattedResult {
  title: string;
  url: string;
  snippet: string;
  engine?: string;
  date?: string;
}

interface SearchDetails {
  query: string;
  categories: string;
  totalResults: number;
  results: FormattedResult[];
  answer?: string;
  error?: string;
}

// ---------------------------------------------------------------------------
// Extension
// ---------------------------------------------------------------------------

export default function (pi: ExtensionAPI) {
  const baseUrl = (process.env.SEARXNG_URL ?? DEFAULT_SEARXNG_URL).replace(/\/$/, "");

  pi.registerTool({
    name: "web_search",
    label: "Web Search",
    description:
      'Search the web via self-hosted SearXNG. Use for current facts, documentation, recent events, or information not in training data.',
    promptSnippet: "Search the web via self-hosted SearXNG (general, science, news categories, etc.)",

    parameters: Type.Object({
      query: Type.String({
        description: "The search query",
      }),
      categories: Type.Optional(
        Type.String({
          description:
            'Search category. "general" (default) for web, "science" for academic papers, "news" for current events. Comma-separate for multiple.',
        })
      ),
    }),

    async execute(_toolCallId, params, signal, onUpdate, _ctx) {
      const categories = params.categories ?? "general";

      // Stream a progress update while fetching
      onUpdate?.({
        content: [{ type: "text", text: `Searching [${categories}]: ${params.query}` }],
        details: {
          query: params.query,
          categories,
          totalResults: 0,
          results: [],
        } as SearchDetails,
      });

      // Build request URL
      const url = new URL(`${baseUrl}/search`);
      url.searchParams.set("q", params.query);
      url.searchParams.set("format", "json");
      url.searchParams.set("categories", categories);

      // Fetch
      let data: SearXNGResponse;
      try {
        const response = await fetch(url.toString(), {
          signal,
          headers: { Accept: "application/json" },
        });
        if (!response.ok) {
          throw new Error(`HTTP ${response.status}: ${response.statusText}`);
        }
        data = (await response.json()) as SearXNGResponse;
      } catch (err: unknown) {
        if (signal?.aborted) {
          return {
            content: [{ type: "text", text: "Search cancelled." }],
            details: { query: params.query, categories, totalResults: 0, results: [] } as SearchDetails,
          };
        }
        const msg = err instanceof Error ? err.message : String(err);
        const details: SearchDetails = {
          query: params.query,
          categories,
          totalResults: 0,
          results: [],
          error: msg,
        };
        throw new Error(`SearXNG search failed: ${msg}`);
      }

      // Deduplicate by URL, keep top N
      const seen = new Set<string>();
      const topResults: FormattedResult[] = [];

      for (const r of data.results) {
        if (seen.has(r.url)) continue;
        seen.add(r.url);
        topResults.push({
          title: r.title,
          url: r.url,
          snippet: r.content ?? "",
          engine: r.engines?.[0] ?? r.engine,
          date: r.publishedDate,
        });
        if (topResults.length >= MAX_RESULTS) break;
      }

      // Extract top direct answer (from infoboxes or answers array)
      const answer =
        data.infoboxes?.[0]?.content ??
        data.answers?.[0] ??
        undefined;

      // Build LLM-readable markdown
      const lines: string[] = [];

      if (answer) {
        lines.push(`> **${answer}**\n`);
      }

      if (topResults.length === 0) {
        lines.push("No results found.");
      } else {
        for (const r of topResults) {
          lines.push(`### ${r.title}`);
          lines.push(`<${r.url}>`);
          const meta: string[] = [];
          if (r.engine) meta.push(r.engine);
          if (r.date) meta.push(r.date);
          if (meta.length > 0) lines.push(`*${meta.join(" · ")}*`);
          if (r.snippet) lines.push(r.snippet);
          lines.push("");
        }
      }

      const details: SearchDetails = {
        query: params.query,
        categories,
        totalResults: data.number_of_results,
        results: topResults,
        answer,
      };

      return {
        content: [{ type: "text", text: lines.join("\n") }],
        details,
      };
    },

    // -----------------------------------------------------------------------
    // TUI rendering
    // -----------------------------------------------------------------------

    renderCall(args, theme, _context) {
      const cat = args.categories ? theme.fg("dim", ` [${args.categories}]`) : "";
      return new Text(
        theme.fg("toolTitle", theme.bold("web_search ")) +
          theme.fg("muted", args.query) +
          cat,
        0,
        0
      );
    },

    renderResult(result, _options, theme, _context) {
      const details = result.details as SearchDetails | undefined;

      if (!details) {
        const raw = result.content[0];
        return new Text(raw?.type === "text" ? raw.text : "", 0, 0);
      }

      if (details.error) {
        return new Text(theme.fg("error", `Error: ${details.error}`), 0, 0);
      }

      if (details.results.length === 0) {
        return new Text(theme.fg("dim", "No results"), 0, 0);
      }

      const total =
        details.totalResults > 0
          ? theme.fg("dim", ` of ~${details.totalResults.toLocaleString()}`)
          : "";
      let text =
        theme.fg("success", `✓ ${details.results.length} results`) + total;

      if (details.answer) {
        text += `\n${theme.fg("accent", details.answer)}`;
      }

      for (const r of details.results.slice(0, 3)) {
        const eng = r.engine ? theme.fg("dim", ` [${r.engine}]`) : "";
        text += `\n${theme.fg("accent", r.title)}${eng}`;
        text += `\n${theme.fg("dim", r.url)}`;
      }

      if (details.results.length > 3) {
        text += `\n${theme.fg("dim", `… +${details.results.length - 3} more`)}`;
      }

      return new Text(text, 0, 0);
    },
  });
}
