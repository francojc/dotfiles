#!/usr/bin/env bash
# Disposable fixtures only; never use live HOME, network, agents, or UI.
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/../.." && pwd -P)
SETUP=$ROOT/ssh-key-setup
BASH_UNDER_TEST=${BASH_UNDER_TEST:-$(command -v bash)}
REAL_KEYGEN=$(command -v ssh-keygen)
TMP=$(mktemp -d "${TMPDIR:-/tmp}/ssh-key-setup-test.XXXXXXXX")
trap 'rm -rf "$TMP"' EXIT
export HOME=$TMP/home SSH_DIR=$TMP/home/.ssh XDG_CONFIG_HOME=$TMP/config
export REAL_KEYGEN TEST_ROOT=$TMP
unset SSH_AUTH_SOCK SSH_AGENT_PID SSH_KEYS_REGISTRY || true
mkdir -p "$SSH_DIR" "$XDG_CONFIG_HOME/ssh" "$TMP/bin"
chmod 700 "$HOME" "$SSH_DIR"
printf 'registry sentinel\n' > "$XDG_CONFIG_HOME/ssh/keys.yaml"
registry_before=$(cksum "$XDG_CONFIG_HOME/ssh/keys.yaml")
cat > "$TMP/bin/ssh-keygen" <<'MOCK'
#!/usr/bin/env bash
set -eu
printf '%s\n' "$*" >> "$TEST_ROOT/keygen-calls"
if [[ "$1" == -t ]]; then
  path=''
  while [[ $# -gt 0 ]]; do
    if [[ "$1" == -f ]]; then path=$2; fi
    shift
  done
  case "${MOCK_GENERATION:-ok}" in
    fail) printf 'partial fixture\n' > "$path"; exit 7 ;;
    incomplete) printf 'partial fixture\n' > "$path"; exit 0 ;;
    race-private) printf 'racing private\n' > "$SSH_DIR/id_ed25519_test_github" ;;
    race-public) printf 'racing public\n' > "$SSH_DIR/id_ed25519_test_github.pub" ;;
    race-link) ln -s "$TEST_ROOT/missing-target" "$SSH_DIR/id_ed25519_test_github" ;;
    race-directory) mkdir "$SSH_DIR/id_ed25519_test_github" ;;
  esac
  # Noninteractive encrypted fixture; production script never receives passphrase.
  exec "$REAL_KEYGEN" -q -t ed25519 -N fixture-passphrase -C 'test github' -f "$path"
fi
[[ "${MOCK_GENERATION:-ok}" != bad-fingerprint ]] || exit 8
exec "$REAL_KEYGEN" "$@"
MOCK
for tool in ssh ssh-add pbcopy open; do
  printf '#!/bin/sh\nprintf "%%s\\n" "%s $*" >> "$TEST_ROOT/effects"\nexit "${MOCK_EFFECT_EXIT:-0}"\n' "$tool" > "$TMP/bin/$tool"
done
chmod +x "$TMP/bin/"*
export PATH="$TMP/bin:$PATH"
TESTS=0
ok() { TESTS=$((TESTS+1)); printf 'ok %s – %s\n' "$TESTS" "$1"; }
assert() { "$@" >/dev/null || { printf 'FAIL assertion: %s\n' "$*" >&2; exit 1; }; }
run() {
  local expected=$1 result=0
  shift
  "$BASH_UNDER_TEST" "$SETUP" "$@" > "$TMP/out" 2> "$TMP/err" || result=$?
  [[ "$result" -eq "$expected" ]] || { printf 'FAIL exit %s expected %s\n' "$result" "$expected" >&2; while IFS= read -r line; do printf '%s\n' "$line" >&2; done < "$TMP/err"; exit 1; }
}
reset_dir() { rm -rf "$SSH_DIR"; mkdir -m 700 "$SSH_DIR"; rm -f "$TMP/keygen-calls" "$TMP/effects"; }
run 0 --help
run 0 --version
run 1
run 1 test
run 1 test github extra
run 1 --force test github
run 1 -f test github
run 1 --replacement-name
run 1 --unknown test github
ok 'help/version, explicit arguments, removed force, option errors'
for label in '../escape' '/absolute' 'a/b' 'UPPER' 'a b' 'a.b' 'a@b' $'a\nb' '-bad' ''; do
  run 1 -- "$label" github
  run 1 -- test "$label"
