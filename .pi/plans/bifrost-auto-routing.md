# Bifrost-side routing via a Pi `auto` model

Design mockup. Pi sends one logical model ID. Bifrost decides everything else:
complexity tier, provider, physical model, fallback chain, load balancing.

    Pi  ──model:"auto"──▶  Bifrost /v1/chat/completions
                            │
                            ├─ Virtual Key  → provider scope, allowlists, weights, budgets
                            ├─ Routing Rules → CEL → weighted target + fallbacks
                            └─ Complexity Analyzer → complexity_tier ∈ SIMPLE|MEDIUM|COMPLEX

Gateway: `https://bifrost.gerbil-matrix.ts.net`, version `v2.3.0` (verified 2026-10-25).
Routing plugin `plugins/routing/v1.2.2`, OSS. Complexity Router is an OSS feature.

---

## 0. Blockers found during recon

Verify each before building. Numbers from a live sweep of all 85 models on the VK.

| # | Finding | Evidence | Effect on this plan |
| --- | --- | --- | --- |
| B1 | **The VK cannot see model `auto` yet.** `{"message": "Model 'auto' is not allowed for virtual key 'Main'"}` | `POST /v1/chat/completions {"model":"opencode-zen/auto"}` → 403 | Routing rules run after VK resolution, so they cannot rescue this. The VK's `allowed_models` must include the sentinel name. |
| B2 | **55 of 85 models reject `POST /v1/chat/completions` with `ModelProtocolUnsupported`.** All GPT, Claude, Gemini, Grok, muse, jev entries. | live probe | Routing to any of them fails. Only 17 models are chat-completions-usable. |
| B3 | **10 models are `FreeTierError`** (`*free`, `beam-free`, `big-pickle`, `test`). | live probe | Never place these in a tier pool. |
| B4 | **3 models are `410 Endpoint is unavailable`** (`kimi-k2.5`, `kimi-k2.6`, `kimi-k2.7-code`). | live probe | Leave out of pools, or let the fallback chain absorb. |
| B5 | **VK is named `Main` and is provider-scoped to `opencode-zen` only** (85 models, one provider). | `GET /v1/models` | Single provider config → no cross-provider weighted LB. Provider routing is a no-op until a second provider is added. |
| B6 | **Admin API rejects the VK.** `/api/routing/*`, `/api/governance/*`, `/api/adaptive-routing/*` all return 401 with `x-bf-vk`. | probe | Rule creation must happen in the dashboard UI (or with admin credentials). `GET /api/adaptive-routing/config` returns the HTML shell on VK auth — a misleading 200. |
| B7 | **Adaptive Routing is Enterprise-only** (`docs.getbifrost.ai/enterprise/adaptive-routing/*`, absent from the OSS index). | llms.txt section layout | Use Routing Rules for balancing, not adaptive routing. |
| B8 | **Provider aliases are per-key, not per-VK.** `Key.aliases` maps a user-facing name to a provider-specific ID (deployment name, inference profile, fine-tuned ID) on a provider key. | OpenAPI `Key.properties.aliases` | Equivalent outcome: alias `auto` on the OpenCode Zen key → any physical model you route to. Must be set on the provider key, not the VK. |

If B8 is not used, keep the sentinel name out of any pool and rely on
`chain_rule` to rewrite it before the request reaches the provider.

---

## 1. Gateway mockup

### 1.1 Virtual Key — `Main`

Dashboard → **Governance → Virtual Keys → Main**.

| Field | Current | Target |
| --- | --- | --- |
| `allow_all_providers` | false | leave false |
| Provider Configs → `opencode-zen` → `allowed_models` | list/`["*"]` scoped to 85 | must also admit the sentinel name (`auto`) |
| `blacklisted_models` | – | `["regex:.*-free$", "beam-free", "big-pickle", "test", "kimi-k2.*"]` |
| `weight` | – | leave null (single provider) |

`blacklisted_models` wins over the allowlist and supports RE2 patterns. Use it to
kill the free-tier and dead-endpoint classes from B2–B4 so they can never enter a
pool by accident. This is the cheapest correctness win in the whole plan.

When a second provider is added later, give each a `weight` and the VK builds
automatic fallback chains from the weighted providers.

### 1.2 Routing Rules

Order matters: `virtual_key` scope → `user` → `team` → `customer` → `global`.
Within a scope, ascending `priority`. First match wins unless `chain_rule` is set.

Recommended layering:

**Tier 0 — manual override by header (priority 0–2)**

