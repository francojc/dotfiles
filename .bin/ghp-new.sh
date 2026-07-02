# Add this function to your ~/.zshrc or ~/.bashrc, then use:
#   ghp-new.sh my-new-repo --public/private --source=. --push          # personal (francojc)
#   ghp-new.sh wfu-agentic-ai/my-new-repo --public/private --source=. --push  # org repo
# instead of `gh repo create ...` — same arguments, same behavior,
# but it locks main immediately after creation.
#
# Applies to repos under francojc (personal) OR any org where `gh repo create`
# is given an "owner/repo" name, e.g. wfu-agentic-ai/my-new-repo.
# For ai-praxis, the org-wide ruleset already covers you — plain `gh repo create`
# is fine there, this wrapper is redundant but harmless.

ghc-protected() {
  local repo_arg="$1"
  shift

  gh repo create "$repo_arg" "$@"

  local full_name
  full_name=$(gh repo view "$repo_arg" --json nameWithOwner --jq '.nameWithOwner')
  local owner="${full_name%%/*}"
  local name="${full_name##*/}"

  # You (francojc) always bypass, regardless of whether owner is you or an org.
  local user_id
  user_id=$(gh api "/users/francojc" --jq '.id')

  local payload
  payload=$(cat <<JSON
{
  "name": "protect-main",
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
      "actor_id": ${user_id},
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

  if echo "$payload" | gh api \
    --method POST \
    -H "Accept: application/vnd.github+json" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    "/repos/${owner}/${name}/rulesets" \
    --input - > /dev/null 2>/tmp/gh_err.log; then
    echo "main branch protected on ${full_name} (francojc bypasses)."
  else
    echo "Ruleset creation FAILED on ${full_name}: $(cat /tmp/gh_err.log)"
  fi
}
