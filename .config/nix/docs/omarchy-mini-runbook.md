# Runbook: Minimal Macs, two Omarchy hosts

Branch: `os/omarchy-mini`. Working dir: `~/.dotfiles/.config/nix`.

Status legend: `[x]` done, `[ ]` pending, `[~]` needs a decision first.

## 1. Context

`Mac-Minicore` (M4 Mac mini, 494 GB APFS container) is becoming a thin host for a try-omarchy VM. Omarchy gets most of the disk and does the real work. `Macbook-Airborne` is demoted the same way. The existing `omarchy` host is renamed `Omarchy-Air` (native dual-boot on the MacBook Air), and a new `Omarchy-Mini` (VM on Mac-Minicore) is added. `nixos-quattro` is retired. `Mini-Rover` is untouched.

### Target hosts

| Host | Class | Builder | Flake output |
|---|---|---|---|
| `Macbook-Airborne` | minimal nix-darwin + HM | `darwinSystem` | `darwinConfigurations` |
| `Mac-Minicore` | minimal nix-darwin + HM + LLM host | `darwinSystem` | `darwinConfigurations` |
| `Omarchy-Air` | Arch/Omarchy, native dual-boot | standalone HM | `homeConfigurations` |
| `Omarchy-Mini` | Arch/Omarchy in a try-omarchy VM | standalone HM | `homeConfigurations` |
| `Mini-Rover` | pure NixOS (unchanged) | `nixosSystem` | `nixosConfigurations` |

### Measured starting point (2026-11-17)

| Item | Size | Note |
|---|---|---|
| APFS container | 494 GB, 402 GB used, 92 GB free | The VM must fit in here |
| Data volume | 279 GB | Only about 35 GB of it is accounted for below. Needs an audit |
| Nix Store volume | 94 GB | Largest known win; shrinks with the Mac profile and GC |
| `~/.llama/models` | 44 GB | GGUF models served by the llama.cpp launchd scripts. Found during review; stays on the Mac |
| `~/.cache/huggingface` | 13 GB | Overlaps the models above (Qwen3.6-35B GGUF). Candidate to dedupe, see step 8 |
| `~/.ollama` | 11 GB | LLM models, stay on the Mac |
| `~/Obsidian` | 3.9 GB | Moves into `~/Projects/obsidian/` (step 8) |
| `~/Projects` | 9.1 GB | Becomes the try-omarchy shared folder |
| iCloud (`Mobile Documents`) | 4.8 GB | Remove from disk |
| `~/Zotero` | 2.4 GB | Already removed by you; only the app remains |
| `~/Library/CloudStorage` (Drive) | 0.24 GB | Remove |

### try-omarchy constraints (from its manual)

- VM runs on Hypervisor.framework with QEMU. Disk is a sparse APFS image under `~/Library/Application Support/Try Omarchy/VM/v1`. It takes host space only as the guest fills it.
- Disk size defaults to 64 GiB. It **can grow but cannot shrink**, so the cap must be set deliberately.
- Memory defaults to 8 GiB on a Mac with 16 GiB or more. At least 4 GiB always stays with macOS, and memory the guest is not using returns to macOS. Sizing for this 32 GiB machine is in section 3a.
- One shared Mac folder only: `/Users/jeridf/Projects`. It is mounted at `/mnt/mac` (9p, `cache=readahead`) and linked to `~/Projects` in the guest. Git works; writable `mmap` and SQLite WAL do not. Keep databases, caches, `node_modules`-style build trees and the Nix store on the guest disk.
- No Vulkan, and video decode is CPU. You have confirmed this is acceptable: no video-heavy work, and the GPU is left to macOS for the local LLM servers (Metal).
- Image is the official aarch64 Omarchy on the `edge` channel. `omarchy update` snapshots first.
- The VM drive must be APFS. Do not unplug an external drive while it runs.

## 2. Design principles (why this shape)

1. **Plain imports over option flags.** A host picks profiles and roles by listing files. Nothing in the flake needs `custom.features.*` plumbing across three module systems (nix-darwin, NixOS, standalone HM). This is the smaller, easier-to-verify change on a branch you are still experimenting on.
2. **One shared definition per concern.** Package groups already live in `lib/packages/*.nix`. Everything Arch-specific moves next to them (`lib/packages/arch.nix`) rather than living under one host directory. This is what makes two Arch hosts cheap.
3. **Hosts are thin, but each Arch host has its own tweak file.** A host file holds identity (system, user, theme, nickname) plus a list of profiles and roles. Behaviour lives in profiles and roles. Because you will hand-tune the two Omarchy hosts, each gets `hosts/<Host>/local.nix`: an HM module that starts nearly empty and is the one place for host-specific package additions, session variables, theme tweaks and overrides. It is listed last in `homeModules` so `lib.mkForce`/`mkDefault` behave predictably.
4. **Heavy tooling lives where the work happens.** The Macs get a short, stable package list. LSPs, toolchains, media, mail and docs tooling go to the Omarchy hosts only.
5. **Never change what Mini-Rover and Omarchy-Air install by accident.** Every refactor step gets a before/after closure comparison (see section 6).
6. **Reversible by default.** Small commits, one concern each. Mac switches use generations, so `darwin-rebuild --rollback` works. Data deletion is a separate, explicit step after a backup check.

## 3. Target layout