Lets you pick a tier per session from Pi's `/model` picker without leaving the TUI.
Each provider ID in Pi's `models.json` sends a different `x-bf-tier` header.

```json
{
  "name": "manual-fast",
  "description": "Pi provider bifrost-fast pins the cheap tier",
  "enabled": true,
  "chain_rule": false,
  "cel_expression": "headers[\"x-bf-tier\"] == \"fast\"",
  "targets": [{ "provider": "opencode-zen", "model": "glm-5.3-flash", "weight": 1 }],
  "fallbacks": ["opencode-zen/deepseek-v4.1-flash", "opencode-zen/minimax-m3"],
  "scope": "virtual_key",
  "scope_id": "<Main VK id>",
  "priority": 0
}
```

```json
{
  "name": "manual-frontier",
  "description": "Pi provider bifrost-frontier pins the frontier tier",
  "enabled": true,
  "chain_rule": false,
  "cel_expression": "headers[\"x-bf-tier\"] == \"frontier\"",
  "targets": [{ "provider": "opencode-zen", "model": "qwen3.8-max", "weight": 1 }],
  "fallbacks": ["opencode-zen/deepseek-v4-pro", "opencode-zen/glm-5.3"],
  "scope": "virtual_key",
  "scope_id": "<Main VK id>",
  "priority": 1
}
```

**Tier 1 — complexity routing (priority 10–12)**

`complexity_tier` is only computed when a rule references it, so this is the only
place that pays the classifier cost.

```json
{
  "name": "complexity-simple",
  "description": "Direct work, one step, no specialist knowledge",
  "enabled": true,
  "chain_rule": false,
  "cel_expression": "complexity_tier == \"SIMPLE\"",
  "targets": [
    { "provider": "opencode-zen", "model": "glm-5.3-flash", "weight": 1 }
  ],
  "fallbacks": ["opencode-zen/deepseek-v4.1-flash"],
  "scope": "virtual_key",
  "scope_id": "<Main VK id>",
  "priority": 10
}
```

```json
{
  "name": "complexity-medium",
  "description": "Focused work needing subject knowledge or a few steps",
  "enabled": true,
  "chain_rule": false,
  "cel_expression": "complexity_tier == \"MEDIUM\"",
  "targets": [
    { "provider": "opencode-zen", "model": "deepseek-v4.1-flash", "weight": 0.5 },
    { "provider": "opencode-zen", "model": "minimax-m3",         "weight": 0.3 },
    { "provider": "opencode-zen", "model": "qwen3.8-flash",      "weight": 0.2 }
  ],
  "fallbacks": ["opencode-zen/glm-5.3", "opencode-zen/mistral-large-4"],
  "scope": "virtual_key",
  "scope_id": "<Main VK id>",
  "priority": 11
}
```

```json
{
  "name": "complexity-complex",
  "description": "Advanced expertise plus derivation, design, or synthesis",
  "enabled": true,
  "chain_rule": false,
  "cel_expression": "complexity_tier == \"COMPLEX\"",
  "targets": [
    { "provider": "opencode-zen", "model": "qwen3.8-max",   "weight": 0.6 },
    { "provider": "opencode-zen", "model": "deepseek-v4-pro","weight": 0.4 }
  ],
  "fallbacks": ["opencode-zen/kimi-k3", "opencode-zen/glm-5.3"],
  "scope": "virtual_key",
  "scope_id": "<Main VK id>",
  "priority": 12
}
```

Three targets in one rule = weighted load balancing inside the tier, no second rule
needed. Weights must sum to 1 or the API returns 400.

**Tier 2 — safety net (priority 90)**

```json
{
  "name": "unclassified-fallback",
  "description": "Classifier declined, timed out, or returned unknown",
  "enabled": true,
  "chain_rule": false,
  "cel_expression": "true",
  "targets": [{ "provider": "opencode-zen", "model": "glm-5.2", "weight": 1 }],
  "fallbacks": ["opencode-zen/deepseek-v4-flash"],
  "scope": "virtual_key",
  "scope_id": "<Main VK id>",
  "priority": 90
}
```

`true` always matches. Without it, an unclassified request keeps the incoming
provider/model — which is the sentinel `auto`, and would 400 at the provider.

**Optional — `chain_rule` for budget degradation (priority 5, after manual, before complexity)**

```json
{
  "name": "budget-degrade",
  "description": "Downgrade to a cheap tier once budget burn is high",
  "enabled": false,
  "chain_rule": true,
  "cel_expression": "budget_used > 80.0",
  "targets": [{ "provider": "opencode-zen", "model": "deepseek-v4.1-flash", "weight": 1 }],
  "fallbacks": [],
  "scope": "virtual_key",
  "scope_id": "<Main VK id>",
  "priority": 5
}
```

