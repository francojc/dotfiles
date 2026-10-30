#!/usr/bin/env python3
"""Index every Pi skill available to this session and report how each is invoked.

  skill-index.py                      # all skills, one line each
  skill-index.py --long               # description + frontmatter summary
  skill-index.py caa-case-prep        # one skill in detail
  skill-index.py --args caa-case-prep # just the argument signature
  skill-index.py --json
  skill-index.py --where              # only which directories were scanned

Discovery mirrors Pi: user skills, .agents/skills, project skills, and skills
shipped inside installed packages. Project `.agents/skills` is walked upward
from the working directory until the repository root, as Pi does.

Argument extraction is heuristic and says so. Pi substitutes `$ARGUMENTS` in
prompt templates, not in skills, so a skill's arguments are whatever its prose
describes — this script reports the evidence rather than inventing a grammar.
"""

import argparse
import json
import os
import re
import subprocess
import sys
from pathlib import Path

FM_RE = re.compile(r"^---\s*$(.*?)^---\s*$", re.S | re.M)
SECTION_RE = re.compile(r"^(#{1,4})\s+(.*)$", re.M)

# Headings that tend to carry usage or argument information, most specific first.
ARG_SECTIONS = [
    "arguments", "argument", "usage", "invocation", "invoke", "syntax",
    "command reference", "commands", "options", "flags", "parameters",
    "common options reference", "how to invoke",
]
USE_SECTIONS = ["when to use", "when to invoke", "purpose", "overview"]
FLAG_RE = re.compile(r"(?<![\w-])(--[a-z][a-z0-9-]{1,30})(?![\w-])")
SHORT_RE = re.compile(r"(?<![\w-])(-[a-zA-Z])(?![\w-])")
SIG_RE = re.compile(r"/skill:([a-z0-9-]+)([^\n`]*)")
SLASH_CMD_RE = re.compile(r"^\s*`?(/[a-z][a-z0-9:_-]+)([^`\n]*)`?\s*$", re.M)


def frontmatter(text: str) -> tuple[dict, str]:
    """Split YAML-ish frontmatter from the body. Values kept as raw strings."""
    m = FM_RE.search(text)
    if not m:
        return {}, text
    raw = m.group(1)
    data: dict = {}
    key = None
    for line in raw.splitlines():
        if not line.strip() or line.lstrip().startswith("#"):
            continue
        if re.match(r"^[a-z][a-z0-9_-]*:", line, re.I):
            key, _, value = line.partition(":")
            key = key.strip()
            value = value.strip()
            if value.startswith(("[", "{")):
                data[key] = value
            elif value:
                data[key] = value
            else:
                data[key] = []          # block list follows
        elif key and line.strip().startswith("-"):
            if isinstance(data.get(key), list):
                data[key].append(line.strip().lstrip("-").strip())
    return data, text[m.end():]


def sections(body: str) -> list[dict]:
    """Split a skill body into heading sections, ignoring fenced code blocks.

    Skills are full of `# comment` lines inside bash fences; treating those as
    headings truncates every enclosing section (and with it the arguments it
    documents). So fences are tracked and `#` lines inside them are skipped.
    """
    lines = body.splitlines(keepends=True)
    headings: list[tuple[int, int, str]] = []      # (line_index, level, title)
    in_fence = False
    fence_marker = ""
    for index, line in enumerate(lines):
        stripped = line.lstrip()
        fence = re.match(r"^(```+|~~~+)", stripped)
        if fence:
            marker = fence.group(1)
            if not in_fence:
                in_fence, fence_marker = True, marker[:3]
            elif marker[:3] == fence_marker:
                in_fence, fence_marker = False, ""
            continue
        if in_fence:
            continue
        m = re.match(r"^(#{1,6})\s+(.+?)\s*$", line)
        if m:
            headings.append((index, len(m.group(1)), m.group(2).strip()))

    out: list[dict] = []
    for position, (line_index, level, title) in enumerate(headings):
        start = line_index + 1
        end = headings[position + 1][0] if position + 1 < len(headings) else len(lines)
        text = "".join(lines[start:end]).strip()
        out.append({"level": level, "title": title, "text": text})
    return out


def norm_title(title: str) -> str:
    return re.sub(r"[^a-z0-9 ]+", " ", title.lower()).strip()


