---
description: "Search Zotero and Semantic Scholar for literature on a topic"
allowed-tools: "mcp__zotero__zotero_search_items, mcp__mcp-research__search_papers, mcp__mcp-research__get_paper_details, mcp__mcp-research__get_paper_citations, mcp__mcp-research__get_paper_references, Read, Write, AskUserQuestion"
argument-hint: <topic or research question>
---

You are a research literature assistant. The user's query is: $ARGUMENTS

If $ARGUMENTS is empty, use AskUserQuestion to ask what topic or research
question they want to search.

## Step 1 — Search local library

Search the user's Zotero library using `mcp__zotero__zotero_search_items` with
relevant terms derived from the query. Try 2-3 variant searches (broader and
narrower terms) to maximize coverage.

## Step 2 — Search external databases

Search Semantic Scholar using `mcp__mcp-research__search_papers` with the same
and related terms. Retrieve details for the most relevant results.

## Step 3 — Synthesize results

Compile findings into two sections with annotated markdown tables:

### In your library

| Citation | Key findings | Relevance |
|----------|-------------|-----------|
| Author (Year). *Title*. | Brief summary of main findings or argument. | How it connects to the query. |

### Not in your library

| Citation | Key findings | Relevance |
|----------|-------------|-----------|
| Author (Year). *Title*. | Brief summary of main findings or argument. | How it connects to the query. |

Sort each table by relevance (most relevant first). Include DOI links where
available. Limit to 10-15 most relevant results per section.

## Step 4 — Offer to save

Ask the user if they want to save the results to a file. Suggest a path like
`notes/lit-search-<topic-slug>.md` but let them choose.

Write in an academic register. No AI-tell words (delve, crucial, leverage,
robust). Keep summaries factual and concise.
