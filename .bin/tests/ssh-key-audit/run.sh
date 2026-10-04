#!/usr/bin/env bash
# Disposable fixtures only. Invoke with Bash 3.2 or newer.
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/../.." && pwd -P)
AUDIT=$ROOT/ssh-key-audit
BASH_UNDER_TEST=${BASH_UNDER_TEST:-$(command -v bash)}
TMP=$(mktemp -d "${TMPDIR:-/tmp}/ssh-key-audit-test.XXXXXXXX")
trap 'rm -rf "$TMP"' EXIT
export HOME=$TMP/home SSH_DIR=$TMP/home/.ssh XDG_CONFIG_HOME=$TMP/config
unset SSH_KEYS_REGISTRY SSH_KEY_AUDIT_DEVICE || true
mkdir -p "$SSH_DIR" "$TMP/config" "$TMP/bin"
chmod 700 "$HOME" "$SSH_DIR"
TESTS=0
ok() { TESTS=$((TESTS+1)); printf 'ok %s – %s\n' "$TESTS" "$1"; }
assert() { "$@" >/dev/null || { printf 'FAIL assertion\n' >&2; exit 1; }; }
run() {
  local expected=$1
  shift
  set +e
  "$BASH_UNDER_TEST" "$AUDIT" "$@" > "$TMP/out" 2> "$TMP/err"
  result=$?
  set -e
  [[ "$result" == "$expected" ]] || { printf 'FAIL exit %s expected %s\n' "$result" "$expected" >&2; read_output; exit 1; }
}
read_output() { while IFS= read -r line; do printf '%s\n' "$line" >&2; done < "$TMP/err"; }
has() { jq -e --arg c "$1" 'any(.findings[];.code==$c)' "$TMP/out" >/dev/null; }
absent() { jq -e --arg c "$1" 'all(.findings[];.code!=$c)' "$TMP/out" >/dev/null; }
# Network, agent, and UI tools must never execute.
for cmd in ssh ssh-add ssh-agent open pbcopy; do
  printf '#!/bin/sh\nprintf "forbidden tool\\n" >> "%s"\nexit 99\n' "$TMP/forbidden" > "$TMP/bin/$cmd"
  chmod +x "$TMP/bin/$cmd"
done
export PATH="$TMP/bin:$PATH"
run 0 --help
run 0 --version
run 2 --json --registry ''
assert jq -e '.completed==false' "$TMP/out"
run 2 --json --check-remote test
ok 'help, version, argument errors, deferred remote mode'

ssh-keygen -q -t ed25519 -N '' -f "$SSH_DIR/key one"
ssh-keygen -q -t ed25519 -N 'fixture-passphrase' -f "$SSH_DIR/encrypted"
mkdir "$SSH_DIR/nested"
chmod 700 "$SSH_DIR/nested"
ssh-keygen -q -t rsa -b 2048 -N '' -f "$SSH_DIR/nested/rsa"
run 0 --init --device test
cp "$TMP/out" "$TMP/base.yaml"
yq -o=json '.' "$TMP/base.yaml" > "$TMP/base.json"
assert jq -e '(.keys|length)==3 and all(.keys[];.created==null and .authorized==[])' "$TMP/base.json"
# Explicit metadata remains unknown; fixture init is never redirected into live registry.
REG=$TMP/registry.yaml
cp "$TMP/base.yaml" "$REG"
run 0 --json --registry "$REG" --device test
assert has empty_passphrase
assert has private_uncheckable
assert absent pair_mismatch
assert absent missing_expected_private
assert jq -e '.inventory | any(.[];.path=="key one" and .private and .pair_match=="matched")' "$TMP/out"
run 1 --json --strict --registry "$REG" --device test
ok 'init, spaces, nested paths, RSA/Ed25519, encrypted/empty passphrases, strict exit'

