---
name: orbitr
description: Search academic literature and manage references with the `orbitr` CLI. Use for academic literature searches, paper lookups, citation exploration, finding related work, author bibliographies, query translation, exporting references to BibTeX/RIS/CSL-JSON, and managing a Zotero library.
---

# Orbitr Research Skill

## Purpose

Control the `orbitr` command-line bibliographic-search and reference-management tool. `orbitr` queries arXiv and Semantic Scholar concurrently, deduplicates results, and can export findings or add them directly to a Zotero library.

## When to use

Use this skill when the user asks for anything like:

- Academic literature search on a topic, method, paper, or author.
- Finding papers, abstracts, citations, related work, or venue information.
- Fetching details for a specific paper by DOI, arXiv ID, or Semantic Scholar ID.
- Translating a natural-language research question into a query.
- Exporting references in BibTeX, RIS, or CSL-JSON.
- Adding references to a Zotero library, collection, or folder.
- Listing, searching, or organizing Zotero collections and items.
- Diagnosing `orbitr` connectivity or credential issues.

## Configuration

- Config file: `~/.config/orbitr/config.toml`.
- Default sources: `arxiv`, `semantic_scholar`.
- Zotero integration requires `zotero_user_id` and `zotero_api_key` in config.
- Use `orbitr init` to set credentials interactively.
- Use `orbitr doctor` to verify config and API connectivity.

## Common options reference

| Option | Use |
| --- | --- |
| `-n, --limit` | Max results (search/cite/author up to 200; recommend up to 50). |
| `-s, --sources` | Comma-separated: `arxiv`, `semantic_scholar`. |
| `-f, --format` | `table`, `list`, `detail` (default), `json`. JSON outputs JSONL. |
| `--sort` | `relevance` (default), `citations`, `date`, `impact`, `combined`. |
| `-T, --title` | Title keyword filter. |
| `-a, --author` | Author name filter. |
| `-j, --venue` | Venue filter. |
| `--from YEAR` | Exclude papers before year. |
| `--to YEAR` | Exclude papers after year. |
| `--no-cache` | Bypass the SQLite cache at `~/.cache/orbitr`. |
| `--output PATH` | Write `export` output to a file. |

## Capability map

| User intent | Command pattern |
| --- | --- |
| Search literature | `orbitr search "QUERY" [-n N] [-a AUTHOR] [--from YYYY] [--sort FIELD]` |
| View one paper | `orbitr paper <arxiv-id\|doi\|ss-id>` |
| Find papers citing X | `orbitr cite <id> -n N` |
| Author bibliography | `orbitr author "Name" -n N` |
| Similar papers | `orbitr recommend <id> -n N` |
| Natural language query | `orbitr query "DESCRIPTION" --run` |
| Export results to file | `orbitr search "Q" --format json \| orbitr export --format <bibtex\|ris\|csl-json> -o refs.ext` |
| Export single paper | `orbitr paper <id> --format json \| orbitr export --format bibtex` |
| Add to Zotero | `orbitr zotero add <id> -c "COLLECTION" -t "tag1,tag2"` |
| List Zotero collections | `orbitr zotero collections` |
| Create collection | `orbitr zotero new "NAME" [-p "PARENT"]` |
| Browse Zotero items | `orbitr zotero list [-c COLLECTION] [-n N] [--format table\|json\|keys]` |
| Search Zotero library | `orbitr zotero search "QUERY" [-c COLLECTION] [-n N]` |
| Recent Zotero items | `orbitr zotero recent [--days N] [--since YYYY-MM-DD]` |
| Export Zotero item to Markdown | `orbitr zotero export-md <ITEM_KEY> -o dir/` |
| Cache maintenance | `orbitr cache stats` / `orbitr cache clean` / `orbitr cache clear` |

## Workflows

### 1. Search and inspect

```bash
orbitr search "task-based language teaching" --from 2020 -n 20 --sort citations
orbitr search "title:pragmatic competence" -a "Taguchi" --format detail
```

### 2. Natural language to query

```bash
orbitr query "recent papers on corrective feedback in L2 writing" --run
```

### 3. Export references to a project file

```bash
orbitr search "dynamic assessment in education" --format json -n 30 \
  | orbitr export --format bibtex -o ~/Projects/my-paper/references.bib
```

Alternatively export as RIS or CSL-JSON:

```bash
orbitr export --query "usage-based SLA" --format csl-json -o refs.json
```

### 4. Add search results to Zotero

First identify the paper, then add by ID:

```bash
orbitr paper "10.1016/j.system.2021.102756" --format list
orbitr zotero add "10.1016/j.system.2021.102756" -c "SLA Reading" -t "systematic-review,2026"
```

### 5. Explore a paper's network

```bash
orbitr paper 1706.03762 --format detail
orbitr cite 1706.03762 -n 25 --sort citations
orbitr recommend 1706.03762 -n 20
orbitr author "Ashish Vaswani" -n 10
```

### 6. Organize Zotero library

```bash
orbitr zotero collections
orbitr zotero new "NLP in Education" -p "Dissertation"
orbitr zotero list -c "NLP in Education" --format keys \
  | xargs -I{} orbitr zotero export-md {} -o kb/sources/raw/
```

## Output handling

- `table`, `list`, and `detail` are human-readable. Prefer `detail` for abstracts and URLs.
- `json` produces JSONL. Pipe it to `orbitr export` for bibliography formats.
- Capture stderr separately when scripting; errors may not be in JSON.

## Error handling and diagnostics

- If Zotero commands fail, verify credentials with `orbitr doctor`.
- If searches return no results, broaden terms, drop filters, or try a single source with `-s semantic_scholar`.
- If metadata looks stale, use `--no-cache` or run `orbitr cache clean`.
- Before `orbitr cache clear`, confirm the user wants to delete all cached entries.

## Safety and best practices

- Do not add large numbers of items to Zotero without user confirmation; summarize what will be added first.
- Avoid exposing API keys; use `orbitr init` and reference config, never paste secrets into prompts.
- PDF URLs from Semantic Scholar may require authentication; treat them as hints, not guaranteed downloads.
- When exporting, verify the target format matches the user's target journal or reference manager.

## Useful IDs

- arXiv ID: e.g. `1706.03762`
- DOI: e.g. `10.18653/v1/2020.acl-main.196`
- Semantic Scholar ID: e.g. `ss:abc123...`
