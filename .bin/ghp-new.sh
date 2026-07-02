# Add this function to your ~/.zshrc or ~/.bashrc, then use:
#   ghc-protected my-new-repo --public --source=. --push
# instead of `gh repo create ...` — same arguments, same behavior,
# but it locks main immediately after creation.
#
# Only meaningful for repos under your personal account (francojc).
# For ai-praxis / wfu-agentic-ai repos, the org ruleset already covers you —
# just use plain `gh repo create` there.

ghc-protected() {
  local repo_name="$1"
  shift

  gh repo create "$repo_name" "$@"

  # gh repo create with no owner prefix defaults to your authenticated user.
  local full_name
  full_name=$(gh repo view "$repo_name" --json nameWithOwner --jq '.nameWithOwner')
  local owner="${full_name%%/*}"
  local name="${full_name##*/}"

  if [[ "$owner" != "francojc" ]]; then
    echo "Note: ${full_name} is not under francojc — skipping personal ruleset (org policy should already apply)."
    return 0
  fi

  local user_id
  user_id=$(gh api "/users/${owner}" --jq '.id')

  gh api \
    --method POST \
    -H "Accept: application/vnd.github+json" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    "/repos/${owner}/${name}/rulesets" \
    -f name="protect-main" \
    -f target="branch" \
    -f enforcement="active" \
    -f 'conditions[ref_name][include][]=~DEFAULT_BRANCH' \
    -f 'bypass_actors[][actor_id]='"$user_id" \
    -f 'bypass_actors[][actor_type]=User' \
    -f 'bypass_actors[][bypass_mode]=always' \
    -f 'rules[][type]=pull_request' \
    -F 'rules[0][parameters][required_approving_review_count]=0' \
    -f 'rules[][type]=non_fast_forward' \
    -f 'rules[][type]=deletion' \
    > /dev/null

  echo "main branch protected on ${full_name} (francojc bypasses)."
}