`chain_rule: true` re-evaluates the whole scope chain with the resolved
provider/model as the new context. Capacity variables are re-read at every chain
step. Each rule fires at most once per request. Note `budget_used` is `0.0` when no
limit is configured, so this is inert until a budget exists.

Gateway auto-fallbacks only apply when the request body has no `fallbacks` array.
Pi does not send one, so both the rule `fallbacks` and the VK-derived chain are live.

### 1.3 Complexity Analyzer

Dashboard → **Routing → Complexity Analyzer**.

```json
{
  "classifier": "decision",
  "decision": {
    "provider": "opencode-zen",
    "model": "jev-1.13",
    "timeout": "3s",
    "criteria": {
      "MEDIUM": {
        "examples": [
          "Review a Rust function for correctness and flag a logic bug",
          "Pick the right crate for a task and explain the tradeoff",
          "Interpret a parser error and propose the fix"
        ]
      },
      "COMPLEX": {
        "signals": [
          "Several dependent reasoning stages, or a nontrivial derivation using multiple concepts",
          "A novel approach, difficult algorithm, or difficult debugging is required",
          "Combine advanced subject knowledge with conflicting evidence or many interacting constraints",
          "A plausible mistake is hard to detect without deep analysis",
          "A change must stay consistent across several files, modules, or public interfaces"
        ],
        "examples": [
          "Refactor a module and update every caller and its tests",
          "Design a schema migration that keeps readers working during rollout",
          "Find the cause of a heisenbug that only appears under load"
        ]
      }
    }
  },
  "session": { "enabled": true }
}
```

Notes:

- **`decision.provider`/`model` must be a decision-capable model, not a chat model.**
  The shipped default is Typesafe Jev (`typesafe` / `jev-latest`). `opencode-zen/jev-1.13`
  exists on the gateway but currently answers `ModelProtocolUnsupported`
  (see B2). Verify with `GET /api/routing/complexity-analyzer-status` before
  switching off the Typesafe default. Leave `decision` omitted to use Typesafe.
- `session.enabled: true` keeps the highest tier a session reached, for 24 h of
  inactivity. Good for a long coding session: a session that hits COMPLEX stays there.
- Each field overrides independently. A list **replaces** the default; it does not
  append. `SIMPLE` left out keeps shipped guidance, and a field identical to the
  default is stored as "use default" so it picks up upstream improvements.
- Tuning rule from the docs: describe the work, not the topic. "Mentions Kubernetes"
  routes every Kubernetes question to one tier, including "what is a pod?".
- `semantic` is the alternative: 150 shipped reference phrases, embed + nearest
  neighbour, faster than a decision call after warmup. Set
  `semantic.fallback: "llm"` to use the decision model only when no phrase matches.
- `GET /api/routing/complexity-analyzer-status` → `disabled | warming | ready | failed`.
  `warming` after a config change (reference phrases are re-embedded in the background).
- Exact field names above are from the docs; `GET /api/routing/complexity-analyzer-config`
  returns canonical defaults. Diff against it before `PUT`.

### 1.4 Provisioning

UI is the path (B6: no admin creds here). For GitOps later, the same objects seed
from `config.json`:

```json
{
  "governance": {
    "virtual_keys": [ { "id": "<vk-id>", "provider_configs": [ { "provider": "opencode-zen" } ] } ],
    "routing_rules": [ ]
  }
}
```

`config.json` cannot express `user`-scoped rules (API/UI only), and seeded rules are
hash-synced into the DB on startup. Changes need a restart. Use
`source_of_truth: "config.json"` only for sub-sections you intend to own entirely.

---

## 2. Pi mockup

### 2.1 `~/.pi/agent/models.json`

Add three providers pointing at the gateway. Separate provider IDs avoid interfering
with the extension-registered `bifrost` provider.

