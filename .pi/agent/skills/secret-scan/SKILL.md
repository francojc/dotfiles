---
name: secret-scan
description: Scan files or directories for high-entropy strings, tokens, and secrets using regex patterns. Detects API keys, JWTs, base64 blobs, hex tokens, and common provider-specific secrets.
---

# Secret Scan

Detect leaked secrets, tokens, and high-entropy strings in code and config files.

## Patterns

### Generic high-entropy

| Type | Pattern |
|------|---------|
| Generic API key assignment | `(?i)(api[_-]?key|secret|token|password|passwd|pwd)\s*[:=]\s*['"]?[A-Za-z0-9+/\-_]{20,}['"]?` |
| Base64 blob (≥32 chars) | `[A-Za-z0-9+/]{32,}={0,2}` |
| Hex token (≥32 chars) | `[A-Fa-f0-9]{32,64}` |
| Bearer token | `Bearer\s+[A-Za-z0-9\-_\.]{20,}` |

### Provider-specific

| Provider | Pattern |
|----------|---------|
| GitHub PAT (classic) | `ghp_[A-Za-z0-9]{36}` |
| GitHub OAuth | `gho_[A-Za-z0-9]{36}` |
| GitHub Actions | `ghs_[A-Za-z0-9]{36}` |
| GitHub refresh | `ghr_[A-Za-z0-9]{76}` |
| Slack bot token | `xoxb-[0-9]{11}-[0-9]{11}-[A-Za-z0-9]{24}` |
| Slack user token | `xoxp-[0-9A-Za-z\-]{72,}` |
| AWS access key ID | `AKIA[0-9A-Z]{16}` |
| AWS secret key | `(?i)aws.{0,20}['"][0-9a-zA-Z/+]{40}['"]` |
| Stripe secret key | `sk_live_[0-9a-zA-Z]{24,}` |
| Stripe publishable | `pk_live_[0-9a-zA-Z]{24,}` |
| OpenAI API key | `sk-[A-Za-z0-9]{48}` |
| JWT | `eyJ[A-Za-z0-9\-_]+\.eyJ[A-Za-z0-9\-_]+\.[A-Za-z0-9\-_]+` |
| Private key header | `-----BEGIN (RSA\|EC\|OPENSSH\|PGP) PRIVATE KEY` |
| Google OAuth | `ya29\.[A-Za-z0-9\-_]+` |
| Twilio SID | `AC[a-z0-9]{32}` |
| Twilio auth token | `(?i)twilio.{0,20}[0-9a-f]{32}` |
| NPM token | `npm_[A-Za-z0-9]{36}` |
| Heroku API key | `[hH]eroku.{0,20}[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12}` |
| Sendgrid key | `SG\.[A-Za-z0-9\-_]{22}\.[A-Za-z0-9\-_]{43}` |

## Usage

### Ripgrep (CLI)

Scan repo for common patterns:

```bash
# Quick combined scan
rg -n --no-heading \
  -e 'ghp_[A-Za-z0-9]{36}' \
  -e 'gho_[A-Za-z0-9]{36}' \
  -e 'AKIA[0-9A-Z]{16}' \
  -e 'sk-[A-Za-z0-9]{48}' \
  -e 'eyJ[A-Za-z0-9\-_]+\.eyJ[A-Za-z0-9\-_]+\.[A-Za-z0-9\-_]+' \
  -e 'sk_live_[0-9a-zA-Z]{24,}' \
  -e 'xoxb-[0-9]{11}-[0-9]{11}-[A-Za-z0-9]{24}' \
  -e '-----BEGIN (RSA|EC|OPENSSH|PGP) PRIVATE KEY' \
  -e '(?i)(api[_-]?key|secret|token|password)\s*[:=]\s*["\047][A-Za-z0-9+/\-_]{20,}["\047]' \
  --glob '!node_modules' --glob '!.git' \
  .
```

### In-session scan

When asked to scan a file or directory for secrets:

1. Use `bash` with `rg` patterns above
2. Report each hit: file, line number, pattern type, redacted match (show first 6 + `…`)
3. Flag `.env`, config files, and committed credential files explicitly
4. Suggest remediation: rotate secret, add to `.gitignore`, use env var or secret manager

## Notes

- Pure regex can't compute Shannon entropy – these patterns catch known formats + assignment context
- False positives expected on hashes, UUIDs, test fixtures – use judgment
- For deeper entropy analysis, pipe to `trufflehog` or `gitleaks` (if available)
- Never log or store full secret values during scan