def pick_sections(secs: list[dict], wanted: list[str]) -> list[dict]:
    """Match sections by normalized title, including their subsections.

    A 'Command Reference' heading usually carries its arguments in `###`
    children, so a parent match subsumes everything beneath it until a heading
    of the same or higher level appears.
    """
    picked: list[dict] = []
    for want in wanted:
        want_norm = norm_title(want)
        for index, sec in enumerate(secs):
            title_norm = norm_title(sec["title"])
            if want_norm not in title_norm:
                continue
            if sec in picked:
                continue
            gathered = [sec]
            for child in secs[index + 1:]:
                if child["level"] > sec["level"]:
                    gathered.append(child)
                else:
                    break
            merged = dict(sec)
            merged["text"] = "\n\n".join(c["text"] for c in gathered if c["text"])
            picked.append(merged)
    return picked


def first_sentences(text: str, count: int = 2, limit: int = 400) -> str:
    clean = re.sub(r"\s+", " ", re.sub(r"`[^`]*`", "", text)).strip()
    clean = re.sub(r"[*_#>|]", "", clean).strip()
    parts = re.split(r"(?<=[.!?])\s+", clean)
    joined = " ".join(parts[:count]).strip()
    return joined[:limit]


def discover_roots(cwd: Path | None = None) -> list[dict]:
    """Directories Pi scans for skills, with a label and a trust-free existence check."""
    home = Path.home()
    roots: list[dict] = []

    def add(path: Path, label: str):
        if path.is_dir():
            roots.append({"path": path, "label": label, "exists": True})
        else:
            roots.append({"path": path, "label": label, "exists": False})

    add(home / ".pi" / "agent" / "skills", "user")
    add(home / ".agents" / "skills", "user (.agents)")

    # project: walk up from cwd, stopping at the repository root when there is
    # one, else at $HOME. Walking to '/' adds noise without finding anything:
    # Pi's own project scope is bounded the same way.
    current = (cwd or Path.cwd()).resolve()
    home_dir = home.resolve()
    stop = None
    for parent in [current, *current.parents]:
        if (parent / ".git").exists():
            stop = parent
            break
    if stop is None:
        # No repository: the project scope is just the working directory.
        walk = [current]
    else:
        walk = []
        for parent in [current, *current.parents]:
            walk.append(parent)
            if parent == stop:
                break
    for parent in walk:
        add(parent / ".pi" / "skills", f"project:{parent.name or parent}")
        add(parent / ".agents" / "skills", f"project .agents:{parent.name or parent}")

    # package skills
    npm_modules = home / ".pi" / "agent" / "npm" / "node_modules"
    if npm_modules.is_dir():
        for skill_md in npm_modules.rglob("SKILL.md"):
            if "/skills/" in str(skill_md):
                add(skill_md.parent.parent.parent if False else skill_md.parent,
                    f"package:{skill_md.parent.parent.relative_to(npm_modules)}")
    return roots


def collect_skills(cwd: Path | None = None) -> tuple[list[dict], list[dict]]:
    """Return (skills, roots). Directories containing SKILL.md, discovered recursively."""
    roots = discover_roots(cwd)
    seen: dict[str, dict] = {}
    skills: list[dict] = []

    for root in roots:
        if not root["exists"]:
            continue
        base = root["path"]
        # a skill is a directory holding SKILL.md, or a standalone .md
        candidates = list(base.rglob("SKILL.md"))
        if root["label"].startswith("package:"):
            candidates = [p for p in candidates if p.parent == base]
        for skill_md in sorted(candidates):
            text = skill_md.read_text(encoding="utf-8", errors="replace")
            fm, body = frontmatter(text)
            name = (fm.get("name") or skill_md.parent.name).strip()
            if name in seen:
                continue                      # Pi keeps the first discovered
            record = {
                "name": name,
                "path": str(skill_md),
                "dir": str(skill_md.parent),
                "scope": root["label"],
                "description": (fm.get("description") or "").strip(),
                "disable_model_invocation": str(
                    fm.get("disable-model-invocation", "")
                ).lower() in ("true", "yes"),
                "allowed_tools": fm.get("allowed-tools"),
                "body": body,
            }
            seen[name] = record
            skills.append(record)

        for standalone in sorted(base.glob("*.md")):
            if standalone.name == "SKILL.md":
                continue
            text = standalone.read_text(encoding="utf-8", errors="replace")
            fm, body = frontmatter(text)
            name = standalone.stem
            if name in seen:
                continue
            record = {
                "name": name,
                "path": str(standalone),
                "dir": str(standalone.parent),
                "scope": root["label"],
                "description": (fm.get("description") or "").strip(),
                "disable_model_invocation": str(
                    fm.get("disable-model-invocation", "")
                ).lower() in ("true", "yes"),
                "allowed_tools": fm.get("allowed-tools"),
                "body": body,
            }
            seen[name] = record
            skills.append(record)

    skills.sort(key=lambda r: r["name"])
    return skills, roots


