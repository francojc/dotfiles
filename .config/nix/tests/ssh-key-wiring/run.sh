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
  "nixos-quattro": "quattro",
  "future-host": None,
}
legacy = {
  "forgejo": "~/.ssh/id_ed25519_forgejo",
  "codeberg": "~/.ssh/id_ed25519_codeberg",
  "workstations": "~/.ssh/id_ed25519_workstation",
}
# Exact existing blocks: key selection, destination, user, port and host trust.
expected = {
  "forgejo forgejo.gerbil-matrix.ts.net": {
    "HostName": "forgejo.gerbil-matrix.ts.net", "HostKeyAlias": "forgejo",
    "User": "forgejo", "IdentityFile": legacy["forgejo"], "IdentitiesOnly": "yes",
  },
  "codeberg.org": {
    "User": "git", "IdentityFile": legacy["codeberg"], "IdentitiesOnly": "yes",
  },
  "rover": {"HostName": "mini-rover.gerbil-matrix.ts.net", "HostKeyAlias": "mini-rover", "User": "jeridf", "Port": "22"},
  "minicore": {"HostName": "mac-minicore.gerbil-matrix.ts.net", "HostKeyAlias": "mac-minicore", "User": "jeridf", "Port": "22", "IdentityFile": legacy["workstations"], "IdentitiesOnly": "yes"},
  "airborne": {"HostName": "macbook-airborne.gerbil-matrix.ts.net", "HostKeyAlias": "macbook-airborne", "User": "francojc", "Port": "22", "IdentityFile": legacy["workstations"], "IdentitiesOnly": "yes"},
}
for alias, name, user in [
  ("monitors", "monitor-services", "jeridf"), ("services", "core-services", "root"),
  ("media", "media-services", "root"), ("homeassistant", "homeassistant", "jeridf"),
  ("hermes", "hermes-agent", "hermes"), ("omarchy", "omarchy", "omarchy"),
  ("proxmox", "minis-proxmox", "root"),
]:
  expected[alias] = {"HostName": f"{name}.gerbil-matrix.ts.net", "HostKeyAlias": name, "User": user, "Port": "22"}

for host, nickname in nicknames.items():
  result = results[host]
  paths = result["paths"]
  assert paths["nickname"] == nickname, host
  assert paths["provisioning"] == ("inventoried" if nickname == "airborne" else "unsupported" if nickname is None else "unprovisioned"), host
  assert result["environment"] == ({"SSH_KEY_AUDIT_DEVICE": nickname} if nickname else {}), host
  assert result["registryExists"] and result["registrySourceCorrect"], host
  assert result["registryForce"] is False, host
  assert len(result["warnings"]) == 1 and "retaining legacy paths" in result["warnings"][0], host
  for purpose, current in legacy.items():
    service = paths["services"][purpose]
    ready = nickname == "airborne" and purpose == "forgejo"
    intended = f"~/.ssh/id_ed25519_{nickname}_{purpose}" if nickname else None
    assert service["current"] == current, (host, purpose)
    assert service["ready"] is ready, (host, purpose)
    assert service["intended"] == intended, (host, purpose)
    assert service["selected"] == (intended if ready else current), (host, purpose)
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
  host_expected = {alias: dict(options) for alias, options in expected.items()}
  if nickname == "airborne":
    host_expected["forgejo forgejo.gerbil-matrix.ts.net"]["IdentityFile"] = "~/.ssh/id_ed25519_airborne_forgejo"
    assert "codeberg, workstations;" in result["warnings"][0], host
  else:
    assert "codeberg, forgejo, workstations;" in result["warnings"][0], host
  assert blocks == host_expected, host
  print(f"PASS {host}: mapping, readiness, registry and scoped SSH blocks")
print("All 5 SSH wiring groups passed; evaluation only, no activation or SSH operations.")
PY