# Errors remain JSON even when --json comes last.
run 2 --bogus --json
assert jq -e '.completed==false' "$TMP/out"
run 2 --json --registry "$TMP/missing"
run 2 --json --registry "$REG" --device unknown
run 0 --json --registry "$REG" # init alias matches fixture hostname
assert jq -e '.device=="test"' "$TMP/out"
cp "$REG" "$TMP/alias.yaml"
yq -i '.devices.test.hostnames=[]' "$TMP/alias.yaml"
run 0 --json --registry "$TMP/alias.yaml"
assert has unknown_device
assert absent missing_expected_private
SSH_KEYS_REGISTRY=$TMP/missing SSH_DIR=$TMP/missing SSH_KEY_AUDIT_DEVICE=unknown run 0 --json --registry "$REG" --ssh-dir "$HOME/.ssh" --device test
ok 'precedence, JSON failures, explicit unknown and hostname mapping'

# Schema mutations: every case must fail before inventory inspection.
mutate() {
  jq "$1" "$TMP/base.json" > "$TMP/bad.json"
  run 2 --json --registry "$TMP/bad.json" --device test
  assert jq -e '.completed==false' "$TMP/out" >/dev/null
}
mutate '.extra=true'
mutate '.version=2'
mutate '.keys[0].fingerprint="bad"'
mutate '.keys += [.keys[0]]'
mutate '.keys[0].created="2025-02-29"'
mutate '.keys[0].review_after_months=0'
mutate '.keys[0].holders[0].path="../escape"'
mutate '.keys[0].holders[0].path="/absolute"'
mutate '.keys[0].holders[0].path="a//b"'
mutate '.keys[0].holders[0].path="a\\b"'
mutate '.keys[0].holders[0].path="a\nb"'
mutate '.keys[0].holders[0].device="absent"'
mutate '.keys[0].holders[0].observed_at="2026-01-01T25:00:00Z"'
mutate '.keys[0].holders += [.keys[0].holders[0]]'
mutate '.keys[0].name=".."'
mutate '.keys[0].replaces=.keys[0].fingerprint'
mutate '.keys[0].replaces=.keys[1].fingerprint | .keys[1].replaces=.keys[0].fingerprint'
mutate '.keys[0].status="retired"'
mutate '.devices.other=.devices.test'
mutate 'del(.keys[0].created)'
mutate '.keys[0].authorization_scope_complete="false"'
# Validate linked replacement, calendar leap date, nullable/empty fields.
jq '.keys[0].replaces=.keys[1].fingerprint | .keys[0].created="2024-02-29"' "$TMP/base.json" > "$TMP/valid.json"
run 0 --json --registry "$TMP/valid.json" --device test
ok 'schema types, dates, traversal, uniqueness, hostname ambiguity, replacement cycles'

printf 'version: 1\nversion: 1\ndevices: {}\nkeys: []\n' > "$TMP/bad.yaml"
run 2 --json --registry "$TMP/bad.yaml"
printf 'version: 1\ndevices:\n  test:\n    hostnames: []\n    provisioning: inventoried\n    provisioning: unprovisioned\nkeys: []\n' > "$TMP/bad.yaml"
run 2 --json --registry "$TMP/bad.yaml"
printf 'version: 1\ndevices: {}\nkeys: []\n---\nversion: 1\ndevices: {}\nkeys: []\n' > "$TMP/bad.yaml"
run 2 --json --registry "$TMP/bad.yaml"
printf 'version: 1\ndevices: {}\nkeys: !evil []\n' > "$TMP/bad.yaml"
run 2 --json --registry "$TMP/bad.yaml"
printf '[' > "$TMP/bad.yaml"
run 2 --json --registry "$TMP/bad.yaml"
printf 'version: 1\ndevices: {}\nkeys: .nan\n' > "$TMP/bad.yaml"
run 2 --json --registry "$TMP/bad.yaml"
cp "$REG" "$TMP/bad.yaml"
printf '    provisioning: inventoried\n' >> "$TMP/bad.yaml"
run 2 --json --registry "$TMP/bad.yaml"
ok 'duplicate YAML mappings, custom tags, multi-document and malformed input'