```
flake.nix                      # host table, 3 builders, per-Arch-host tool outputs
lib/
  systems.nix                  # unchanged (platform = "arch" routing)
  packages/{lsp,cli,dev,media}.nix
  packages/arch.nix            # moved from hosts/omarchy/packages.nix (step 2)
profiles/
  darwin/{base,minimal,llm-host}.nix
  arch/{base,native,vm}.nix
  nixos/configuration.nix      # Mini-Rover only
roles/                         # HM modules, plain imports, no options
  core/                        # every host: shell, git, editor, tmux, gpg
  heavy/                       # Arch hosts only: dev-tools, docs, mail, media
hosts/
  Macbook-Airborne  Mac-Minicore  Mini-Rover
  Omarchy-Air/{default,local}.nix
  Omarchy-Mini/{default,local}.nix
docs/
  arch-omarchy.md              # updated for two Arch hosts
  omarchy-mini-runbook.md      # this file
```

`modules/arch/{shell,tmux}.nix` and `home/arch-core.nix` fold into `roles/` (see step 4). `modules/shared/*` stays as is.

### Imports per host

| Host | Profiles | HM roles |
|---|---|---|
| Macbook-Airborne | `darwin/base`, `darwin/minimal` | core |
| Mac-Minicore | `darwin/base`, `darwin/minimal`, `darwin/llm-host` | core |
| Omarchy-Air | `arch/base`, `arch/native`, `hosts/Omarchy-Air/local.nix` | core + heavy |
| Omarchy-Mini | `arch/base`, `arch/vm`, `hosts/Omarchy-Mini/local.nix` | core + heavy |
| Mini-Rover | `nixos/configuration` | unchanged (`home/gnome.nix` + legacy modules) |

### Why these profile splits

- `arch/base`: everything both Omarchy hosts need. `targets.genericLinux`, the flake overlay, `allowUnfree`, Omarchy env-bootstrap, gpg-agent. Today this is `profiles/arch/configuration.nix` and is already host-agnostic.
- `arch/native`: bare-metal, laptop items for Omarchy-Air only (power, lid, hardware quirks, anything Omarchy does not already own). Starts nearly empty. Having the slot prevents VM-only config from leaking into the laptop.
- `arch/vm`: try-omarchy guest quirks. The sioyek portal override already in `lib/packages/media.nix` is a candidate, as are the shared-folder path convention and software-GL wrappers (kitty already has one in `home/kitty.nix`).
- `darwin/minimal`: the demotion for both Macs. Trimmed brew/cask lists, a short Nix package list, and the minimal HM roles.
- `darwin/llm-host`: Minicore only. launchd services, LLM brews, model paths.

## 3a. Memory budget (32 GiB Mac mini)

Measured by your own server scripts (`~/.llama.cpp/scripts/start-llama-*.sh`): the Metal working-set ceiling on this machine is about 24 GiB, and the three servers already use 21.97 GiB of it.

| Server | Model | GiB (weights + KV) |
|---|---|---|
| chat (:8081) | Qwen3.6-35B-A3B-UD-Q4_K_S + mmproj, `--ctx-size 65536`, KV q4_0 | 19.92 + 0.84 + 0.72 |
| FIM (:8080) | Qwen2.5-Coder 0.5B Q8_0 | 0.49 |
| embed (:8082) | nomic-embed-text v1.5 Q8_0 | about 0.14 |
| **Total** | | **about 22.1 GiB (ceiling about 24 GiB)** |

The scripts' own notes record that a 3B FIM pushes the total to 24.54 GiB and wedges the Metal backend (`kIOGPUCommandBufferCallbackErrorOutOfMemory`, every later request fails with "Compute error"). So there is **about 2 GiB of GPU headroom and no room to trade it**. The VM must not take memory the GPU working set needs.

Leftover for everything else: 32 - 22.1 = about 9.9 GiB, shared by macOS (kernel, WindowServer, helium, orbstack, Tailscale, etc., about 4–5 GiB in practice) and the VM.

**Recommendation: VM memory 6 GiB at first, 8 GiB as the ceiling. Do not go to 10 GiB.**

