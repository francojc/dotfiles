# Isolated SSH key generator tests

Run from repository root; all generated material lives in disposable temporary directories. Tests replace `HOME`, `SSH_DIR`, and `XDG_CONFIG_HOME`, clear agent variables, wrap `ssh-keygen` to create encrypted fixtures without prompts, and mock SSH/agent/clipboard/browser tools. No live keys, registry, network, agent, clipboard, browser, or hardware are used.

```bash
bash .bin/tests/ssh-key-setup/run.sh
BASH_UNDER_TEST=/bin/bash /bin/bash .bin/tests/ssh-key-setup/run.sh
```

`BASH_UNDER_TEST` selects generator interpreter; default uses Bash on PATH. Requires Bash 3.2+, OpenSSH `ssh-keygen`, jq, and standard file utilities. Fixture passphrase appears only in test wrapper, never production arguments or registry suggestion. Temporary tree is removed on exit.

## Coverage

- Help/version, explicit positional arguments, removed force, missing/unknown options.
- Strict nickname/purpose validation, traversal rejection, distinct replacement naming, URL/SSH-target validation.
- Dry-run with every opt-in: no tool execution or filesystem writes, including absent SSH directory.
- Private/public collisions with files, directories, live symlinks, and dangling symlinks; unchanged existing objects/content.
- Encrypted disposable generation, fingerprint recomputation, registry suggestion validated against existing schema, private mode 600, old pair unchanged during replacement overlap.
- Failed/incomplete generation and fingerprint failure: nonzero exit, retained/reported staging, no success output or side effects.
- Late private/public/dangling-symlink/directory collisions after preflight: no overwrite, explicit partial-publication report.
- Explicit opt-in mock invocations; remote flags disable user config, agent identities, trust changes, and multiplex reuse.
- Post-generation opt-in failure: nonzero exit, pair and suggestion preserved.
- SSH-root symlink refusal, existing directory permissions unchanged, `~/.bin`-style symlink-directory invocation, runtime-registry sentinel unchanged.

## Safety and limits

Production generates into mode-700 staging, publishes with Bash `noclobber`, and removes only successful staging. Two-file publication is not atomic: public collision may leave newly published private file plus staging, explicitly reported for owner cleanup. No generator path deletes existing destinations. Trusted user-controlled SSH directory/ancestors required; this is not protection from hostile same-user directory swaps or nonregular-file races. Process interruption may leave partial new output; staging path is logged before generation.

Verified on macOS with Bash 3.2.57 and Bash 5.3.15. Native Linux, physical tokens, actual agent/UI/network integrations, interactive passphrase entry, disk-full/write-failure/signal injection, and hostile concurrent-directory mutation remain untested. ShellCheck unavailable during implementation. Remote success recognition is intentionally limited to exit 0 or `successfully authenticated` greeting; other greetings report unconfirmed, never inferred authorization evidence.