mv "$SSH_DIR/key one" "$SSH_DIR/renamed"
mv "$SSH_DIR/key one.pub" "$SSH_DIR/renamed.pub"
run 0 --json --registry "$REG" --device test
assert has holder_path_drift
assert has naming
assert has missing_expected_private
mv "$SSH_DIR/renamed" "$SSH_DIR/key one"
mv "$SSH_DIR/renamed.pub" "$SSH_DIR/key one.pub"
jq '.keys=[]' "$TMP/base.json" > "$TMP/empty.json"
run 0 --json --registry "$TMP/empty.json" --device test
assert has unregistered_key
cp "$SSH_DIR/encrypted.pub" "$TMP/public-backup"
cp "$SSH_DIR/key one.pub" "$SSH_DIR/encrypted.pub"
# Encrypted key cannot be pair verified: report gap, not matched.
run 0 --json --registry "$REG" --device test
assert has private_uncheckable
cp "$TMP/public-backup" "$SSH_DIR/encrypted.pub"
cp "$SSH_DIR/key one.pub" "$TMP/public-backup"
cp "$SSH_DIR/encrypted.pub" "$SSH_DIR/key one.pub"
run 2 --json --registry "$REG" --device test
assert has pair_mismatch
cp "$TMP/public-backup" "$SSH_DIR/key one.pub"
printf 'invalid\n' > "$SSH_DIR/bad.pub"
run 2 --json --registry "$REG" --device test
assert has invalid_public_key
rm "$SSH_DIR/bad.pub"
mv "$SSH_DIR/key one.pub" "$TMP/public-backup"
run 0 --json --registry "$REG" --device test
assert has missing_public
mv "$TMP/public-backup" "$SSH_DIR/key one.pub"
ok 'unregistered, renamed, missing companion, invalid public and pair mismatch'

jq '.devices.other={hostnames:[],provisioning:"unprovisioned"} |
  .keys[0].holders += [(.keys[0].holders[0] | .device="other" | .path="other-only")]' "$TMP/base.json" > "$TMP/shared.json"
run 0 --json --registry "$TMP/shared.json" --device test
assert has shared_software_key
assert absent missing_expected_private
run 0 --json --registry "$TMP/shared.json" --device other
assert has missing_expected_private
assert has unprovisioned
ok 'shared holder records, current-device-only missing checks, provisioning'

# Authorization/lifecycle invariants and archived material retain unresolved revocation.
jq '.keys[0] |= (.status="retiring" | .holders[0].material_state="archived" |
  .authorized=[{kind:"account",host:"example.invalid",account:null,repository:null,ssh_alias:null,
    verification_status:"unverified",verified_at:null,revocation_status:"pending",revoked_at:null}])' "$TMP/base.json" > "$TMP/retiring.json"
run 0 --json --registry "$TMP/retiring.json" --device test
assert has pending_revocation
jq '.keys[0].status="retired"' "$TMP/retiring.json" > "$TMP/bad.json"
run 2 --json --registry "$TMP/bad.json" --device test
jq '.keys[0] |= (.status="retired" | .authorization_scope_complete=true |
  .authorized[0] |= (.revocation_status="completed" | .revoked_at="2026-01-01T00:00:00Z" | .evidence="fixture"))' "$TMP/retiring.json" > "$TMP/retired.json"
run 0 --json --registry "$TMP/retired.json" --device test
jq '.keys[0].authorized[0].evidence=null' "$TMP/retired.json" > "$TMP/bad.json"
run 2 --json --registry "$TMP/bad.json" --device test
jq '.keys[0].authorized += [.keys[0].authorized[0]]' "$TMP/retired.json" > "$TMP/bad.json"
run 2 --json --registry "$TMP/bad.json" --device test
jq '.keys[0].authorized[0].verification_status="verified"' "$TMP/retired.json" > "$TMP/bad.json"
run 2 --json --registry "$TMP/bad.json" --device test
ok 'partial revocation, retirement coverage, evidence, verified scope, destination duplicates'

