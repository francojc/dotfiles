#!/usr/bin/env bash
# Applies a branch-protection ruleset (main branch, PR required, francojc bypasses)
# to every repo under the given owner (defaults to the personal account francojc;
# pass an org name like wfu-agentic-ai as $1 to target that org instead).
#
# Usage:
#   ghp-existing.sh                  # defaults to francojc
#   ghp-existing wfu-agentic-ai      # targets the org instead
#
# Requires: gh CLI authenticated with 'repo' scope on personal repos, or
# 'admin:org' scope when targeting an organization (an admin-scoped classic
# PAT or `gh auth login` session — NOT the Hermes Agent token).

set -euo pipefail

OWNER="${1:-francojc}"
BYPASS_USER="francojc"   # you, regardless of which owner's repos are being protected
RULESET_NAME="protect-main"

# Always look up francojc's ID for the bypass actor — /users/ resolves correctly
# whether OWNER is francojc (personal) or an org like wfu-agentic-ai, since we
# want *you* to bypass either way, not the org itself.
USER_ID=$(gh api "/users/${BYPASS_USER}" --jq '.id')

REPOS=$(gh repo list "$OWNER" --limit 1000 --json name,isFork --jq '.[] | select(.isFork == false) | .name')

for REPO in $REPOS; do
  echo "Processing ${OWNER}/${REPO}..."

  EXISTING=$(gh api "/repos/${OWNER}/${REPO}/rulesets" --jq \
    ".[] | select(.name==\"${RULESET_NAME}\") | .id" 2>/dev/null || true)

  if [[ -n "$EXISTING" ]]; then
    echo "  -> Ruleset already present (id ${EXISTING}), skipping."
    continue
  fi

  PAYLOAD=$(cat <<JSON
{
  "name": "${RULESET_NAME}",
  "target": "branch",
  "enforcement": "active",
  "conditions": {
    "ref_name": {
      "include": ["~DEFAULT_BRANCH"],
      "exclude": []
    }
  },
  "bypass_actors": [
    {
      "actor_id": ${USER_ID},
      "actor_type": "User",
      "bypass_mode": "always"
    }
  ],
  "rules": [
    {
      "type": "pull_request",
      "parameters": {
        "required_approving_review_count": 0,
        "dismiss_stale_reviews_on_push": false,
        "require_code_owner_review": false,
        "require_last_push_approval": false,
        "required_review_thread_resolution": false
      }
    },
    { "type": "non_fast_forward" },
    { "type": "deletion" }
  ]
}
JSON
)

  if echo "$PAYLOAD" | gh api \
    --method POST \
    -H "Accept: application/vnd.github+json" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    "/repos/${OWNER}/${REPO}/rulesets" \
    --input - > /dev/null 2>/tmp/gh_err.log; then
    echo "  -> Ruleset applied."
  else
    echo "  -> FAILED: $(cat /tmp/gh_err.log)"
  fi

  sleep 1
done

echo "Done."
