#!/usr/bin/env bash
set -euo pipefail
here=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
result=$(mktemp)
trap 'rm -f "$result"' EXIT
nix eval --offline --json --file "$here/eval.nix" > "$result"
python3 - "$result" <<'PY'
import json
import sys

with open(sys.argv[1]) as stream:
  results = json.load(stream)
nicknames = {
  "Macbook-Airborne": "airborne",
  "Mac-Minicore": "minicore",
  "Mini-Rover": "rover",
  "omarchy": "omarchy",
  "nixos-quattro": None,
  "future-host": None,
}
for host, nickname in nicknames.items():
  result = results[host]
  services = {
    purpose: f"~/.ssh/id_ed25519_{nickname}_{purpose}"
    for purpose in ("forgejo", "codeberg", "github")
  } if nickname else {}
  assert result["paths"] == {"nickname": nickname, "services": services}, host
  assert result["environment"] == ({"SSH_KEY_AUDIT_DEVICE": nickname} if nickname else {}), host
  assert result["registryExists"] and result["registrySourceCorrect"], host
  assert result["registryForce"] is False, host
  assert result["registryEnabled"] is (nickname != "airborne"), host
  assert result["warnings"] == [], host

  blocks = {}
  block = None
  for line in result["config"].splitlines():
    line = line.strip()
    if not line or line.startswith("#"):
      continue
    key, value = line.split(None, 1)
    if key == "Host":
      assert value not in blocks, (host, value)
      block = blocks[value] = {}
    else:
      assert block is not None and key not in block, (host, key)
      block[key] = value
  expected = {
    "forgejo forgejo.gerbil-matrix.ts.net": {
      "HostName": "forgejo.gerbil-matrix.ts.net",
      "HostKeyAlias": "forgejo",
      "User": "forgejo",
      "IdentityFile": services["forgejo"],
      "IdentitiesOnly": "yes",
    },
    "codeberg.org": {
      "User": "git", "IdentityFile": services["codeberg"], "IdentitiesOnly": "yes",
    },
    "github.com": {
      "User": "git", "IdentityFile": services["github"], "IdentitiesOnly": "yes",
    },
  } if nickname else {}
  assert blocks == expected, host
  print(f"PASS {host}: device/service paths, registry and exact SSH blocks")
print("All 6 SSH wiring groups passed; evaluation only, no activation or SSH operations.")
PY