- 8 GiB leaves about 2 GiB for macOS beyond the 4 GiB try-omarchy always reserves. It runs, but sits at the edge.
- 10 GiB would force macOS to compress and swap, and the 4 GiB floor try-omarchy enforces does not protect the LLM working set.
- Memory the guest is not using returns to macOS (try-omarchy's reclamation), so a lower cap costs little at idle and bounds the worst case.
- Your 8 GiB is probably enough for nvim, tmux, a browser tab and builds. If it is tight, swap-heavy compiles are the usual cause; use `zram` in the guest rather than raising the cap.

Measure before fixing the number (step 9):

1. Start the three servers, VM off: `memory_pressure`, Activity Monitor Memory Pressure graph, swap used.
2. Start the VM at 6 GiB and use it normally for a session. Watch swap and Memory Pressure. Swap near zero and a green graph means keep 6 or raise to 8.
3. Send a long request to the chat server while the VM is busy. If it errors with "Compute error", reduce the VM cap.

Levers if it is still tight, cheapest first: lower `--ctx-size` on the chat server (the KV cache is small, so this saves little); keep the VM at 6 GiB; stop `ollama` when idle.

The llama servers bind to the Tailscale address (`HOST=100.101.38.4`). Omarchy-Mini reaches them through its own tailnet node (decided), so no VM networking changes are needed.

## 4. Optimizations and their reasons

| Change | Reason |
|---|---|
| Move `hosts/omarchy/packages.nix` to `lib/packages/arch.nix` | `flake.nix` and `home/arch-core.nix` both reach into a host directory today. With two Arch hosts, one host would import from another. |
| Generate `omarchy-global-tools` per Arch host | Today it is a hardcoded `packages.aarch64-linux.omarchy-global-tools`. Per-host outputs (`<host>-global-tools`) keep the `nix profile install` workflow working for both hosts. |
| Stop importing `pimalaya`, `syncthing`, `ssh-aliases`, `document-tools` on every host | `home/default.nix` imports all four for the Macs too. The Macs do not need mail/docs tooling. `ssh-aliases` stays in core because it is cheap and cross-host. |
| Drop `isArch` branching in `home/default.nix` for role selection | The `if isArch` list is the main thing that makes a third host class awkward. Hosts list roles instead. `isArch` stays as a special arg for the few real cross-platform conditionals. |
| Drop `virby` (keep Determinate Nix) | `services.virby.enable = false` in `modules/darwin/virby.nix`, so the input and module are dead weight. Decided: remove virby and its cachix substituter. Determinate Nix stays as the Nix installer/daemon; only the extras go. Note `determinateNix` is configured in the same file, so it must move to a small `modules/darwin/determinate.nix` (or into `base.nix`) rather than being deleted with virby. |
| Drop most Nix packages from the Macs | `home/core.nix` pulls about 60 packages (rust, go, ffmpeg, tenacity, imagemagick...). They duplicate what the VM provides and are a big part of the 94 GB store. |
| Trim brew casks and brews | `cleanup = "zap"` is already on, so removing an entry uninstalls it. |
| Fix hostname-keyed sizing | `home/kitty.nix` and `home/wezterm.nix` branch on `hostname == "Mac-Minicore"` for font sizes. New hosts fall to the default. Add entries for `Omarchy-Air` and `Omarchy-Mini` or move to a small host attribute. |
| Fix `ssh-key-paths.nix` | Map is keyed by hostname and has `"omarchy"`. Rename to `Omarchy-Air`, add `Omarchy-Mini`, add both to `plainHosts` in `ssh-aliases.nix`. |
| Retire Mac-only shell snippets from Arch | `aliases.zsh` has `gdrive`, `dswitch`, `pbcopy` helpers. They are harmless on Arch but pollute `functions.zsh`/`fzf.zsh`. Gate on `isDarwin` or split by platform. Not blocking. |

## 5. Decisions

### Decided

- VM model: try-omarchy on macOS. Mac-Minicore stays macOS.
- Macs keep: LLM servers (Minicore only), a minimal shell and a few GUI apps.
- `Macbook-Airborne` hosts no LLM services.
- `Omarchy-Air` is a native dual-boot on the MacBook Air. It is a full Omarchy install with Nix added, and parallels `Omarchy-Mini`.
- Casks kept on both Macs: `orbstack`, `helium-browser`. Everything else dropped.
- Old `omarchy` host retired via rename. `nixos-quattro` removed. `Mini-Rover` untouched.
- Omarchy-Mini VM disk: 300 GB or more.
- Shared folder is `/Users/jeridf/Projects` (mounted at `/mnt/mac`, linked to `~/Projects` in the guest). `~/Obsidian` moves inside it as `~/Projects/obsidian/`.
- Both `Mac-Minicore` and `Omarchy-Mini` are separate Tailscale nodes. Install Tailscale in the guest.
- `lm-studio` dropped. `dropbox` dropped from Airborne. `transmission` dropped (now a web service on Proxmox). Zotero data is already gone; only the app is removed. Google Drive removed.
- `node` stays on both Macs (the `copilot-api` launchd service needs it).
- Brews: any brew that has an `aarch64-linux` nixpkgs package moves to the Omarchy hosts; Mac-only formulae stay on the Macs.
- virby is removed; Determinate Nix stays as the Nix installer/daemon.
- SSH key rename risk is accepted: new keys will be generated if remotes break.
- Each Omarchy host gets a `local.nix` for hand tweaks.
- try-omarchy limitations (no Vulkan, CPU video decode) accepted. Video-heavy work is out of scope; the GPU stays with macOS for local models.
- VM memory: start at 6 GiB, ceiling 8 GiB (section 3a). Not 10 GiB.
- Disk growth on the Macs after the changeover is minimal. Keep a buffer for new llama.cpp/ollama models.

### Brew triage (D2, now answered by your rule)

Rule: if nixpkgs has an `aarch64-linux` package, it moves to the Omarchy hosts (`lib/packages/arch.nix` or `roles/heavy`). Mac-only formulae stay on the Macs. Checked against nixpkgs-unstable:

| Brew | nixpkgs aarch64-linux? | Destination |
|---|---|---|
| `hunk` | yes | Omarchy (`roles/heavy/dev-tools`) |
| `ketch` | yes | Omarchy |
| `linecast` | yes | Omarchy |
| `llm` | yes (`python3.14-llm`) | Omarchy |
| `nmap` | yes | Omarchy |
| `pandoc` | yes | Already in `arch.nix`; drop from Mac |
| `rename` | yes | Omarchy |
| `tree-sitter-cli` | yes (`tree-sitter`) | Omarchy |
| `yt-dlp` | yes | Omarchy |
| `mole` | yes, but it is a macOS cleaner | Mac (brew), skip on Omarchy |
| `node` | yes | **Stays on both Macs** (copilot-api); also Omarchy via mise |
| `synapseq` | no (tap only) | Re-check at step 6; if no Linux build, Mac only |
| `koan` | no (tap only) | Mac only unless the tap ships Linux builds |
| `borders` | no (jankyborders is macOS) | Mac |
| `mandible` | no | Mac |
| `pngpaste` | no (macOS) | Mac |
| `reminders-cli` | no (macOS) | Mac |
| LLM stack (`llama.cpp`, `ollama`, `hf`, `llmfit`) | llama-cpp and ollama exist, `hf` does not | Mac (Metal/GPU lives here), Minicore only |

Casks: `orbstack` and `helium-browser` only, on both Macs. This removes `kitty`, `obsidian`, `zotero`, `quarto`, `zoom`, `google-drive`, `transmission`, `lm-studio`, `appcleaner`, `betterdisplay`, `bettermouse`, `bettershot`, `kap`, `supercmd`, `crest-browser`, `dropbox`.

Taps follow the brews that remain: keep `felixkratz/formulae` (borders), `keith/formulae` (reminders-cli), `as-foss/mandible`; drop the rest unless a Mac-only formula still needs them (`radiosilence/koan`, `synapseq-foundation/synapseq`, decided in step 6).

### Still open

| # | Question | Needed by | Default |
|---|---|---|---|
| D1 | Terminal on the Macs once the `kitty` cask is gone | Step 6 | Install kitty via Nix HM (`home/kitty.nix` already exists), not the cask. If you would rather drop it, the Macs use Terminal.app and you SSH into the VM. |
| D6 | `omlx` (`/Applications/oMLX.app`, `.dmg`) | Step 7 | Leave alone; outside the flake. It uses GPU memory, so check it is not running alongside the servers. |
| D9 | Duplicate model storage | Step 8 | `~/.cache/huggingface` (13 GB, Qwen3.6-35B GGUF) duplicates `~/.llama/models`. The scripts use explicit paths, so the HF copy is removable. `~/.ollama` (11 GB) is separate. |
| D10 | Other Data-volume contents (about 245 GB unaccounted) | Step 8 | Audit first. |

## 6. Verification toolkit (used by every step)

Run from `~/.dotfiles/.config/nix`.

```sh
# Evaluation per host (fast, no build)
nix eval --raw .#nixosConfigurations.Mini-Rover.config.system.build.toplevel.drvPath
nix eval --raw .#darwinConfigurations.Mac-Minicore.system.drvPath
nix eval --raw .#darwinConfigurations.Macbook-Airborne.system.drvPath
nix eval --raw .#homeConfigurations.<arch-host>.activationPackage.drvPath

# Flake sanity
nix flake check --no-build
```

**Drv hash is the equality test.** For a pure refactor (no intended change), the drv path before and after must be identical. Mini-Rover's current drv is `8h7nnhpl…` and it did not change across the quattro removal. Record baselines before step 4:

```sh
mkdir -p /tmp/baseline
for h in Mini-Rover; do
  nix eval --raw .#nixosConfigurations.$h.config.system.build.toplevel.drvPath > /tmp/baseline/$h
done
nix eval --raw .#homeConfigurations.omarchy.activationPackage.drvPath > /tmp/baseline/Omarchy-Air
```

If the drv changes in a step that should not change behaviour, diff with `nix store diff-closures` or `nix-diff` on the two drvs before proceeding.

Closure-size comparison for the Mac steps (aarch64-darwin):

```sh
nix build .#darwinConfigurations.Mac-Minicore.system --no-link --print-out-paths
nix path-info -Sh <outpath>
```

Cross-evaluating the aarch64-linux Home Manager configs from darwin works for `nix eval`. Building them needs a Linux builder or must be done on the Arch host. For `Omarchy-Air` and `Omarchy-Mini`, `eval` on the Mac is the gate here, and a real build happens on the target.

## 7. Steps

Implementation notes from execution (2026-11-17):

- Step 4 used `roles/default.nix` lists (`legacyFull`, `arch`, `mac`) rather than per-file imports in each host. Verified: Omarchy-Air and Mini-Rover packages and generated files are unchanged.
- Step 6: `linecast` is not in the locked nixpkgs, so it stays a Homebrew formula (tap kept) until the next `nix flake update`. The `kitty` cask became `pkgs.kitty` (lowPrio) in `roles/core/packages-mac.nix` (D1 default). Minicore did not import Determinate before and still does not; only Airborne does (via `modules/darwin/determinate.nix`).
- Mac system closure: 8.4 GiB before, 3.6 GiB after. `cliamp` alone is about 2 GB of what is left.

### Step 1 – Remove `nixos-quattro` and dead sway/i3 code  `[x]`

Done and committed:

- `62563a9 chore(nix): remove nixos-quattro host`
- `693597d chore(nix): drop unused sway/i3 profiles and refresh README`

Mini-Rover drv unchanged. All other hosts evaluate.

### Step 2 – Make Arch packages host-independent  `[x]`

Why: removes cross-host imports and unblocks adding `Omarchy-Mini`.

- [x] `git mv hosts/omarchy/packages.nix lib/packages/arch.nix`. Fix its relative `import ../../lib/packages/*.nix` to `./*.nix`.
- [x] Update `home/arch-core.nix`: `import ../lib/packages/arch.nix pkgs`.
- [x] In `flake.nix`, replace `packages.aarch64-linux.omarchy-global-tools` with a generated set: one `<host>-global-tools` per Arch host, built via `buildEnv` from `lib/packages/arch.nix`. Keep the `allowUnfreePredicate` for `copilot-language-server`.
- [x] Update the header comment in `arch.nix`; the old text references `hosts/omarchy`.
- [x] Update `docs/arch-omarchy.md` file table.

Verify: `omarchy` activation drv unchanged. `nix eval .#packages.aarch64-linux --apply builtins.attrNames` lists the new outputs.

Risk: low. Note that the live machine uses `nix profile install .#omarchy-global-tools`; after this step the attr name changes, so the profile entry must be re-added under the new name (step 3 documents the migration command).

Commit: `refactor(nix): move arch package list to lib/packages/arch.nix`

### Step 3 – Rename `omarchy` to `Omarchy-Air`  `[x]`

Why: hostnames are the keys used by `hostname`-sensitive modules, the Justfile and the `home-manager switch` command. Rename once, early, before adding the second host.

- [x] `git mv hosts/omarchy hosts/Omarchy-Air`.
- [x] `flake.nix` host table key: `"Omarchy-Air"`.
- [x] `home/ssh-key-paths.nix`: `"Omarchy-Air" = "air"` (or `omarchyair`). WARN: the nickname defines key file names `~/.ssh/id_ed25519_<nickname>_<purpose>`. The existing machine has `id_ed25519_omarchy_*`. Choose between keeping the nickname `omarchy` (zero impact) and renaming keys on the machine. Default: keep nickname `omarchy` for the host `Omarchy-Air` and use `omarchymini` for the new one.
- [x] `home/ssh-aliases.nix` `plainHosts`: add `omarchy-air` and `omarchy-mini` entries (user `jeridf`).
- [x] `home/kitty.nix`, `home/wezterm.nix`: add font-size branches for the Arch hosts, or fall through to default. Check what they get today (default 16/14).
- [x] `Justfile`: replace `omarchy` / `omarchy-build` with host-aware recipes:
  `arch: home-manager switch --flake .#{{hostname}}` and `arch-build: nix build .#homeConfigurations.{{hostname}}.activationPackage`. `hostname` on Omarchy-Air must match the flake key, or the recipe takes the host as an argument.
- [x] `docs/arch-omarchy.md`, `README.md`: rename references and the host table.
- [x] Create `hosts/Omarchy-Air/local.nix` (empty tweak module) and list it last in `homeModules`.
- [x] Machine-side migration (run on Omarchy-Air, document, do not script from here):
  1. `nix profile remove omarchy-global-tools` then `nix profile install .#Omarchy-Air-global-tools`.
  2. First switch uses `home-manager switch --flake .#Omarchy-Air`.

Verify: `.#homeConfigurations.Omarchy-Air` evals; its drv differs from the `omarchy` baseline only by the host name (expected; confirm the diff is just `hostname`-derived strings).

Risk: low. The only real risk is the SSH key nickname.

Commit: `refactor(nix): rename omarchy host to Omarchy-Air`

### Step 4 – Extract roles and split Arch profiles  `[x]`

Why: this is the step that makes the structure real. It removes `isArch` branching from `home/default.nix`, lets the Macs opt out of heavy tooling, and gives both Arch hosts identical role lists.

Do it in sub-commits, running the baseline check after each.

**4a. Core roles (no behaviour change).**

- [x] Create `roles/core/{shell,git,editor,tmux,gpg}.nix` as thin re-exports or moves of `home/shell/default.nix`, `home/git.nix`, `home/vim.nix`, `home/tmux.nix`, and the gpg block in `core.nix`/`arch-core.nix`.
- [x] Keep the Arch variants for shell and tmux (`modules/arch/{shell,tmux}.nix`) as `roles/core/shell-arch.nix` and `tmux-arch.nix` for now. Merging Mac and Arch shell is a separate cleanup, not this step.
- [x] `home/default.nix` imports only `themes`, `ssh-aliases`, plus the host's role list passed via `homeModules`. `hostConfig.homeModules` becomes the full list for each host.

Why not merge shell variants now: the Arch shell drops macOS-isms (`brew shellenv`, `launchctl`, DYLD, Flatpak XDG hack). Merging requires `isDarwin` conditionals inside one file and risks changing Mac output while the goal here is no behaviour change.

**4b. Heavy roles.**

- [x] `roles/heavy/dev-tools.nix`: `lib/packages/{lsp,dev}.nix` plus `arch.nix` dev entries.
- [x] `roles/heavy/docs.nix`: `document-tools.nix`, pandoc, typst, tectonic, `pdc-mdpdf`.
- [x] `roles/heavy/mail.nix`: `pimalaya`, `aerc`, `khal`, `vdirsyncer`.
- [x] `roles/heavy/media.nix`: `lib/packages/media.nix` minus mail.

**4c. Arch profiles.**

- [x] `git mv profiles/arch/configuration.nix profiles/arch/base.nix`.
- [x] Add `profiles/arch/native.nix` (empty placeholder with a header comment).
- [x] `hosts/Omarchy-Air/default.nix`: `homeModules = [base native] ++ core ++ heavy`.

**4d. Mini-Rover protection.**

Mini-Rover uses `home/default.nix` through `mkHomeManagerConfig` with the non-Arch import list (core, git, kitty, wezterm, shell, tmux, vim). After 4a, `home/default.nix` no longer has the list, so Mini-Rover's host file must now list its modules. Do this in the same commit as 4a so the Mini-Rover drv does not flap.

Verify: Mini-Rover drv unchanged against baseline. Omarchy-Air drv unchanged except for rename noise. Both Macs evaluate. If a Mac drv changes, that is acceptable at this step only if the diff is import-order or module-path noise; check with `nix store diff-closures`.

Risk: medium. The usual failure is module ordering. `lib.mkAfter` on `programs.zsh.profileExtra` in `arch/base` already depends on order; re-check the resulting `.zprofile` content.

Commits: one per sub-step.

### Step 5 – Add `Omarchy-Mini` (VM)  `[x]`

- [x] `hosts/Omarchy-Mini/local.nix` (and `hosts/Omarchy-Air/local.nix`, created in step 3): empty HM module with a header comment explaining it is the manual-tweak file, listed last in `homeModules`.
- [x] `hosts/Omarchy-Mini/default.nix`: `system = "aarch64-linux"`, `platform = "arch"`, username `jeridf`, theme `tokyonight` (match Omarchy stock; revisit later), `homeModules = [arch/base arch/vm] ++ core ++ heavy`.
- [x] `profiles/arch/vm.nix`:
  - Software-GL for kitty (already in `home/kitty.nix`; move the wrapper into `vm.nix` or guard it so the native host does not get it unnecessarily).
  - `QT_QPA_PLATFORMTHEME=xdgdesktopportal` sioyek override from `lib/packages/media.nix`, behind a flag passed by the profile instead of `isLinux`.
  - Shared folder convention: `~/Projects` is a link to `/mnt/mac` (9p, `cache=readahead`). Keep databases and build caches off it.
  - Optional: `home.sessionVariables` for try-omarchy paths.
- [x] `home/ssh-key-paths.nix`, `ssh-aliases.nix`: add `Omarchy-Mini`.
- [x] Flake: it appears in `homeConfigurations` and the per-host tool output automatically.
- [x] Docs: extend `docs/arch-omarchy.md` with a "two hosts" section: native vs VM, what lives where.

Verify: `nix eval .#homeConfigurations.Omarchy-Mini.activationPackage.drvPath`. Compare package set with Omarchy-Air: only `vm.nix` differences should appear.

Risk: medium for the VM-flag design. Keep it simple: a profile that sets a few options, not a new mechanism.

Commit: `feat(nix): add Omarchy-Mini host`

### Step 6 – Minimal darwin profiles and trimmed Macs  `[x]`

Why: this is the actual footprint reduction on the Mac side.

- [x] `git mv profiles/darwin/configuration.nix profiles/darwin/base.nix`. Keep system defaults (Dock, Finder, keyboard, Touch ID sudo). I propose no changes to these.
- [x] `profiles/darwin/minimal.nix`: short brew list (D2), casks `orbstack` and `helium-browser` only, `cleanup = "zap"` kept, core HM roles only, short Nix package list: `ripgrep fd fzf jq bat eza just`, plus `home-manager`. (Not nvim LSPs etc.)
- [x] Move `modules/darwin/apps.nix` content into `profiles/darwin/minimal.nix` or trim in place. Keep `modules/darwin/apps.nix` filename if the diff stays smaller; the principle is that the Macs list is minimal.
- [x] `profiles/darwin/llm-host.nix`: imports the existing `modules/darwin/llama-*.nix` and `copilot-api.nix`, enables them, and holds the LLM brews (`llama.cpp`, `ollama`, `hf`, `llmfit`).
- [x] `Mac-Minicore`: `darwin/base`, `darwin/minimal`, `darwin/llm-host`. Keep the Fn to Right Option mapping inline.
- [x] `Macbook-Airborne`: `darwin/base`, `darwin/minimal`, copilot-api only (as today). Drop `macchanger` tap and brew, `dropbox`.
- [x] Remove virby: delete the `virby` input and `modules/darwin/virby.nix` content, and drop the virby cachix substituter. **Keep Determinate Nix**: move `determinateNix` and `determinate.darwinModules.default` into `modules/darwin/determinate.nix` (imported by both Macs), because both live in the same file today. Check that `nix.enable = false` in `base.nix` still holds. Only `Macbook-Airborne` imports `virby.nix` today; `Mac-Minicore` does not, so Minicore has no Determinate module config. Decide whether Minicore gets `determinate.nix` too (default: yes, for consistency, after verifying it evaluates).
- [x] Move Mac-removable tools to the Omarchy hosts per the brew triage table (hunk, ketch, linecast, llm, nmap, rename, tree-sitter, yt-dlp) via `lib/packages/arch.nix` or `roles/heavy/dev-tools`.
- [x] Remove Mac-only entries from `flake.nix` special args if nothing uses them (`pimalaya` is built for every host in `mkSpecialArgs`; with mail moved to Arch only, evaluate lazily or per-system).

Verify:

- Eval both Macs.
- `nix build .#darwinConfigurations.<host>.system` and compare `nix path-info -S` against the baseline (record before editing).
- `darwin-rebuild build` (no switch) first.

Risk: medium. Main hazards:

- `homebrew.onActivation.cleanup = "zap"` really removes apps and their data (Obsidian, Quarto, Zoom, Google Drive, etc.) when switched. Zotero data is already gone and Transmission has moved to Proxmox. The Obsidian vaults must be moved out of the app's reach first (step 8). Step 8 checks data before step 7 runs.
- `pi` and other tools install into `~/.npm-global` via `NPM_CONFIG_PREFIX`; dropping `node` from Nix and brew removes the runtime that `copilot-api` (launchd on Minicore and Airborne) needs. WARN: keep `node` on both Macs while `copilot-api` runs there, or move it to Nix. Update D2 accordingly: **keep `node`**.

Commit: `refactor(darwin): minimal profile and llm-host profile`

### Step 7 – Switch the Macs and reclaim the Nix store  `[ ]`

Run only after steps 5 and 6 are verified, step 8a (Obsidian move) is done, and the Omarchy-Mini VM is up (step 9). The heavy tools must exist in the VM before they leave the Mac.

- [ ] Record: `df -h /`, `du -sh /nix`, `brew list --cask`, `brew list`.
- [ ] `darwin-rebuild build --flake .#Mac-Minicore`, then `sudo darwin-rebuild switch ...`. Repeat on Airborne.
- [ ] `nix-collect-garbage -d` (system). On the Mac, old generations of `/nix/var/nix/profiles/system` and the home-manager profile pin much of the store.
- [ ] `brew cleanup --prune=all`.
- [ ] Record the same numbers after.

Expected: the Nix Store volume drops from 94 GB. The exact figure depends on how many generations pin it, so measure it rather than guess.

Rollback: `sudo darwin-rebuild --rollback` or `darwin-rebuild switch --switch-generation N`. Cask removals are not reversible by generation; they are reversible by reinstall, and any local-only data lost to `zap` is not.

### Step 8 – Move data, audit, shrink the Data volume  `[ ]`

Why: the VM disk is a one-way cap, and the container is 494 GB with 92 GB free. After the Nix store and the audit below, there must be roughly the VM cap (300 GB) plus a buffer for new LLM models free before step 9.

Free-space target before step 9: about 300 GB for the sparse image, plus a model buffer (about 30–50 GB), plus a safety margin. That is about 200 GB more than today.

**8a. Obsidian (do this first; it is a precondition for step 7).**

- [ ] Quit Obsidian. Confirm both vaults are clean git repos: `git -C ~/Obsidian/Notes status`, `git -C ~/Obsidian/Personal status`, and push if needed. They are restorable from the remote as you said.
- [ ] `mv ~/Obsidian ~/Projects/obsidian`. Inside it the vaults are `notes/` and `personal/` as you described. WARN: current folders are `Notes/` and `Personal/` (capital letters). The macOS filesystem is case-insensitive, so `mv` will not rename them. Decide whether the target is `Notes/Personal` or lowercase, then be consistent below.
- [ ] Update references to `~/Obsidian/...`: `home/shell/aliases.zsh` (`on`, `op`) and `home/tmux.nix` (weekly-note popup, two paths). Point them at `~/Projects/obsidian/...`. Same path works in the guest because `~/Projects` is the shared folder.
- [ ] Update any nvim config that references `~/Obsidian` (check `~/.config/nvim`; the earlier grep found none in tracked Nix files but did not search Lua).
- [ ] Leave `.obsidian/` (plugin state) with each vault; that is why the app should not run during the move.

Rationale for `~/Projects`: it is the single shared folder, so notes appear on both OSes. Vaults are plain Markdown plus git, which works over 9p `cache=readahead`. Obsidian's own indexing and any SQLite/WAL state would not, so open the vault from macOS only (the cask is dropped anyway) and edit from Omarchy with nvim.

**8b. Zotero.**

- [ ] Data is already removed. The app is removed by the cask drop in step 6/7. Nothing else to do.

**8c. Audit.**

- [ ] `sudo du -xhd1 /System/Volumes/Data | sort -h` to find the roughly 245 GB not accounted for. Likely candidates: `~/Library` (Application Support, Caches, Containers, Group Containers), `~/.cache`, Photos/Music libraries, Xcode (`/Applications/Xcode.app` plus `~/Library/Developer`), Time Machine local snapshots, OrbStack data, Homebrew cache. Known big items: `~/.llama/models` 44 GB (keep), `~/Projects` 9 GB (stays, it is the share).
- [ ] `tmutil listlocalsnapshots /` and `tmutil deletelocalsnapshots <date>` as needed.
- [ ] iCloud: turn off Desktop/Documents sync and "Optimize Mac Storage", then remove `~/Library/Mobile Documents` local copies (4.8 GB). Confirm everything is in iCloud first.
- [ ] Google Drive: sign out in the app and remove the app (the cask drop does this) and `~/Library/CloudStorage` (0.24 GB). `home/shell/repo.zsh` and `aliases.zsh` (`gdrive`) reference Drive; remove or retire those helpers.
- [ ] `~/.cache/huggingface` (13 GB): the llama scripts use explicit model paths, so this is only a download cache. Remove it after checking `hf` does not need it for pending downloads. `~/.ollama` (11 GB): keep if you use ollama; otherwise remove.
- [ ] Xcode.app and Apple apps (Pages, Numbers, Keynote, GarageBand, Office): optional big wins. Not Nix-managed, so remove manually.

Do not delete anything here without a backup check. Record each decision and the free space after.

### Step 9 – Install try-omarchy and bring up Omarchy-Mini  `[ ]`

- [ ] Download the `.dmg` from `omacom/try-omarchy` Releases and install. Requires Apple Silicon and macOS 15+.
- [ ] First launch downloads the image (about 3 GB).
- [ ] In **Resources → Configure…**: set disk to 300 GB or more (cannot shrink, so confirm free space first), memory 6 GiB to start (8 GiB ceiling; see section 3a), cores 4–6 (the M4 has 10; the llama servers are GPU-bound, so CPU is available).
- [ ] Optional: store the VM on an external APFS drive if internal space is short. The VM drive must be APFS, and the drive must stay attached while it runs.
- [ ] Inside Omarchy:
  1. `omarchy update`.
  2. Install Nix with the Determinate installer.
  3. Clone dotfiles into `~/.dotfiles` on the **guest** disk (not the shared folder). Keep the Nix store and `.git` of heavy repos on the guest disk; `~/Projects` repos work but 9p is slower for large trees.
  4. `home-manager switch --flake ~/.dotfiles/.config/nix#Omarchy-Mini`.
  5. Install and log in to Tailscale. Omarchy-Mini appears as its own node on the tailnet, separate from Mac-Minicore. Test reaching the llama servers at `100.101.38.4:8080/8081/8082` from the guest.
  6. Generate SSH keys and register public keys (see `ssh-key-paths.nix` header).
- [ ] Set the shared folder to `/Users/jeridf/Projects` in the launcher. The guest mounts it at `/mnt/mac` and links `~/Projects`. Verify `findmnt -n -t 9p -o SOURCE,TARGET,OPTIONS /mnt/mac` shows `cache=readahead`.
- [ ] Run the memory measurement from section 3a with the three llama servers up.

Notes:

- **Sparse image does not shrink.** Deleting files in the guest does not return space to macOS unless TRIM/discard is passed through. Check with `fstrim -v /` in the guest and `du` on the image on the host. If discard is not honoured, the image only grows. Treat the 300 GB cap as a one-way commitment, and keep the guest Nix store trimmed (`nix-collect-garbage`, `nix store optimise`).
- Nix store inside the guest will duplicate a few packages that exist in the Mac store. That is expected; the Mac store is shrinking.

### Step 10 – Docs and cleanup  `[ ]`

- [ ] Update `README.md` host table, layout tree, and the Arch/Omarchy section for two hosts.
- [ ] Update `docs/arch-omarchy.md`: "two hosts" section, `native` vs `vm`.
- [ ] Remove any now-unused inputs (`nix-flatpak` is still used by Mini-Rover; `virby` and `determinate` per step 6).
- [ ] Review `home/shell/*.zsh` for Mac-only helpers on the Arch hosts. Optional follow-up.
- [ ] Squash or rebase the branch if you want a clean history before merge.

## 8. Risks

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| `zap` deletes app data (Obsidian, Quarto, Google Drive) | Medium | Medium | Obsidian vaults move to `~/Projects/obsidian` and are git repos (8a); `brew list` snapshot before step 7. Zotero data and Transmission are already handled. |
| VM takes memory the LLM working set needs | High if sized to 10 GiB | High | Start at 6 GiB, ceiling 8 GiB, measure (section 3a). A Metal OOM wedges every later request until the server restarts |
| Dropping `node` breaks `copilot-api` launchd service | High if unaddressed | Medium | Keep `node` on both Macs (Step 6 note) |
| VM disk cap too big or too small | Low | Medium | Cannot shrink. Macs will not grow much after the switch (you confirmed), so 300 GB is a safe cap if the audit frees the space; leave a 30–50 GB buffer for new models |
| Guest disk never gives space back | Medium | Medium | Verify TRIM before relying on it; keep guest trimmed |
| Refactor changes Mini-Rover accidentally | Low | High | Drv hash compared at every step; Mini-Rover host lists its own modules |
| SSH key nickname rename breaks git remotes | Medium | Low | Accepted: generate new keys if it breaks. Default still keeps the `omarchy` nickname for Omarchy-Air. |
| Virby removal drags Determinate Nix out with it | Medium | High | They share one file today (`modules/darwin/virby.nix`). Split it so `determinateNix` is preserved; keep the removal in its own commit |
| `Omarchy-Air` and `Omarchy-Mini` diverge over time | Medium | Low | Intentional. Shared roles/profiles carry the common base; each host has its own `local.nix` for hand tweaks |
| try-omarchy limitations (no Vulkan, CPU video decode) | Certain | None | Accepted. No video-heavy apps, and the GPU is for the macOS LLM servers |

## 9. Ordering rationale

Execution order is **1, 2, 3, 4, 5, 6, 8, 9, 7, 10**. Step numbers are kept stable for reference; step 7 runs late on purpose.

1. Steps 2–5 (Arch side) come first because they add capability without removing anything, and every one is verifiable by eval.
2. Step 6 builds the Mac minimal profile but does not switch it.
3. Step 8 (data move and audit) precedes the VM install because the VM disk cap is irreversible and needs the free space to exist. Within it, 8a (Obsidian move) is the one data step that must precede step 7.
4. Step 9 brings up the VM and proves the Omarchy hosts have the tools.
5. Step 7 (the destructive Mac switch and garbage collection) runs only after the VM and its Nix environment work, so no tooling is lost before its replacement exists.

## 10. Execution checklist

- [x] 1. Remove `nixos-quattro` and dead sway/i3
- [x] 2. Arch package list to `lib/packages/arch.nix`; per-host tool outputs
- [x] 3. Rename `omarchy` to `Omarchy-Air`
- [x] 4. Roles extraction and Arch profile split (4a–4d)
- [x] 5. Add `Omarchy-Mini`
- [x] 6. Minimal darwin profiles; trim both Macs (D1 default taken: kitty via Nix)
- [ ] 8. Move Obsidian; audit Data volume; remove iCloud/Drive copies (run before 9)
- [ ] 9. Install try-omarchy; bring up `Omarchy-Mini` (run before 7)
- [ ] 7. Switch Macs; garbage collect (run after 9)
- [ ] 10. Docs and cleanup