def invocation(skill: dict) -> dict:
    """Best-effort report of how to invoke the skill and what it accepts.

    Evidence, not invention: this reads the skill's own prose. `confidence` says
    how much of the signature was actually stated by the skill.
    """
    body = skill["body"]
    secs = sections(body)
    out = {
        "skill_command": f"/skill:{skill['name']}",
        "signature": None,
        "flags": [],
        "positional": [],
        "argument_source": None,          # 'stated' | 'inferred' | 'none'
        "usage_block": None,
        "when_to_use": None,
    }

    # 1. an explicit '/skill:name args' signature anywhere
    for m in SIG_RE.finditer(body):
        if m.group(1) == skill["name"]:
            rest = m.group(2).strip().strip("`").strip()
            if rest:
                out["signature"] = f"/skill:{skill['name']} {rest}"
                out["argument_source"] = "stated"
                break

    # 2. an Arguments / Usage / Commands section. Flags only count when they
    #    appear in such a section; prose elsewhere may mention flags incidentally.
    arg_secs = pick_sections(secs, ARG_SECTIONS)
    if arg_secs:
        block = arg_secs[0]["text"]
        flags = sorted(set(FLAG_RE.findall(block)))
        if flags or "argument" in norm_title(arg_secs[0]["title"]):
            out["usage_block"] = block[:1200]
            out["argument_source"] = out["argument_source"] or "stated"
        if flags:
            out["flags"] = flags
            if out["signature"] is None:
                short = sorted({f for f in SHORT_RE.findall(block)})
                parts = [f"[{s}]" for s in short] + [f"[{f}]" for f in flags]
                out["signature"] = " ".join([f"/skill:{skill['name']}", *parts])

    # 3. a fenced usage line like 'orbitr search "query" --from 2020'
    if out["usage_block"] is None:
        for fence in re.findall(r"```[a-z]*\n(.*?)```", body, re.S):
            first = next((ln for ln in fence.splitlines() if ln.strip()), "")
            if first and first.strip().startswith(("orbitr", "tuicr", "hunk", "workmux", "ketch", "tirith")):
                out["usage_block"] = first.strip()
                out["argument_source"] = "inferred"
                if "--" in first:
                    out["flags"] = sorted(set(FLAG_RE.findall(fence)))
                break

    # 4. $ARGUMENTS-style usage, including the inline '**Arguments:** `$ARGUMENTS`'
    if "$ARGUMENTS" in body or re.search(r"\$1\b", body):
        out["argument_source"] = out["argument_source"] or "stated"
        out["accepts_freeform"] = True
        inline = re.search(r"^.*\bArguments:?\*{0,2}\s*`?\$ARGUMENTS`?.*$", body, re.M)
        if inline and not out["usage_block"]:
            out["usage_block"] = inline.group(0).strip()

    if shot := pick_sections(secs, USE_SECTIONS):
        out["when_to_use"] = first_sentences(shot[0]["text"], 2)

    # description fallback for "when to use"
    if not out["when_to_use"] and skill["description"]:
        out["when_to_use"] = skill["description"][:300]

    # Only call it undocumented when nothing at all was found. A skill that
    # documents its arguments in prose (or via $ARGUMENTS) has documented them,
    # even if no --flag-shaped token appears.
    has_evidence = bool(
        out["signature"]
        or out["flags"]
        or out["usage_block"]
        or out.get("accepts_freeform")
        or out["argument_source"] == "stated"
    )
    if not has_evidence:
        out["argument_source"] = "none"
    return out


def render_list(skills: list[dict], long: bool) -> str:
    lines = []
    width = max((len(s["name"]) for s in skills), default=10)
    lines.append(f"{len(skills)} skills\n")
    for skill in skills:
        inv = invocation(skill)
        hidden = " (manual only)" if skill["disable_model_invocation"] else ""
        lines.append(f"{skill['name']:<{width}}  {inv['skill_command']}{hidden}")
        if long:
            desc = skill["description"] or "(no description)"
            lines.append(f"{'':<{width}}  {first_sentences(desc, 3, 300)}")
            if inv["signature"]:
                lines.append(f"{'':<{width}}  args: {inv['signature']}")
            elif inv["flags"]:
                lines.append(f"{'':<{width}}  flags: {' '.join(inv['flags'][:8])}")
            lines.append(f"{'':<{width}}  [{skill['scope']}] {skill['path']}")
            lines.append("")
    return "\n".join(lines)


