---
name: skill-index
description: List and describe the Pi skills installed on this machine — where each one lives, how to invoke it, and which arguments it documents. Use when the user asks what skills exist, what a skill is called, how to invoke a skill, what arguments or flags a skill takes, which skills are project vs user vs package scope, or wants a quick reference of available skills instead of reading every SKILL.md.
---

# Skill index

Answers "what skills do I have and how do I call them" without opening 26 SKILL.md files.

## Arguments

Pi appends your trailing text here as a user request; it does not parse it into flags. Interpret it as:

| Input | Meaning |
|---|---|
| nothing | full index, one line per skill (fast) |
| `--long` | add descriptions, arguments, and paths |
| a skill name, e.g. `orbitr` | detailed card for that one skill |
| `--args <name>` | just the invocation signature |
| `--where` | which directories are scanned, and whether each exists |
| `--json` | machine-readable output |
| `--cwd <path>` | index as if run from another directory |

Natural phrasings map onto those: "what skills do I have" → no args; "how do I call orbitr" → `--args orbitr`; "which are project skills" → `--where`, plus the scope column from `--long`.

## Run it

```bash
S="$HOME/.pi/agent/skills/skill-index/scripts/skill-index.py"
python3 "$S"                 # one line per skill
python3 "$S" --long          # descriptions, args, paths
python3 "$S" <skill-name>    # one detailed card
python3 "$S" --args <name>   # signature only
python3 "$S" --where         # scanned directories
```

## Workflow

1. Run the index at the detail level asked for.
2. Read the output back. Do not paraphrase a card into a summary — these are reference material, and the flags matter more than the prose.
3. If the user asked about a skill that is not installed, say it is absent; the script suggests near matches.
4. If they want more depth than a card gives, read that skill's `SKILL.md` at the path the card prints.

## What the report means

**Scopes.** Pi discovers skills from four places, and the report labels which:

| Scope label | Location |
|---|---|
| `user` | `~/.pi/agent/skills` |
| `user (.agents)` | `~/.agents/skills` |
| `project:<name>` | `<repo>/.pi/skills` |
| `project .agents:<name>` | `<repo>/.agents/skills` |
| `package:<name>` | inside an installed Pi package |

Project `.agents/skills` is walked upward from the working directory to the repository root, matching Pi. First discovery of a name wins, as in Pi.

**Manual only.** Skills with `disable-model-invocation: true` never auto-activate; you must type `/skill:<name>`. The report marks these.

**Arguments are evidence, not a schema.** Repeat this caveat whenever the report is presented:

- Pi substitutes `$ARGUMENTS` and `$1` in **prompt templates** only. In a skill, trailing text is appended as an ordinary user request.
- The "Signature" line is reconstructed from whatever the skill itself documents — an `## Arguments` section, a usage fence, a `/skill:` line, or `$ARGUMENTS`.
- `argument_source` in the JSON says how solid that is: `stated` (documented), `inferred` (pulled from an example command), `none` (nothing found).
- A skill marked `none` may still accept trailing text; it just does not document any. Do not tell the user a skill "takes no arguments" when the honest statement is "documents no arguments".

## Maintenance

This skill is global (dotfiles at `~/.dotfiles/.pi/agent/skills/skill-index/`), so it works in every project. The script is self-contained: no imports outside the Python standard library, no dependency on any other skill.

`--where` is the diagnostic: it shows each scanned directory and whether it was found. Re-run it after installing new Pi packages to confirm package-scoped skills are still discovered.

When run outside a git repository, the project scope is only the working directory; inside one, it walks up to the repository root. That matches Pi and keeps `--where` honest about what it looked at.