```json
{
  "providers": {
    "bifrost-auto": {
      "name": "Bifrost auto (complexity)",
      "api": "openai-completions",
      "baseUrl": "https://bifrost.gerbil-matrix.ts.net/v1",
      "apiKey": "!pass show API/BIFROST_VK",
      "authHeader": true,
      "compat": { "supportsDeveloperRole": false },
      "models": [
        {
          "id": "auto",
          "name": "auto",
          "reasoning": false,
          "input": ["text"],
          "contextWindow": 128000,
          "maxTokens": 16384,
          "cost": { "input": 0.5, "output": 1.5, "cacheRead": 0.05, "cacheWrite": 0.6 }
        }
      ]
    },

    "bifrost-fast": {
      "name": "Bifrost fast (manual tier)",
      "api": "openai-completions",
      "baseUrl": "https://bifrost.gerbil-matrix.ts.net/v1",
      "apiKey": "!pass show API/BIFROST_VK",
      "authHeader": true,
      "compat": { "supportsDeveloperRole": false },
      "headers": { "x-bf-tier": "fast" },
      "models": [
        { "id": "auto", "name": "auto (fast)", "reasoning": false, "input": ["text"],
          "contextWindow": 128000, "maxTokens": 16384,
          "cost": { "input": 0.2, "output": 0.6, "cacheRead": 0.02, "cacheWrite": 0.25 } }
      ]
    },

    "bifrost-frontier": {
      "name": "Bifrost frontier (manual tier)",
      "api": "openai-completions",
      "baseUrl": "https://bifrost.gerbil-matrix.ts.net/v1",
      "apiKey": "!pass show API/BIFROST_VK",
      "authHeader": true,
      "compat": { "supportsDeveloperRole": false },
      "headers": { "x-bf-tier": "frontier" },
      "models": [
        { "id": "auto", "name": "auto (frontier)", "reasoning": false, "input": ["text"],
          "contextWindow": 128000, "maxTokens": 16384,
          "cost": { "input": 2.0, "output": 8.0, "cacheRead": 0.2, "cacheWrite": 2.4 } }
      ]
    }
  }
}
```

Rationale for each non-obvious field:

| Field | Why |
| --- | --- |
| `reasoning: false` | Pi then sends no reasoning-effort param, so upstream defaults apply. Avoids the `medium reasoning effort is not supported` failure class. Cost: no per-turn thinking control from Pi. |
| `compat.supportsDeveloperRole: false` | Provider-level `compat` is not inherited by extension models, but is honoured for `models.json` providers. Several upstreams behind this gateway reject the `developer` role. |
| `contextWindow: 128000` | Set to the **minimum** across the tier pools, not the max. Pi derives compaction and context-usage from this. Too high → Pi over-sends and the routed model errors. Check the real minimum first (`GET /api/models`). |
| `maxTokens: 16384` | Same reasoning; clip to the smallest pool member's output cap. |
| `cost` | Pi shows and sums this. It cannot know which physical model answered, so use a blended estimate per pool. Expect the displayed number to be approximate. |
| `input: ["text"]` | Pi sends image placeholders to models without image support, so declaring text-only is safe. Widen only if every pool member is multimodal. |
| `!pass show …` | Resolved at request time, not cached. Same pattern already used for `wfu-gemma`. |

`x-bf-vk` as a header is deliberately **not** set. `authHeader: true` already sends
the key as `Authorization: Bearer`. Bifrost also reads `x-bf-vk` from the key; test
with one and drop it if both are sent, to avoid a duplicate-credential puzzle later.

### 2.2 `~/.pi/agent/settings.json`

```diff
-  "defaultProvider": "bifrost",
-  "defaultModel": "opencode-zen/deepseek-v4.1-flash",
+  "defaultProvider": "bifrost-auto",
+  "defaultModel": "auto",
```

Leave `thinkingLevel` as-is. Since `reasoning: false`, Pi ignores it for this model.

### 2.3 Nix — `shell/default.nix`

```nix
home.sessionVariables = {
  BIFROST_BASE_URL = "https://bifrost.gerbil-matrix.ts.net/v1";
  BIFROST_VK_PASS  = "API/BIFROST_VK";
};
```

Keeps the existing `pi-bifrost` extension working for per-model picks. Do not put the
virtual key literal in the nix store.

### 2.4 What stays

- The `pi-bifrost` extension keeps registering `bifrost` with the full 85-model
  catalog, so `/model` still offers exact models when you want to pin one. Metadata
  patching, probe cache, and the unreachable filter are unaffected.
- `/session` will attribute all auto-routed cost to one model ID. Per-physical-model
  cost lives in the Bifrost logs, not in Pi.
- Do **not** install `iamaamir/pi-bifrost` alongside this. Two routers fighting over
  the active model is the failure mode that extension's docs warn about.

---

## 3. Verification

Run in order. Each step gates the next.