mkdir "$SSH_DIR/retired" "$TMP/external"
printf 'invalid\n' > "$SSH_DIR/retired/old.pub"
printf 'invalid\n' > "$TMP/external/outside.pub"
ln -s "$TMP/external" "$SSH_DIR/linkdir"
ln -s "$TMP/external/outside.pub" "$SSH_DIR/link.pub"
ln -s "$SSH_DIR/key one.pub" "$SSH_DIR/internal.pub"
printf 'invalid\n' > "$SSH_DIR/authorized_keys"
printf 'invalid\n' > "$SSH_DIR/known_hosts"
printf 'invalid\n' > "$SSH_DIR/whatever-cert.pub"
printf 'Include ~/.orbstack/ssh/config\nIdentityFile /external/key\n' > "$SSH_DIR/config"
run 0 --json --registry "$REG" --device test
assert absent invalid_public_key
assert has symlink_excluded
assert has config_references
# Companion symlinks must not be followed by implicit ssh-keygen -l fallback.
mv "$SSH_DIR/key one.pub" "$TMP/public-backup"
ln -s "$TMP/external/outside.pub" "$SSH_DIR/key one.pub"
run 0 --json --registry "$REG" --device test
assert absent invalid_public_key
assert absent pair_mismatch
assert has symlink_excluded
rm "$SSH_DIR/key one.pub"
mv "$TMP/public-backup" "$SSH_DIR/key one.pub"
chmod 644 "$SSH_DIR/key one"
chmod 755 "$SSH_DIR"
run 0 --json --registry "$REG" --device test
assert has unsafe_permissions
chmod 600 "$SSH_DIR/key one"
chmod 700 "$SSH_DIR"
ok 'archive, inbound/trust/certificate exclusion, symlink boundaries, reference gaps, mode checks'

# Mock a hardware key container marker. Any -y hardware invocation is fatal.
REAL_KEYGEN=$(command -v ssh-keygen)
printf '%s\n' '-----BEGIN OPENSSH PRIVATE KEY-----' > "$SSH_DIR/hardware"
printf 'fixture sk-ssh-ed25519@openssh.com marker' | base64 >> "$SSH_DIR/hardware"
printf '\n%s\n' '-----END OPENSSH PRIVATE KEY-----' >> "$SSH_DIR/hardware"
chmod 600 "$SSH_DIR/hardware"
cp "$SSH_DIR/key one.pub" "$SSH_DIR/hardware.pub"
cat > "$TMP/bin/ssh-keygen" <<'MOCK'
#!/usr/bin/env bash
case "$*" in
  *hardware*)
    if [[ "$1" == -y ]]; then printf 'hardware derive forbidden\n' >> "$HARDWARE_MARKER"; exit 99; fi
    printf '256 SHA256:AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA fixture (ED25519-SK)\n'; exit 0 ;;
esac
exec "$REAL_KEYGEN" "$@"
MOCK
chmod +x "$TMP/bin/ssh-keygen"
export REAL_KEYGEN HARDWARE_MARKER=$TMP/touched
run 0 --json --registry "$REG" --device test
assert has hardware_uncheckable
assert test ! -e "$TMP/touched"
assert test ! -e "$TMP/forbidden"
ok 'hardware handling never derives or prompts; no network/agent/UI tools'
rm "$TMP/bin/ssh-keygen" "$SSH_DIR/hardware" "$SSH_DIR/hardware.pub"

# Directory-symlink deployment: helper lookup must survive ~/.bin -> repository .bin.
ln -s "$ROOT" "$HOME/.bin"
AUDIT=$HOME/.bin/ssh-key-audit
run 0 --json --registry "$REG" --device test
assert jq -e '.completed==true' "$TMP/out" >/dev/null
ok 'symlink-directory invocation'

