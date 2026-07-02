#!/usr/bin/env bash
# Applies a branch-protection ruleset (main branch, PR required, francojc bypasses)
# to every repo currently owned by the personal account francojc.
#
# Requires: gh CLI authenticated as francojc with 'repo' and 'admin:org' scope
# (an admin-scoped classic PAT or `gh auth login` session — NOT the Hermes Agent token).

set -euo pipefail

OWNER="francojc"
RULESET_NAME="protect-main"

# Get francojc's user ID once, for the bypass actor entry.
USER_ID=$(gh api "/users/${OWNER}" --jq '.id')

# Pull every repo (public + private) owned by francojc.
REPOS=$(gh repo list "$OWNER" --limit 1000 --json name,isFork --jq '.[] | select(.isFork == false) | .name')

for REPO in $REPOS; do
  echo "Processing ${OWNER}/${REPO}..."

  # Skip if a ruleset with this name already exists (idempotency).
  EXISTING=$(gh api "/repos/${OWNER}/${REPO}/rulesets" --jq \
    ".[] | select(.name==\"${RULESET_NAME}\") | .id" 2>/dev/null || true)

  if [[ -n "$EXISTING" ]]; then
    echo "  -> Ruleset already present (id ${EXISTING}), skipping."
    continue
  fi

  gh api \
    --method POST \
    -H "Accept: application/vnd.github+json" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    "/repos/${OWNER}/${REPO}/rulesets" \
    -f name="${RULESET_NAME}" \
    -f target="branch" \
    -f enforcement="active" \
    -f 'conditions[ref_name][include][]=~DEFAULT_BRANCH' \
    -f 'bypass_actors[][actor_id]='"$USER_ID" \
    -f 'bypass_actors[][actor_type]=User' \
    -f 'bypass_actors[][bypass_mode]=always' \
    -f 'rules[][type]=pull_request' \
    -F 'rules[0][parameters][required_approving_review_count]=0' \
    -f 'rules[][type]=non_fast_forward' \
    -f 'rules[][type]=deletion' \
    > /dev/null && echo "  -> Ruleset applied." || echo "  -> FAILED (check repo permissions/plan tier)."

  sleep 1  # be polite to the API rate limit
done

echo "Done."