```sh
VK=$(pass show API/BIFROST_VK)

# 1. Does the VK admit the sentinel? Expect not 403.
curl -sS -o /dev/null -w '%{http_code}\n' \
  https://bifrost.gerbil-matrix.ts.net/v1/chat/completions \
  -H "x-bf-vk: $VK" -H 'content-type: application/json' \
  -d '{"model":"auto","messages":[{"role":"user","content":"hi"}],"max_tokens":3}'

# 2. Which models are chat-completions usable right now? Re-run after any provider change.
for m in glm-5.3-flash deepseek-v4.1-flash minimax-m3 qwen3.8-flash qwen3.8-max \
         deepseek-v4-pro glm-5.3 mistral-large-4 kimi-k3; do
  printf '%-24s ' "$m"
  curl -sS -o /tmp/p.json -w '%{http_code} ' \
    https://bifrost.gerbil-matrix.ts.net/v1/chat/completions \
    -H "x-bf-vk: $VK" -H 'content-type: application/json' \
    -d "{\"model\":\"opencode-zen/$m\",\"messages\":[{\"role\":\"user\",\"content\":\"1+1=\"}],\"max_tokens\":4}"
  python3 -c "import json;d=json.load(open('/tmp/p.json'));e=d.get('error') or {};print((e.get('type') or 'OK'), (e.get('message') or '')[:40])"
done

# 3. Header override reaches the rule. Expect the pinned target provider/model.
curl -sS https://bifrost.gerbil-matrix.ts.net/v1/chat/completions \
  -H "x-bf-vk: $VK" -H 'x-bf-tier: frontier' -H 'content-type: application/json' \
  -d '{"model":"auto","messages":[{"role":"user","content":"hi"}],"max_tokens":3}' \
  | python3 -c "import json,sys;print(json.load(sys.stdin)['extra_fields']['routing_info'])"

# 4. Complexity routing fires on content, not header.
curl -sS https://bifrost.gerbil-matrix.ts.net/v1/chat/completions \
  -H "x-bf-vk: $VK" -H 'content-type: application/json' \
  -d '{"model":"auto","messages":[{"role":"user","content":"extract the date from 2026-10-25"}],"max_tokens":3}' \
  | python3 -c "import json,sys;print(json.load(sys.stdin)['extra_fields']['routing_info'])"

curl -sS https://bifrost.gerbil-matrix.ts.net/v1/chat/completions \
  -H "x-bf-vk: $VK" -H 'content-type: application/json' \
  -d '{"model":"auto","messages":[{"role":"user","content":"move auth from middleware into each handler and keep the tests passing"}],"max_tokens":3}' \
  | python3 -c "import json,sys;print(json.load(sys.stdin)['extra_fields']['routing_info'])"
```

Every successful response carries `extra_fields.routing_info` with `provider`,
`model`, `key`, `requested_provider`, `requested_model`, plus `latency` and
`upstream_latency`. That object is the ground truth at runtime and the thing to grep
in the dashboard log view.

Then in Pi:

```
/model                  # confirm bifrost-auto / bifrost-fast / bifrost-frontier appear
pi --list-models bifrost-auto
```

`/v1/models` never lists `auto`, so Pi will not find it on a catalog refresh. It
resolves from `models.json` instead, which is correct, but any tooling that
cross-checks `/v1/models` will flag it as phantom.

---

## 4. Open decisions

| # | Question | Why it matters |
| --- | --- | --- |
| D1 | Does a provider-key alias named `auto` actually resolve, or is the sentinel-only entry enough once the VK allowlist admits it? | Determines whether the requests reach the provider as `auto` (fail) or a real model (works). Test with one rule in place and read `resolved_model_used`. |
| D2 | Which models are genuinely chat-completions-usable, and is `ModelProtocolUnsupported` fixable by adding provider entries per protocol? | Only 17 of 85 respond today. Frontier GPT/Claude tiers are unreachable, which caps the value of COMPLEX routing. |
| D3 | Is `opencode-zen/jev-1.13` decision-capable for the Complexity Analyzer, or does the analyzer stay on the Typesafe default? | Decides whether classification is gateway-local or a hosted call. |
| D4 | Which physical model should own each tier? | The assignments in §1.2 are provisional, chosen from the 17 usable models. |
| D5 | Is a second provider worth adding to the VK? | Unlocks cross-provider weighted LB and VK-derived fallback chains. With one provider, provider routing does nothing. |
| D6 | Should the free-tier and dead-endpoint models be blacklisted at the VK, or left visible for the extension's probe to mark unreachable? | VK blacklist is stronger (rules cannot reach them) but changes what `/v1/models` returns, which changes the Pi catalog. |
| D7 | Is `contextWindow: 128000` correct, or should it track the pool minimum per tier? | Wrong values corrupt Pi's compaction decisions. |