done
run 1 --replacement-name id_ed25519_test_github test github
run 1 --replacement-name ../escape test github
run 1 --replacement-name id_ed25519_test_github_../escape test github
run 1 --replacement-name id_ed25519_other_github_2027 test github
run 1 --check-remote '-oProxyCommand=bad' test github
run 1 --open-url 'file:///tmp/foo' test github
assert test ! -e "$TMP/keygen-calls"
ok 'strict naming, traversal, distinct replacements, safe opt-in values'
run 0 -n --load-agent --copy --open-url https://example.invalid/keys --check-remote git@example.invalid test github
assert test ! -e "$TMP/keygen-calls"
assert test ! -e "$TMP/effects"
assert test -z "$(find "$SSH_DIR" -mindepth 1 -print)"
SSH_DIR="$TMP/absent" run 0 -n test github
assert test ! -e "$TMP/absent"
ok 'dry-run writes nothing and executes no generation/side-effect tools'
for companion in '' '.pub'; do
  for kind in file directory dangling symlink; do
    reset_dir
    path=$SSH_DIR/id_ed25519_test_github$companion
    case "$kind" in
      file) printf 'existing material\n' > "$path" ;;
      directory) mkdir "$path" ;;
      dangling) ln -s "$TMP/missing" "$path" ;;
      symlink) printf 'target sentinel\n' > "$TMP/target"; ln -s "$TMP/target" "$path" ;;
    esac
    before=$(ls -ld "$path")
    run 1 test github
    run 1 -n test github
    assert test "$before" = "$(ls -ld "$path")"
    [[ "$kind" != file ]] || assert grep -qx 'existing material' "$path"
    [[ "$kind" != symlink ]] || assert grep -qx 'target sentinel' "$TMP/target"
    assert test ! -e "$TMP/keygen-calls"
  done
done
ok 'private/public collision matrix incl directories and dangling/live symlinks'
reset_dir
run 0 test github
assert test -s "$SSH_DIR/id_ed25519_test_github"
assert test -s "$SSH_DIR/id_ed25519_test_github.pub"
assert test ! -e "$TMP/effects"
assert jq -e '.name=="id_ed25519_test_github" and .purpose=="github" and .created==null and .replaces==null and .authorized==[] and (.authorization_scope_complete|not)' "$TMP/out"
jq '{version:1,devices:{test:{hostnames:[],provisioning:"inventoried"}},keys:[.]}' "$TMP/out" > "$TMP/registry.json"
assert jq -e -f "$ROOT/ssh-key-audit-lib/validate.jq" "$TMP/registry.json"
fp=$("$REAL_KEYGEN" -E sha256 -lf "$SSH_DIR/id_ed25519_test_github.pub")
fp=${fp#* }; fp=${fp%% *}
assert jq -e --arg fp "$fp" '.fingerprint==$fp' "$TMP/out"
assert test -z "$(find "$SSH_DIR" -name '.ssh-key-setup.*' -print)"
# Private/public permissions generated with restrictive umask.
if stat -f '%Lp' "$SSH_DIR/id_ed25519_test_github" >/dev/null 2>&1; then
  mode=$(stat -f '%Lp' "$SSH_DIR/id_ed25519_test_github")
else
  mode=$(stat -c '%a' "$SSH_DIR/id_ed25519_test_github")
fi
assert test "$mode" = 600
before=$(cksum "$SSH_DIR/id_ed25519_test_github" "$SSH_DIR/id_ed25519_test_github.pub")
run 0 --replacement-name id_ed25519_test_github_2027 test github
assert test "$before" = "$(cksum "$SSH_DIR/id_ed25519_test_github" "$SSH_DIR/id_ed25519_test_github.pub")"
assert jq -e '.name=="id_ed25519_test_github_2027" and .holders[0].path==.name' "$TMP/out"
run 1 --replacement-name id_ed25519_test_github_2027 test github
ok 'encrypted generation, fingerprint/schema suggestion, mode 600, overlap preserves old pair'
for failure in fail incomplete bad-fingerprint; do
  reset_dir
  MOCK_GENERATION=$failure run 1 test github
  assert test ! -e "$SSH_DIR/id_ed25519_test_github"
  assert test ! -e "$SSH_DIR/id_ed25519_test_github.pub"
  assert test -n "$(find "$SSH_DIR" -name key -print)"
  assert test ! -s "$TMP/out"
  assert test ! -e "$TMP/effects"
  assert grep -Eqi 'failed|Incomplete' "$TMP/err"
done
ok 'failed/incomplete generation and fingerprint failure retain reported staging, no success/side effects'
for race in race-private race-public race-link race-directory; do
  reset_dir
  MOCK_GENERATION=$race run 1 test github
  assert test ! -s "$TMP/out"
  assert grep -q 'publication failed' "$TMP/err"
  case "$race" in
    race-private) assert grep -qx 'racing private' "$SSH_DIR/id_ed25519_test_github" ;;
    race-public) assert grep -qx 'racing public' "$SSH_DIR/id_ed25519_test_github.pub"; assert test -s "$SSH_DIR/id_ed25519_test_github" ;;
    race-link) assert test -L "$SSH_DIR/id_ed25519_test_github"; assert test ! -e "$TMP/missing-target" ;;
    race-directory) assert test -d "$SSH_DIR/id_ed25519_test_github"; assert test -z "$(find "$SSH_DIR/id_ed25519_test_github" -mindepth 1 -print)" ;;
  esac
