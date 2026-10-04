# SSH audit isolated tests

Run from repository root:

```bash
bash .bin/tests/ssh-key-audit/run.sh
BASH_UNDER_TEST=/bin/bash bash .bin/tests/ssh-key-audit/run.sh
```

`BASH_UNDER_TEST` selects audit interpreter; on macOS `/bin/bash` exercises Bash 3.2. Runner also supports Bash 3.2. Fixtures use temporary HOME, SSH directory, XDG directory, and registries; software keys generated here are disposable. No live registry or SSH material is inspected. Cleanup removes only runner-owned temporary directory.

15 test groups cover CLI/exit/JSON behavior, starter YAML, registry validation, duplicates/tags/documents, schema/lifecycle invariants, dates/replacement chains, software fingerprints, encrypted/empty-passphrase keys, mismatches, missing/renamed keys, shared holders, device selection/override precedence, nested/spaced paths, archives, inbound/trust/certificate exclusions, symlink boundaries, config-reference coverage gaps, modes/ownership/ACL reporting, hardware non-interaction, symlink-directory deployment, missing dependencies, age reminders, and byte preservation.

SSH, agent, browser, and clipboard commands are replaced with failure sentinels. Hardware handling uses mock container/type marker and keygen sentinel; no physical authenticator is enrolled or touched. GNU stat/getfacl behavior is mocked to exercise Linux branches on macOS. Native platform stat/ACL tools are exercised during ordinary scans. Native Linux, physical hardware, real extended ACLs, and remote checks remain separate coverage; ShellCheck is optional and not bundled.

Tests report groups, not individual assertions. A failing exit/assertion stops runner immediately. No test retrieves secrets or prints private-key bytes.
