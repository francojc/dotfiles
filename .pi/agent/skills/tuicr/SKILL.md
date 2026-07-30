---
name: tuicr
description: Use tuicr persisted review sessions to launch a local Git-diff review in tmux, read user-authored inline comments, and apply requested fixes. Use when user asks to review Pi changes, comments added in tuicr, a commit range, or a local Git diff.
---

# tuicr Review Workflow

Use `tuicr review` as agent interface. TUI belongs to user. CLI reads persisted review session data.

## User-led review

1. Launch review with `scripts/tuicr-tmux.sh /path/to/repo [tuicr arguments...]` when user asks for a review pane.
2. Wrapper returns immediately. Tell user pane ID and tmux switch keys.
3. Discover active session:

```bash
tuicr review list --repo /path/to/repo
```

4. When user says comments are ready, read comments:

```bash
tuicr review comments --repo /path/to/repo --session <slug>
```

5. Treat returned comments as user feedback:
  - `issue` – fix first.
  - `suggestion` – implement or explain why not.
  - `note` – answer or acknowledge.
  - `praise` – no action.
6. Rerun `tuicr review comments` before claiming work complete if review could have continued.

Do not add review comments or impersonate user feedback in user-led review.

## Session selection

- Use exactly one relevant active session when `active` is `true`.
- If multiple plausible sessions exist, ask user for session slug.
- A local slug needs `--repo`; a PR slug such as `gh:owner/repo/pr/N` does not.
- If no session appears, ask user to focus review pane briefly. Tuicr creates persisted session after review target activates.

## Agent-led review

Only add comments after user explicitly asks for agent-authored review comments. Attribute them:

```bash
tuicr review add --repo /path/to/repo --session <slug> --target-file src/file.ts --line 42 --side new --type issue --username "Pi" "Explain problem and requested fix."
```

Use line comments when anchor known. Use file or review comments only when scope requires it.

## Launch arguments

```bash
scripts/tuicr-tmux.sh .                 # tuicr commit selector
scripts/tuicr-tmux.sh . -w              # uncommitted changes
scripts/tuicr-tmux.sh . -r main..HEAD   # commit range
scripts/tuicr-tmux.sh . pr 123          # GitHub PR
```

`tuicr` supports local Git review for any remote, including Codeberg/Forgejo. Remote review submission currently supports GitHub and GitLab only. Do not claim Forgejo PR submission works.

## Errors

- `tuicr` missing – tell user to install it.
- Not in tmux – tell user to start Pi inside tmux or start `tuicr` manually.
- Not a Git repository – ask for repository path.
- Empty comments – confirm user added comments to selected session.