# Exercise GNU stat/getfacl branch on macOS too. Platform behavior is mocked;
# native Linux execution remains separate coverage requirement.
REAL_STAT=$(command -v stat)
REAL_STAT_DIALECT=gnu
if "$REAL_STAT" -f '%u %Lp' "$TMP" >/dev/null 2>&1; then REAL_STAT_DIALECT=bsd; fi
export REAL_STAT REAL_STAT_DIALECT
cat > "$TMP/bin/stat" <<'MOCK'
#!/usr/bin/env bash
if [[ "$1" == -f ]]; then exit 1; fi
if [[ "$MOCK_OWNER" == 1 ]]; then printf '999999 600\n'; exit 0; fi
if [[ "$REAL_STAT_DIALECT" == bsd ]]; then exec "$REAL_STAT" -f '%u %Lp' "$3"; fi
exec "$REAL_STAT" "$@"
MOCK
cat > "$TMP/bin/getfacl" <<'MOCK'
#!/usr/bin/env bash
case "$MOCK_ACL" in
  exposed) printf 'user::rw-\nuser:other:r--\ngroup::---\nmask::r--\nother::---\n' ;;
  failed) exit 1 ;;
  *) printf 'user::rw-\ngroup::---\nother::---\n' ;;
esac
MOCK
chmod +x "$TMP/bin/stat" "$TMP/bin/getfacl"
export MOCK_ACL=exposed MOCK_OWNER=0
run 0 --json --registry "$REG" --device test
assert has acl_present
export MOCK_ACL=failed
run 0 --json --registry "$REG" --device test
assert has acl_gap
export MOCK_ACL=plain MOCK_OWNER=1
run 0 --json --registry "$REG" --device test
assert has unsafe_permissions
rm "$TMP/bin/stat" "$TMP/bin/getfacl"
unset MOCK_ACL MOCK_OWNER
ok 'mocked GNU stat, ACL exposure/failure and ownership mismatch'

mkdir "$TMP/minimal-bin"
ln -s "$(command -v dirname)" "$TMP/minimal-bin/dirname"
PATH="$TMP/minimal-bin" run 2 --json --registry "$REG" --device test
assert jq -e '.completed==false' "$TMP/out"
printf '#!/bin/sh\nexit 7\n' > "$TMP/bin/find"
chmod +x "$TMP/bin/find"
run 2 --json --registry "$REG" --device test
assert jq -e '.completed==false' "$TMP/out"
rm "$TMP/bin/find"
mkdir "$TMP/empty-ssh"
chmod 700 "$TMP/empty-ssh"
run 0 --json --verbose --strict --registry "$TMP/empty.json" --ssh-dir "$TMP/empty-ssh" --device test
assert jq -e '.warnings==0 and .errors==0' "$TMP/out"
ok 'missing dependency/required operation errors, strict warning-free completion'

# Age review uses confirmed date, not mtime; unknown remains unknown.
jq '.keys[0].created="2000-01-31" | .keys[0].review_after_months=1' "$TMP/base.json" > "$TMP/aged.json"
run 0 --json --registry "$TMP/aged.json" --device test
assert has age_review
jq --arg today "$(date -u +%Y-%m-%d)" '.keys[0].created=$today | .keys[0].review_after_months=1' "$TMP/base.json" > "$TMP/recent.json"
run 0 --json --registry "$TMP/recent.json" --device test
assert absent age_review
ok 'age review based on explicit date and interval'

before=$(cksum "$SSH_DIR/key one" "$REG")
run 0 --json --registry "$REG" --device test
assert test "$before" = "$(cksum "$SSH_DIR/key one" "$REG")"
assert test ! -e "$TMP/forbidden"
ok 'private bytes and registry unchanged; prohibited tools never invoked'
printf 'PASS: %s groups (%s)\n' "$TESTS" "$BASH_UNDER_TEST"