def render_detail(skill: dict) -> str:
    inv = invocation(skill)
    out = [f"# {skill['name']}", ""]
    out.append(f"**Invoke** `{inv['skill_command']}`"
               + ("  ·  manual only (`disable-model-invocation: true`)" if skill["disable_model_invocation"] else ""))
    out.append(f"**Scope** {skill['scope']}")
    out.append(f"**Path** `{skill['path']}`")
    if skill["allowed_tools"]:
        tools = skill["allowed_tools"]
        out.append(f"**Allowed tools** {tools if isinstance(tools, str) else ', '.join(tools)}")
    out.append("")

    out.append("## What it does")
    out.append(skill["description"] or "_No description declared._")
    out.append("")

    if inv["when_to_use"]:
        out.append("## When to use it")
        out.append(inv["when_to_use"])
        out.append("")

    out.append("## Arguments")
    if inv["argument_source"] == "none":
        out.append("_No arguments identified. It runs on the trailing text if you supply any, "
                   "otherwise on your current context._")
    else:
        if inv["signature"]:
            out.append(f"Signature (from the skill): `{inv['signature']}`")
        if inv["flags"]:
            out.append("Flags mentioned: " + " ".join(f"`{f}`" for f in inv["flags"]))
        if inv.get("accepts_freeform"):
            out.append("Takes freeform text via `$ARGUMENTS`.")
    out.append("")

    if inv["usage_block"]:
        out.append("## Usage as documented")
        out.append("```")
        out.append(inv["usage_block"].strip())
        out.append("```")
        out.append("")

    out.append("## Caveat")
    out.append(
        "Extracted from the skill's own prose. Pi does not parse skill arguments, so "
        "anything above is a convention this skill documents, not a schema the runtime "
        "enforces."
        if inv["argument_source"] != "none"
        else "Pi does not parse skill arguments; whatever you append simply arrives as "
        "a user request."
    )
    return "\n".join(out)


def main() -> int:
    ap = argparse.ArgumentParser(
        description="Index Pi skills and report how each is invoked.",
    )
    ap.add_argument("skill", nargs="?", help="one skill name to describe in detail")
    ap.add_argument("--long", action="store_true", help="include descriptions and args")
    ap.add_argument("--json", action="store_true")
    ap.add_argument("--args", metavar="SKILL", help="print only the argument signature")
    ap.add_argument("--where", action="store_true", help="show scanned directories only")
    ap.add_argument("--cwd", type=Path, help="treat this as the working directory")
    args = ap.parse_args()

    skills, roots = collect_skills(args.cwd)

    if args.where:
        for root in roots:
            mark = "found" if root["exists"] else "absent"
            print(f"[{mark}] {root['label']:<44} {root['path']}")
        print(f"\n{len(skills)} skills discovered")
        return 0

    if args.args:
        match = next((s for s in skills if s["name"] == args.args), None)
        if not match:
            print(f"error: no skill named {args.args!r}", file=sys.stderr)
            return 1
        inv = invocation(match)
        if args.json:
            print(json.dumps(inv, indent=2))
        else:
            print(inv["signature"] or f"/skill:{match['name']}  (no documented arguments)")
        return 0

    if args.json:
        payload = [
            {
                "name": s["name"],
                "scope": s["scope"],
                "path": s["path"],
                "description": s["description"],
                "manual_only": s["disable_model_invocation"],
                **{k: v for k, v in invocation(s).items() if k != "usage_block"},
            }
            for s in skills
        ]
        print(json.dumps(payload, indent=2, ensure_ascii=False))
        return 0

    if args.skill:
        match = next((s for s in skills if s["name"] == args.skill), None)
        if not match:
            near = [s["name"] for s in skills if args.skill.lower() in s["name"].lower()]
            hint = f" did you mean: {', '.join(near)}" if near else ""
            print(f"error: no skill named {args.skill!r}.{hint}", file=sys.stderr)
            return 1
        print(render_detail(match))
        return 0

    print(render_list(skills, args.long))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
