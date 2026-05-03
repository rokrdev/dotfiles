---
name: web-fetch
description: Use when fetching any webpage to read its content — articles, docs, product pages, SPAs, anything reachable by URL. Handles JavaScript-rendered pages. Keeps all content in the context-mode sandbox to prevent context flooding. Triggers: user says "fetch this URL / read this page / check this site / look at this link", or Claude needs to read web content for any task (research, docs lookup, link previews, etc.).
when_to_use: |
  Invoke whenever you need to fetch and read a webpage:
  - User provides a URL and asks you to read, check, summarize, or extract from it
  - You need to look up documentation, articles, release notes, or any web content
  - You are researching something and want to read a specific page
  - A tool result contains a URL you need to follow and read

  Do NOT use for:
  - Searching the web (use WebSearch)
  - Fetching raw API/JSON endpoints (use ctx_execute with fetch in sandbox)
  - Reading local files (use Read or ctx_execute_file)
  - GitHub file content via API (use gh CLI or ctx_execute)
---

# web-fetch

Fetch any webpage, optionally render JavaScript, convert to markdown, index for search — without flooding the context window.

## Decision: Which lane to use

```
Is the page likely static?
(GitHub READMEs, MDN, Stack Overflow, Wikipedia, blog posts, RFCs, npm docs)
  → YES → Lane 1 (direct fetch)

Is the page a SPA or known JS-heavy site?
(Vercel docs, Notion, Twitter/X, LinkedIn, *.vercel.app, React/Next.js app sites,
 or Lane 1 returned < 500 chars of usable content)
  → YES → Lane 2 (Jina AI — JS rendering)

Is the page behind a login, paywalled, or Jina is unavailable?
  → YES → Lane 3 (web-to-markdown CLI, requires prior install)
```

After ANY lane: always call `ctx_search` to query indexed content.

---

## Lane 1 — Static fetch (default)

```
ctx_fetch_and_index("{url}", "{descriptive-label}")
ctx_search(queries: ["your question about the page"])
```

**Example:**
```
ctx_fetch_and_index("https://docs.python.org/3/library/asyncio.html", "python-asyncio-docs")
ctx_search(queries: ["how to run coroutine", "event loop", "asyncio.run"])
```

---

## Lane 2 — JS-rendered pages (Jina AI)

Prefix the URL with `https://r.jina.ai/`. Jina renders the page server-side and returns clean LLM-optimized markdown. Free: 20 req/min without API key; 500 req/min with free `JINA_API_KEY`.

```
ctx_fetch_and_index("https://r.jina.ai/{url}", "{descriptive-label}")
ctx_search(queries: ["your question about the page"])
```

**Example:**
```
ctx_fetch_and_index("https://r.jina.ai/https://vercel.com/docs/functions/edge-functions", "vercel-edge-functions-docs")
ctx_search(queries: ["edge function limits", "runtime", "how to deploy"])
```

**Fallback trigger:** If Lane 1 returned < 500 chars or search returned no relevant results, retry with Lane 2 automatically.

---

## Lane 3 — Local JS rendering (escape hatch)

Use only when Lane 2 is unavailable or page requires authentication. Requires `web-to-markdown` CLI installed: `npm install -g web-to-markdown`.

```
ctx_execute(language: "shell", code: "web-to-markdown '{url}'")
```

Then index the output manually:
```
ctx_index("{output from ctx_execute}", "{descriptive-label}")
ctx_search(queries: ["your question about the page"])
```

**Note:** `web-to-markdown` launches a real Chrome/Chromium browser. First run downloads Chromium (~300MB). Use sparingly — Lane 2 handles 95% of cases.

---

## Multi-page fetching

For fetching several pages at once, call `ctx_fetch_and_index` in sequence with distinct labels, then run a single `ctx_search` with all your queries:

```
ctx_fetch_and_index("https://r.jina.ai/https://site.com/page1", "site-page1")
ctx_fetch_and_index("https://r.jina.ai/https://site.com/page2", "site-page2")
ctx_search(queries: ["question 1", "question 2", "question 3"])
```

---

## Rules

1. **Never use raw `WebFetch`** — it is blocked and floods context.
2. **Always follow fetch with `ctx_search`** — indexed content is useless without querying.
3. **Use descriptive labels** — the label becomes the FTS5 chunk title; good labels improve search accuracy. Format: `{site}-{topic}` e.g. `stripe-webhooks-docs`.
4. **Lane 2 is the safe default for any doubt** — the Jina prefix costs nothing extra and avoids thin-content failures.
5. **Lane 3 is rarely needed** — document the reason when you use it.