done
ok 'late private/public/dangling-symlink/directory collisions never overwrite; partial publication reported'
reset_dir
run 0 --load-agent --copy --open-url https://example.invalid/keys --check-remote git@example.invalid test github
assert test "$(wc -l < "$TMP/effects" | tr -d ' ')" = 4
assert grep -q '^ssh-add ' "$TMP/effects"
assert grep -q '^pbcopy ' "$TMP/effects"
assert grep -q '^open https://example.invalid/keys' "$TMP/effects"
assert grep -q 'ssh -F /dev/null.*IdentityAgent=none.*StrictHostKeyChecking=yes.*ControlPath=none' "$TMP/effects"
ok 'all side effects explicit, remote config/agent/trust isolation (mocked only)'
reset_dir
MOCK_EFFECT_EXIT=9 run 1 --load-agent test github
assert test -s "$SSH_DIR/id_ed25519_test_github"
assert jq -e '.fingerprint' "$TMP/out"
assert grep -q 'Operation failed' "$TMP/err"
ok 'post-generation opt-in failure exits nonzero and preserves generated pair/suggestion'
reset_dir
mkdir "$TMP/external"
ln -s "$TMP/external" "$TMP/linkdir"
SSH_DIR="$TMP/linkdir" run 1 test github
assert test -z "$(find "$TMP/external" -mindepth 1 -print)"
chmod 755 "$SSH_DIR"
run 0 test custom
if stat -f '%Lp' "$SSH_DIR" >/dev/null 2>&1; then mode=$(stat -f '%Lp' "$SSH_DIR"); else mode=$(stat -c '%a' "$SSH_DIR"); fi
assert test "$mode" = 755
ok 'SSH root symlink refused; existing directory permissions unchanged'
reset_dir
ln -s "$ROOT" "$HOME/.bin"
SETUP=$HOME/.bin/ssh-key-setup
run 0 test github
assert jq -e '.name=="id_ed25519_test_github"' "$TMP/out"
assert test "$registry_before" = "$(cksum "$XDG_CONFIG_HOME/ssh/keys.yaml")"
assert test ! -e "$TMP/effects"
ok 'directory-symlink invocation, runtime registry untouched, defaults stay local'
printf 'PASS: %s groups (%s)\n' "$TESTS" "$BASH_UNDER_TEST"
