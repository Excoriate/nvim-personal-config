---
task_id: 2026-05-11-001
title: neo-hacker — security/trust-boundary receipt
type: review
status: complete
agent: neo-hacker
summary: 13 findings. Dropbox-resident config is a P0 cross-machine code-execution channel; lazy.nvim bootstrap has no commit/host pinning (MITM-on-first-run); Mason+TSUpdate install ~40+ unsigned binaries/parsers from upstream URLs; backup directory is mode 0755 (group/other-readable) and stores plugin state that may carry tokens; nvim-rollback can re-point ~/.config/nvim to attacker-controlled paths via tampered .symlink record; sync uses non-zero-exit-swallowing `|| true` over Mason; bash scripts call git/nvim/rsync/awk/find/sed without absolute paths (PATH injection); DAILY_DRIVER_NONINTERACTIVE=1 is parsed from raw environment with no allowlist; vim.deprecate filter is set late (post-plugin-load possible) and uses prefix-match exploitable by colliding plugin symbol names; vim.ui.input/select bindings are silently re-overridable by any later-loading plugin; bench/health scripts use predictable /tmp paths with no mktemp -d. Verdict: VULNERABLE on a personal-trust-model basis; HARDENED requires commit pinning, mode-0700 backups, $PATH lockdown, and an integrity check between Dropbox-resident bytes and what nvim actually loads.
---

# EXPLOIT DOSSIER: nvim-personal-config (Dropbox-resident + lazy.nvim + Mason)

**Assessment Type**: Security / Trust-Boundary Architecture Review
**Scope**: Standard
**Threat Model**: Personal developer workstation (macOS), single-user, no team adversary; primary adversaries are (1) anything that gains write access to one of the user's other Dropbox-synced machines, (2) network MITM on a hostile network (cafe / hotel / compromised router), (3) upstream supply-chain compromise of GitHub / npm / cargo / Homebrew taps, (4) opportunistic code in Mason-installed binaries / Treesitter parsers.

---

## 1. Attack Surface Map

### 1.1 Trust Boundaries

| # | Boundary Crossing | Trust Δ | Validation | Critical Gap |
|---|------------------|---------|------------|--------------|
| TB-1 | Dropbox cloud → `~/Dropbox/@GITHUB/@oss/nvim-personal-config/` | external mutable storage → local exec | NONE (no signing, no hash check, no readonly check) | Any other machine logged into the same Dropbox account can rewrite `init.lua` and the next `nvim` launch executes it |
| TB-2 | `~/.config/nvim` → Dropbox path (symlink) | local FS → Dropbox-synced bytes | NONE (symlink target is trusted blindly) | Symlink is itself a TOCTOU: bytes on disk at `init.lua` open time ≠ bytes Dropbox started syncing |
| TB-3 | `github.com/folke/lazy.nvim.git` → local clone (init.lua:44) | network → local exec | `--branch=stable` only; no commit SHA pin, no GPG, no TLS pinning beyond system trust store | First-run MITM, DNS spoof, or compromised mirror = arbitrary Lua-on-startup |
| TB-4 | lazy-lock.json (pinned SHAs) → 67 plugin git remotes | network → local exec | SHA pinning IS present in lock; BUT `Lazy! sync` (nvim-sync.sh:29) will move past lock for unpinned/new plugins | Mid-supply-chain attack: a plugin pushes a malicious commit before lock is refreshed |
| TB-5 | Mason registry → `~/.local/share/nvim/mason/bin/*` (~40 tools) | network → local exec (LSP servers run with user privs) | npm/cargo/pip/go upstream registries; no SBOM, no checksum verification by Mason | Compromised npm package (`typescript-language-server`, `eslint_d`, `bash-language-server`) runs in user context on every relevant filetype open |
| TB-6 | nvim-treesitter parser registry → compiled .so | network → local code-gen → local exec | git URLs + local cc compile; no signature | Grammar registry takeover or PR-poisoning compiles arbitrary C into a .so loaded by nvim on filetype detect |
| TB-7 | `BACKUP_ROOT` (`~/.local/state/nvim-personal-config/backups/`) → restore path | local FS → restored symlink target | `nvim-rollback.sh` parses `.symlink` file and re-creates symlink to whatever path is recorded | Anyone who can write a `.symlink` line under `BACKUP_ROOT` controls where `~/.config/nvim` points after the next `just rollback` |
| TB-8 | Environment (`DAILY_DRIVER_NONINTERACTIVE`, `BACKUP_ROOT`, `XDG_*`, `MASON_SYNC_TIMEOUT_SECONDS`, `PATH`) → script behavior | shell env → control flow | All read as `${VAR:-default}`; no allowlist, no canonicalization | Sourced `.envrc` / leaked CI env / forgotten shell export silently flips destructive auto-confirm or relocates backup root |
| TB-9 | `vim.deprecate` global → suppression filter (init.lua:25-38) | nvim core → installed-plugin call site | Prefix-string match against `_suppressed_prefixes` | Any plugin loaded BEFORE init.lua finishes (theoretical) OR a plugin whose deprecate `name` argument starts with `client.supports_method` can silently hide its own deprecation/security warnings |
| TB-10 | `vim.ui.input` / `vim.ui.select` → snacks (polish.lua:226-227) | core UI surface → plugin override | Idempotent overwrite; NO write-protection after binding | Any plugin loaded later (or any `:lua` command, or a malicious plugin opts.config) can re-overwrite these to functions that exfiltrate user input |

### 1.2 Ingress Points (where untrusted data enters)

| Ingress | Surface | Trust Level |
|---------|---------|-------------|
| Dropbox sync daemon | Bytes under `~/Dropbox/@GITHUB/@oss/nvim-personal-config/**` | UNTRUSTED (any other-machine compromise = write here) |
| GitHub clone of lazy.nvim (first run) | `~/.local/share/nvim/lazy/lazy.nvim/**` | UNTRUSTED on first run, pinned-via-lock after |
| Plugin git remotes (lazy.nvim sync) | 67 git repos (`lazy-lock.json`) | SEMI-TRUSTED (lock pins commits; `Lazy! sync` can advance) |
| Mason install URLs | npm/cargo/pip/go/github releases | UNTRUSTED (no signature verify) |
| Treesitter parser URLs + cc | Grammar git repos compiled locally | UNTRUSTED (compile = arbitrary code) |
| `~/.local/state/.../backups/*/config-nvim.symlink` | Plain text symlink record | TRUSTED by `nvim-rollback.sh` (no validation) |
| Environment variables | `DAILY_DRIVER_NONINTERACTIVE`, `BACKUP_ROOT`, `XDG_*`, `PATH` | UNTRUSTED (process env) |

---

## 2. Findings

### F-1 — Dropbox-resident config = cross-machine code execution channel  [P0 / CRITICAL]

**Classification**: FACT (evidence) + INFER (impact)
**CWE**: CWE-732 (Incorrect Permission Assignment), CWE-426 (Untrusted Search Path), CWE-672 (Use of a Resource after Expiration or Release)
**MITRE**: T1546 (Event Triggered Execution), T1195.002 (Supply Chain Compromise: Compromise Software Supply Chain), T1080 (Taint Shared Content)

**Evidence**:
- `~/.config/nvim -> /Users/alextorresruiz/Dropbox/@GITHUB/@oss/nvim-personal-config/nvim-config` (FACT, `ls -la ~/.config/nvim` confirmed)
- All Lua under the repo executes on `nvim` startup, with user privileges (FACT, `init.lua:63 require "lazy_setup"`)

**Kill Chain — KC-1: Other-machine compromise → daily-driver RCE**

| Step | Precondition | Action | Mechanism | Postcondition | Detection |
|------|-------------|--------|-----------|---------------|-----------|
| 1 | Attacker has write access to ONE other machine logged into the same Dropbox account (compromised laptop, lost iPad, malware on an iOS device with Dropbox app, shared family Mac, work machine with Dropbox business + same personal account) | Append a payload to `nvim-config/init.lua` OR drop a new file under `nvim-config/lua/plugins/` that gets auto-imported (no payload needs to touch the primary machine) | Dropbox syncs the malicious bytes to `~/Dropbox/@GITHUB/@oss/nvim-personal-config/nvim-config/` on the primary machine | Malicious Lua on disk at the path the symlink targets | NONE (Dropbox treats this as a normal file sync; no syscall hooks; macOS file events do not differentiate user-edit vs sync-write) |
| 2 | Step 1 complete | User runs `nvim` (any reason — open `.txt`, open project, vscode-neovim) | `init.lua` is executed; `lazy_setup.lua` is required; plugin imports are walked | Arbitrary attacker code runs as the user (read shell history, ssh keys, `~/.config/`, browser tokens, exfiltrate via DNS or HTTPS to any host) | NONE (no integrity check; no hash compare; no AppArmor/SELinux on macOS) |
| 3 | Step 2 complete | Payload writes a LaunchAgent at `~/Library/LaunchAgents/` OR adds an ssh authorized_key OR drops a shell rc tail | macOS launchd reloads on login; ssh accepts new key | Persistence beyond nvim sessions | macOS XProtect may catch some signatures, not custom Lua-spawned shells |

**Blast Radius**:
- **DATA**: full `$HOME` read (ssh keys, GH tokens in `~/.config/gh`, AWS creds in `~/.aws`, browser cookie stores)
- **LATERAL**: every git remote with cached creds; every Dropbox-synced repo; the user's GitHub/AzureDevOps via cached tokens
- **PERSISTENCE**: LaunchAgents, shell rc files, `~/.local/bin/` shims — all reachable from user-level write
- **DETECTION**: NONE in the harness; relies on macOS XProtect / EDR if installed

**Counter-Hypothesis**: "Maybe Dropbox provides path-based protections." — REJECTED. macOS Dropbox client syncs as the logged-in user; there is no per-folder integrity policy. Selective Sync only controls what is downloaded, not how downloaded bytes are trusted.

**Mitigations (ranked by ROI)**:
1. **M-1a (P0, 5 min)**: Move the canonical config OUT of `~/Dropbox`. Keep the repo as a regular `git` clone under `~/code/` or `~/.config/nvim-personal-config-src/`. Use git remote (private GitHub repo) for cross-machine sync. Blocks KC-1 entirely.
2. **M-1b (P1, 30 min, if Dropbox must stay)**: Set Dropbox Selective Sync to NOT sync this folder on every machine except one "authoring" machine. On non-authoring machines, the folder doesn't exist locally, so an attacker compromising those machines has no write surface. Reduces KC-1 to "must compromise the authoring machine."
3. **M-2 (P1, 1 h)**: Add an integrity-check hook to `init.lua` step 1: SHA-256 the loaded files, compare against a list checked into the repo (chicken-and-egg solved by storing the hash list outside Dropbox, e.g. `~/.config/nvim-integrity/manifest.sha256`, rotated by a justfile recipe). Mismatch → abort startup with a banner.
4. **M-3 (P2, 15 min)**: `chflags uchg` (immutable) on `init.lua` + `lazy_setup.lua` between intentional edits. Dropbox sync of those specific files will fail; user is forced to consciously unlock before editing.

**Residual after M-1a**: KC-1 is closed. Residual = TB-3..TB-6 (network supply chain) still apply but no longer have a free cross-machine channel.

---

### F-2 — lazy.nvim first-run clone has no commit pinning + no host pinning  [P1 / HIGH]

**Classification**: FACT
**CWE**: CWE-494 (Download of Code Without Integrity Check), CWE-295 (Improper Certificate Validation — system trust only)
**MITRE**: T1195.001 (Compromise Software Dependencies and Development Tools), T1557 (Adversary-in-the-Middle)

**Evidence**: `nvim-config/lua/lazy_setup.lua:44` — `git clone --filter=blob:none https://github.com/folke/lazy.nvim.git --branch=stable <lazypath>`
- No `--config tag.gpgSign=true`
- No commit SHA constraint (`--branch=stable` resolves at clone time to whatever HEAD `stable` points at)
- No TLS pinning; relies entirely on system CA store

**Kill Chain — KC-2: First-run MITM → bootloader compromise**

| Step | Precondition | Action | Mechanism | Postcondition |
|------|-------------|--------|-----------|---------------|
| 1 | User on a hostile network (cafe, hotel, hostile DNS, captive portal with cert injection, corporate MITM proxy where the user has installed the proxy CA) AND `~/.local/share/nvim/lazy/lazy.nvim` is absent (fresh install or a `rm -rf ~/.local/share/nvim` reset) | User runs `nvim` | `vim.fn.system({"git","clone",...})` resolves `github.com` over MITM-controlled DNS; the attacker's reverse proxy serves a malicious lazy.nvim with their HTTPS leaf cert (trusted because corp CA is installed, or because user accepted captive-portal interstitial) | Malicious lazy.nvim Lua is on disk |
| 2 | Step 1 complete | nvim continues startup, `pcall(require, "lazy")` succeeds | Malicious `lazy.setup()` runs; can hijack subsequent plugin loads, exfiltrate, set up persistence | Long-term implant |

**Blast Radius**: Same as F-1.
**Detection Blindspot**: `vim.v.shell_error` only checks `git clone` exit code, not commit SHA. The harness has no out-of-band record of "the expected lazy.nvim commit."

**Mitigations**:
- **M-4 (P1, 15 min)**: Pin lazy.nvim to a commit SHA. After clone, `git -C <lazypath> rev-parse HEAD` MUST equal a SHA hard-coded in `lazy_setup.lua` (constant) or in a sibling `lazy-bootstrap.sha` file. Mismatch → abort.
- **M-5 (P2, 30 min)**: Pre-stage `lazy.nvim` checked into the repo as a git submodule (or vendored .zip with a known sha256). Skip the network clone entirely.
- **M-6 (P3)**: Don't run first-time `nvim` on untrusted networks. Operational hygiene only.

---

### F-3 — Mason installs ~40 binaries with no signature/checksum verification  [P1 / HIGH]

**Classification**: FACT (Mason behavior is documented; mason-tool-installer wraps it) + INFER (impact)
**CWE**: CWE-494, CWE-829 (Inclusion of Functionality from Untrusted Control Sphere)
**MITRE**: T1195.002

**Evidence**: `nvim-config/lua/plugins/mason.lua` lists 30+ ensure_installed tools (`typescript-language-server`, `eslint_d`, `bash-language-server`, `prettier`, `yamllint`, `cfn-lint`, `markdownlint`, `actionlint`, `mypy`, `hadolint`, …). Mason resolves these via its registry to upstream npm / cargo / pip / go / GitHub Releases URLs and downloads without per-artifact signature verification.

**Kill Chain — KC-3: Upstream package compromise → LSP-on-filetype RCE**

| Step | Precondition | Action | Mechanism | Postcondition |
|------|-------------|--------|-----------|---------------|
| 1 | Attacker compromises any of (a) an npm maintainer of `typescript-language-server` / `eslint_d`, (b) a cargo crate dependency of one of the rust-built tools, (c) an Action `*-lint` GitHub release artifact, or (d) the Mason registry repo itself | Publish malicious version that Mason picks up on next `just sync` | mason-tool-installer auto-upgrades unpinned tools | Malicious binary in `~/.local/share/nvim/mason/bin/` |
| 2 | User opens any matching filetype (`.ts`, `.sh`, `.yml`, `.md`) | nvim's LSP client spawns the Mason binary | Arbitrary code runs as the user, with the LSP's full filesystem access | RCE per filetype open |

**Blast Radius**: Same as F-1; one trigger is "open a markdown file" (markdownlint) or "edit a shell script" (bash-language-server, shellcheck) — extremely high-frequency triggers.

**Mitigations**:
- **M-7 (P1, 1 h)**: Pin Mason package versions explicitly. `mason-tool-installer` supports `{ "typescript-language-server", version = "4.3.3" }` form. Reduces "next sync silently upgrades to malicious" to "user has to consciously bump."
- **M-8 (P2, 2 h)**: Wrap Mason install with a post-install hook that verifies sha256 against a checked-in manifest (`mason-checksums.json`). Refuse to run binaries that don't match.
- **M-9 (P3)**: Reduce attack surface: drop tools you don't actually use. `vale`, `codespell`, `cfn-lint`, `taplo` are all rarely-triggered but every additional binary is one more compromise channel.

---

### F-4 — Backup root is mode 0755 (group/other-readable) on macOS  [P2 / MEDIUM]

**Classification**: FACT
**CWE**: CWE-732 (Incorrect Permission Assignment for Critical Resource), CWE-538 (Insertion of Sensitive Information into Externally-Accessible File or Directory)

**Evidence**: `ls -la ~/.local/state/nvim-personal-config/backups/` shows `drwxr-xr-x@`. macOS default umask 022 produces 0755. `nvim-backup.sh:14 mkdir -p "$BACKUP_DIR"` inherits umask.

**Why it matters here**:
- Backups contain `data-lazy/` (full plugin source) and `data-mason/` (LSP binaries, npm node_modules trees, pip caches).
- Several modern dev plugins persist tokens to `$XDG_DATA_HOME`. Examples seen in the wild:
  - `copilot.lua` / `copilot.vim` — GitHub Copilot OAuth tokens in `~/.config/github-copilot/hosts.json` (not in backup) but plugin state can include cached auth
  - `codecompanion.nvim`, `avante.nvim`, etc. — any plugin that caches API keys/tokens in its data dir
  - npm modules under mason can contain `.npmrc` with author tokens
- The backup is on a local single-user macOS box, so realistic adversaries are: (1) other local accounts on the machine, (2) Time Machine / cloud backup that picks up `~/.local/state/`, (3) a process running under a lower-privileged macOS service account, (4) an SSH-exposed share.

**Kill Chain — KC-4: Local read → token harvest**
1. Adversary process (any non-root, non-user UID) walks `~/.local/state/nvim-personal-config/backups/*/data-lazy/**/*.json`, `data-mason/packages/**/.npmrc`, `state-nvim/**/*.json`
2. Extracts any cached API tokens, OAuth refresh tokens, JWT credentials
3. Uses them outside the machine

**Mitigations**:
- **M-10 (P2, 30 sec)**: `chmod 0700 "$BACKUP_DIR"` after creation in `nvim-backup.sh`. Add a `umask 077` at the top of every script that writes to `~/.local/state/`. One-line change.
- **M-11 (P3, 5 min)**: Document explicitly: backups MAY contain plugin tokens; treat them as a credential blob; do not sync them to cloud backups without encryption.

---

### F-5 — `nvim-rollback.sh` re-creates symlink from attacker-controlled `.symlink` record  [P1 / HIGH]

**Classification**: FACT
**CWE**: CWE-61 (UNIX Symbolic Link Following), CWE-20 (Improper Input Validation)
**MITRE**: T1574.005 (Hijack Execution Flow: Executable Installer File Permissions Weakness)

**Evidence**: `scripts/nvim-rollback.sh:40-58` parses `$BACKUP_DIR/config-nvim.symlink` via awk on " -> " and uses the parsed path as `ln -s "$restore_target" "$DEST"` (line 88).

**Vector**: The parsing is robust to embedded `" -> "` (good) but performs ONLY existence (`-e`) check on the target. There is no:
- Path canonicalization (`realpath`)
- Allow-list check (e.g., target MUST be under `~` or under the repo)
- Ownership/permission check on the target
- Check that the `.symlink` file itself is owned by the user (any process that wrote to `BACKUP_ROOT` as the user is implicitly trusted)

**Kill Chain — KC-5: Backup tamper → daily-driver redirect**

| Step | Precondition | Action | Mechanism | Postcondition |
|------|-------------|--------|-----------|---------------|
| 1 | Adversary has write access under `$HOME/.local/state/nvim-personal-config/backups/` (any malware running as the user; Dropbox-sync from F-1 also reaches this path if state were ever symlinked into Dropbox — currently it is not, FACT verified) | Overwrite `config-nvim.symlink` in the newest timestamp dir to read `~/.config/nvim -> /tmp/attacker-nvim` | File is now poisoned | Pending |
| 2 | User runs `just rollback` (a routine operation) | Script accepts the path (it exists), prompts y/N | If user confirms (UX: they're rolling back to "their latest backup" — high trust) | `~/.config/nvim -> /tmp/attacker-nvim`; next nvim launch executes attacker init.lua |
| 3 | nvim launches | `init.lua` from `/tmp/attacker-nvim/init.lua` runs | RCE | Same as F-1 |

**Blast Radius**: Same as F-1.
**Detection Blindspot**: `rollback` prints the target before prompting, but a target like `/Users/alextorresruiz/.config/nvim-old` looks innocuous next to `/tmp/attacker-nvim-cache`.

**Mitigations**:
- **M-12 (P1, 10 min)**: Constrain `restore_target` to a known prefix. e.g. reject any target not under `${HOME}` AND not under `${REPO_ROOT}`. Add `realpath --canonicalize-existing` first.
- **M-13 (P2, 5 min)**: Verify `.symlink` file is mode 0600 and owner = current user before parsing.
- **M-14 (P3, 1 h)**: Sign the `.symlink` record with a minisign / age key kept in `~/.config/nvim-keys/` (outside Dropbox, outside the backup tree).

---

### F-6 — `nvim-sync.sh` swallows Mason failures with `|| true`  [P2 / MEDIUM]

**Classification**: FACT
**CWE**: CWE-754 (Improper Check for Unusual or Exceptional Conditions), CWE-390 (Detection of Error Condition Without Action)

**Evidence**: `scripts/nvim-sync.sh:44` — `nvim --headless +"lua vim.defer_fn(...)" +"sleep ${TIMEOUT_S}" +"qa" >"$MASON_LOG" 2>&1 || true`

The `|| true` defeats `set -euo pipefail`. The follow-up `grep -qE "(error|failed|❌)"` (line 46) is a string heuristic on the log; a Mason install that silently exits with code 1 but emits no matching string will be reported as success.

**Why it matters**: A partial Mason install means the LSP is missing, so the user sees a degraded experience (potentially silent: e.g. `eslint_d` not installed → eslint doesn't run → real bugs ship). It is not directly a security issue, BUT — if the failure pathway is "Mason download was tampered with and the partial install left a script in `~/.local/share/nvim/mason/staging/`," the script swallowing the exit code means the user never sees the warning.

**Mitigations**:
- **M-15 (P2, 5 min)**: Replace `|| true` with capture: `set +e; nvim --headless ...; rc=$?; set -e`. Treat `rc != 0` as warning AND log. Don't blanket-mute.
- **M-16 (P3, 30 min)**: Add a post-sync verification: `mason-tool-installer` exposes `MasonToolsCheck`; run it headlessly and exit non-zero if any expected tool is missing.

---

### F-7 — Scripts call `nvim`, `git`, `rsync`, `awk`, `find`, `sed`, `cp`, `mv` without absolute paths  [P2 / MEDIUM]

**Classification**: FACT
**CWE**: CWE-426 (Untrusted Search Path), CWE-427 (Uncontrolled Search Path Element)
**MITRE**: T1574.007 (Hijack Execution Flow: Path Interception by PATH Environment Variable)

**Evidence**:
- `nvim-backup.sh:25` — `rsync -a "$src/" "$BACKUP_DIR/$name/"`
- `nvim-sync.sh:21,29,42` — `nvim --headless +...`
- `nvim-rollback.sh:43,46,82,91` — `awk`, `find`, `bash`, `rsync`
- `nvim-theme.sh:54,61` — `sed -i.bak`, `awk`
- `nvim-doctor.sh:40` — `command -v "$tool"` (this one is fine, but the surrounding scripts are not)

Every one of these is `PATH`-resolved. The justfile sets `shell := ["bash", "-uce"]` (FACT) but does NOT set a hardened `PATH`. `dotenv-load := false` is good (FACT, line 3) but `PATH` is inherited from the invoking shell.

**Kill Chain — KC-6: PATH-priority shim hijack**

| Step | Precondition | Action | Mechanism | Postcondition |
|------|-------------|--------|-----------|---------------|
| 1 | Adversary drops `~/.local/bin/nvim` (or `~/bin/nvim`, or `/usr/local/bin/nvim` if mode allows) with `#!/usr/bin/env bash` + exfil payload + `exec /opt/homebrew/bin/nvim "$@"` | Files synced or dropped by any prior compromise (F-1, malicious npm postinstall, …) | `~/.local/bin` is earlier on PATH than `/opt/homebrew/bin` for typical user setups | Pending |
| 2 | User runs `just sync` or `just bench` or `just health` | Script resolves `nvim` via PATH | Adversary's wrapper runs, then chains to real nvim | RCE inside scripts; user sees normal output |

**Blast Radius**: Each script run is one trigger.

**Mitigations**:
- **M-17 (P2, 30 min)**: Add a hardened PATH at the top of every script: `export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"` (adjust for arm64 vs intel). One-line guard.
- **M-18 (P2, 1 h)**: Resolve each tool once at script entry: `readonly NVIM="$(command -v nvim)"` after a hardened PATH, then `"$NVIM" --headless ...`. Forces single resolution.
- **M-19 (P3, 30 min)**: justfile can pre-export `export PATH := "/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin"` at the top, so every recipe inherits it.

---

### F-8 — `DAILY_DRIVER_NONINTERACTIVE=1` accepts any truthy value with no allowlist  [P2 / MEDIUM]

**Classification**: FACT
**CWE**: CWE-15 (External Control of System or Configuration Setting), CWE-453 (Insecure Default Variable Initialization)

**Evidence**: `nvim-install.sh:56` — `if [[ "${DAILY_DRIVER_NONINTERACTIVE:-0}" != "1" ]]; then` — confirmation gated by string equality to `"1"`.

This is itself fine. The problem is the wider environment:
- No check that the env var was set intentionally vs leaked
- A user with `direnv` could have `DAILY_DRIVER_NONINTERACTIVE=1` set in a forgotten `.envrc` (e.g. from a CI mirror), then `just install` (the daily-driver flavor) skips the confirmation and silently clobbers `~/.config/nvim`.
- The destructive lexicon includes `rm -rf "$DEST"` (line 67) and `rm "$DEST"` (line 51) — both pre-gated on a `confirm` that the env var can disable.

**Kill Chain — KC-7: Env-leak → unattended destructive install**

| Step | Precondition | Action | Mechanism | Postcondition |
|------|-------------|--------|-----------|---------------|
| 1 | Adversary tricks user into sourcing a config or running `direnv allow` on a poisoned `.envrc` containing `export DAILY_DRIVER_NONINTERACTIVE=1` | Env var leaks into interactive shell | Bash inherits | Pending |
| 2 | User runs `just install` (the daily-driver path) for any reason | Script reads env var as truthy | Skips the y/N prompt | `~/.config/nvim` is replaced silently with the Dropbox symlink (or worse, with whatever the malicious script chains next) |

This is a small attack but it removes one of the few interactive guards. Combined with F-1, it removes the LAST line of defense between "Dropbox has malicious config" and "daily driver is silently swapped to it."

**Mitigations**:
- **M-20 (P2, 5 min)**: In `nvim-install.sh`, log the value of `DAILY_DRIVER_NONINTERACTIVE` when it bypasses; print "Bypass confirmed via env (set in: shell init? .envrc?)" so a misconfiguration is at least visible.
- **M-21 (P3, 15 min)**: Replace env-based bypass with a CLI flag (`--yes`/`-y`) that has to appear in the literal command line. Env vars are forgeable; argv is observable in shell history.

---

### F-9 — `vim.deprecate` filter is overridable AND prefix-matches names  [P3 / LOW]

**Classification**: FACT (mechanism) + INFER (exploitability is theoretical)
**CWE**: CWE-693 (Protection Mechanism Failure)

**Evidence**: `init.lua:25-38` — `vim.deprecate = function(name, ...)` with `name:find(prefix, 1, true) == 1` prefix match against `{"opts.jump.float", "client.supports_method"}`.

**Two concerns**:

1. **Override race**: The override is set DURING `init.lua` execution (line 31). Anything that runs BEFORE line 31 (e.g. a `runtimepath` plugin auto-sourced by Nvim's standard startup like `~/.config/nvim/plugin/*.lua` if any exist, or a `--cmd` from a wrapper) cannot be filtered. More importantly, ANY plugin that loads later and re-assigns `vim.deprecate` (e.g. a plugin author who wants their own filter) wins. There is no `vim.api.nvim_set_var` lock.

2. **Prefix collision**: `name:find("client.supports_method", 1, true) == 1` means ANY deprecate call whose name starts with that literal is suppressed. The `.` in `client.supports_method` is a literal dot here (plain mode, `true`), but the name is matched at position 1, so a maliciously crafted deprecate call from a compromised plugin could embed the prefix to silently suppress legitimate deprecation warnings about its own behavior. Example: a plugin calls `vim.deprecate("client.supports_method.evil_internal_API", ...)` and it never shows.

**Blast Radius**: LOW directly. The risk is loss-of-signal — deprecation warnings are the user's early-warning for plugin EOL, not a security control. But if a malicious plugin wants to hide telemetry-shaped warnings, this gives it a free channel.

**Mitigations**:
- **M-22 (P3, 5 min)**: Use exact-string equality + an explicit allow-list set (`local SUPPRESSED = { ["opts.jump.float"] = true, ["client.supports_method"] = true }; if SUPPRESSED[name] then return end`). No prefix-match. Removes the collision channel.
- **M-23 (P3, 15 min)**: After installing the filter, freeze it: `setmetatable(vim, { __newindex = function(_, k, _) if k == "deprecate" then error("vim.deprecate is sealed") end end })` — caveat: this fights upstream patches; tradeoff is real. Document and revisit.

---

### F-10 — `vim.ui.input` / `vim.ui.select` rebinding is silently re-overridable  [P3 / LOW]

**Classification**: FACT
**CWE**: CWE-829 (Inclusion of Functionality from Untrusted Control Sphere), CWE-862 (Missing Authorization)

**Evidence**: `nvim-config/lua/polish.lua:225-227` — `vim.ui.input = snacks.input.input; vim.ui.select = snacks.picker.select` — set unconditionally, NOT protected.

**Vector**: `vim.ui.input` is the canonical surface for any plugin that prompts the user (rename input, commit messages, search-and-replace patterns, secret prompts). A plugin that loads AFTER `polish.lua` (lazy-loaded on an event like `BufRead`) can re-assign `vim.ui.input = function(opts, on_confirm) ... end` and now sees every prompt's contents.

Realistic threat: a compromised plugin (per F-3 or F-1) wraps `vim.ui.input` to exfiltrate input. Because the harness has NO post-binding sentinel, the user never notices.

**Mitigations**:
- **M-24 (P3, 15 min)**: Add a periodic checker (autocmd on `User VeryLazy` and on `User LazyDone`) that asserts `vim.ui.input == snacks.input.input` and either re-binds with a warning notification, or actively refuses with a banner.
- **M-25 (P3, 30 min)**: Wrap the assignment with a sealed local: bind a captured-upvalue wrapper that ignores subsequent assignment via metatable. Same caveat as M-23 — fights legitimate overrides; acceptable for personal config.

---

### F-11 — `lazy-lock.json` is regenerated by `Lazy! sync`, not just restored  [P2 / MEDIUM]

**Classification**: FACT
**CWE**: CWE-1357 (Reliance on Insufficiently Trustworthy Component)

**Evidence**: `nvim-sync.sh:21,29` runs `Lazy! restore` first (good — pins to lock), THEN `Lazy! sync` (which advances unpinned/new entries and writes the lock). Then `nvim-update-lock.sh` propagates the lock back to the repo.

**Issue**: If a malicious plugin is added to a spec (e.g. via F-1), the very next `just sync` will:
1. Restore everything pinned (fine)
2. Walk the spec, see the new entry, clone its remote, and silently advance lazy-lock.json
3. `nvim-update-lock.sh` commits the new SHA to the repo as if it were authorized

The lock is a SHA-after-the-fact record, not a SHA-before-the-fact authorization. There's no allowlist of permitted repos.

**Mitigations**:
- **M-26 (P2, 1 h)**: Maintain `plugin-allowlist.txt` = set of allowed `owner/repo` strings. Pre-sync hook diffs current spec against allowlist. Refuse to sync if a non-allowlisted plugin appears.
- **M-27 (P3, 30 min)**: Replace `Lazy! sync` in `nvim-sync.sh` with `Lazy! restore` only; force the user to consciously run `:Lazy update` to advance plugins. Removes "silently advance on sync" path.

---

### F-12 — Treesitter parsers compile arbitrary C from network sources  [P2 / MEDIUM]

**Classification**: FACT (mechanism is documented), INFER (no specific compromised parser found)
**CWE**: CWE-829, CWE-78 (Improper Neutralization of Special Elements used in an OS Command) — indirect via compiler
**MITRE**: T1195.001

**Evidence**: nvim-treesitter is in the dependency tree (referenced by `gopher.nvim` `nvim-config/lua/plugins/user.lua:209`); AstroNvim default. Parser install path: `:TSInstall <lang>` → clone grammar repo → run `cc` → load `.so` into nvim.

**Kill Chain — KC-8**:
1. Attacker compromises a Treesitter grammar repo (or its registry entry in nvim-treesitter)
2. User opens a file of that filetype
3. nvim auto-installs if `ensure_installed` includes it, OR the user runs `:TSUpdate`
4. `cc` compiles attacker-controlled C; arbitrary code at compile time + when `.so` is loaded

**Mitigations**:
- **M-28 (P2, 1 h)**: Pin parser revisions via `nvim-treesitter` `ensure_installed` config OR vendor compiled `.so` files in the repo and disable runtime compilation.
- **M-29 (P3)**: Disable auto-install; require manual `:TSInstall` only when consciously needed.

---

### F-13 — `/tmp` file races in bench + sync scripts  [P3 / LOW]

**Classification**: FACT
**CWE**: CWE-377 (Insecure Temporary File), CWE-378 (Creation of Temporary File With Insecure Permissions)

**Evidence**:
- `nvim-bench.sh:18` — `LOG="$(mktemp /tmp/nvim-startup.XXXXXX.log)"` — `mktemp` is fine (template); BUT the file is then read and printed without permission tightening.
- `nvim-sync.sh:19,40` — `mktemp -t "nvim-sync-lazy.XXXXXX"` and `mktemp -t "nvim-sync-mason.XXXXXX"` — these go to `$TMPDIR` (macOS per-user `/var/folders/...`) which is mode 0700; this is fine on macOS but the script doesn't enforce it.
- `nvim-health.sh:7` — `OUT_DIR="${OUT_DIR:-/tmp/nvim-health-$APPNAME}"` — fixed predictable path under `/tmp` (NOT `$TMPDIR`); `mkdir -p` will use existing dir if present; another process could pre-create it as a symlink to a different path. CWE-59 (Improper Link Resolution Before File Access).

The health-log path is the most exploitable: a non-privileged process pre-creates `/tmp/nvim-health-nvim-pristine` as a symlink to `~/.ssh/`, then `nvim --headless -c "write! $LOG"` writes nvim's checkhealth output INTO a path that, depending on symlink semantics, could clobber a user file.

**Mitigations**:
- **M-30 (P3, 10 min)**: Replace `OUT_DIR=/tmp/...` with `OUT_DIR="$(mktemp -d -t nvim-health.XXXXXX)"` (macOS auto-routes to `$TMPDIR`).
- **M-31 (P3, 5 min)**: Add `umask 077` at the top of every script.

---

## 3. STRIDE Roll-Up (selected, per top-3 findings)

### F-1 (Dropbox symlink) STRIDE

| Threat | Surface | Control | Status |
|--------|---------|---------|--------|
| S — Spoofing | Other-machine identity → Dropbox writer | Dropbox account = identity | TRUSTED to Dropbox; NO secondary signing |
| T — Tampering | `init.lua` bytes on disk | NONE | ABSENT — exploitation primary |
| R — Repudiation | Who wrote the malicious commit? | Dropbox metadata (which device) | PRESENT but post-hoc; not a control |
| I — Information Disclosure | nvim post-exec exfiltrates | NONE | ABSENT |
| D — Denial of Service | Sync churn could break startup | None | LOW concern |
| E — Elevation of Privilege | User-level → persistent user-level | Limited (no priv escalation needed) | Trivial via LaunchAgents |

### F-2 (lazy.nvim clone) STRIDE — same shape, host validation gap.

### F-5 (rollback symlink) STRIDE

| Threat | Control |
|--------|---------|
| Tampering on `.symlink` file | NONE (no signature, no ownership check) |
| Elevation | Effective E-of-P: from "can write backup dir" → "controls daily-driver init.lua" |

---

## 4. Attacker ROI Summary

| Finding | Skill | Time | Access Required | Tooling | Detection | Impact | Priority |
|---------|-------|------|----------------|---------|-----------|--------|----------|
| F-1 Dropbox channel | Competent | Minutes (post-access) | Other-machine writer on same Dropbox account | Text editor | STEALTH | Full $HOME RCE on every primary-machine boot | P0 |
| F-2 lazy.nvim MITM | Advanced (needs MITM position) | Hours | Hostile network position OR corp MITM proxy + user trust of CA | mitmproxy / ettercap | STEALTH (first install only) | First-run RCE on bootstrap | P1 |
| F-3 Mason upstream | Nation-State / Insider | Weeks-Months | npm maintainer compromise OR Mason registry PR | Standard supply chain | Public CVE eventually | RCE on filetype open | P1 |
| F-4 Backup perms | Local attacker | Minutes | Read on machine | Standard | NONE | Token harvest | P2 |
| F-5 Rollback redirect | Competent | Minutes | Write to backup dir | Text editor | LOW (visible in prompt) | RCE on next rollback | P1 |
| F-6 sync `\|\| true` | n/a — not direct | n/a | n/a | n/a | Masks symptoms | Loss of signal | P2 |
| F-7 PATH injection | Competent | Minutes | Drop a shim | bash | LOW | RCE per script run | P2 |
| F-8 NONINTERACTIVE env | Competent | Minutes | Trick user to source envrc | Standard | LOW | Removes interactive guard | P2 |
| F-9 deprecate filter | Advanced | Plugin compromise required | F-3 chain | n/a | NONE | Loss of signal | P3 |
| F-10 vim.ui.* rebind | Competent | Plugin compromise required | F-3 chain | n/a | NONE | Input exfil | P3 |
| F-11 lock advance | n/a — config drift | Hours | Spec edit | Editor | LOW | Silent supply chain | P2 |
| F-12 TS parsers | Advanced | Weeks | Grammar repo PR | Standard | Eventually CVE | RCE on filetype | P2 |
| F-13 /tmp race | Local attacker | Minutes | Local non-root | Standard | LOW | File overwrite | P3 |

---

## 5. Detection Blindspots

| Channel | Current Logging | Gap |
|---------|----------------|-----|
| `init.lua` byte changes | NONE | No SHA manifest; no startup banner showing loaded SHAs |
| lazy.nvim clone integrity | exit-code only | No SHA verification post-clone |
| Mason install integrity | string-grep heuristic + `\|\| true` | Silent partial installs; no per-binary hash check |
| Backup tamper | NONE | Mode 0755; no inotify/fsevents; no manifest signing |
| `vim.ui.input` rebind | NONE | No sentinel; silent re-override |
| Script execution under hijacked PATH | NONE | No absolute-path enforcement |
| Plugin allowlist | NONE | Spec changes propagate via `Lazy! sync` without out-of-band approval |

---

## 6. Mitigation Roadmap (defense-in-depth, P0 → P3)

### Phase 1 — Critical (do today, < 1 hour total)

1. **M-1a** Move repo OUT of `~/Dropbox`. Use private GitHub remote for cross-machine sync. **Closes KC-1 entirely.** (5 min)
2. **M-10** `chmod 0700` on backup dirs + `umask 077` in `nvim-backup.sh`. (30 sec)
3. **M-17/M-19** Hardened PATH at the top of every script + justfile. (15 min)
4. **M-12** Constrain `nvim-rollback.sh` `restore_target` to `${HOME}` prefix + `realpath` it. (10 min)

### Phase 2 — High (this week, ~3 hours)

5. **M-4** Pin lazy.nvim to a known SHA in `lazy_setup.lua`. (15 min)
6. **M-7** Pin Mason package versions. (1 h)
7. **M-26** Plugin allowlist + pre-sync diff hook. (1 h)
8. **M-15** Replace `\|\| true` with proper rc capture in `nvim-sync.sh`. (5 min)

### Phase 3 — Medium (this month)

9. **M-2** Integrity-check hook in `init.lua` step 1 (SHA manifest outside Dropbox). (1 h)
10. **M-8** Per-tool sha256 manifest for Mason. (2 h)
11. **M-28** Pin or vendor Treesitter parsers. (1 h)
12. **M-22/M-24** Tighten `vim.deprecate` filter + `vim.ui.*` sentinel. (30 min)

### Phase 4 — Low (when bored)

13. **M-30** `mktemp -d` for health log. (10 min)
14. **M-21** Replace env-based bypass with `--yes` flag. (15 min)

---

## 7. Self-Interrogation

**Q1 — Environmental assumptions**: Threat model assumes a personal single-user macOS workstation. Findings F-4, F-13, and parts of F-7 assume "another local UID exists on the machine" which is uncommon on personal Macs; downgrade those to P3 if the user confirms the box is strictly single-user with no SSH/remote management. F-1 does NOT depend on any such assumption — it works as long as the user has Dropbox on more than one device.

**Q2 — Simpler paths**: For an attacker who already has user-level execution on the primary Mac, every finding here is unnecessary. The findings address attackers who DON'T already have local execution and use the harness as their entry. F-1 is the cheapest such path; F-2/F-3 cost more (need network position or upstream compromise). Most findings target the most realistic personal-workstation adversary: a Dropbox-synced other device.

**Q3 — Detection**: Every finding's "Detection" column is honest; the harness currently has zero security-event logging. Even a one-line "warn if init.lua SHA changed since last launch" would catch F-1.

**Q4 — Exploitability gate**:
- F-1 / F-5: REACHABLE ✓, TRIGGERABLE ✓, DEMONSTRABLE ✓ — confirmed vulnerabilities
- F-2 / F-3 / F-11 / F-12: REACHABLE ✓, TRIGGERABLE ✓ but requires upstream compromise OR network position — confirmed vulnerabilities of real but lower-frequency threat actors
- F-4 / F-7 / F-13: REACHABLE ✓, TRIGGERABLE ✓ on multi-user box; PARTIALLY REACHABLE on single-user Mac — downgrade noted in roadmap
- F-9 / F-10: Theoretical channel; useful for defense-in-depth only

---

## VERDICT

**Overall Security Posture**: **VULNERABLE** (personal threat model)
**Kill Chains Identified**: 8 (KC-1 through KC-8)
**Critical Findings**: 1 (F-1)
**High Findings**: 3 (F-2, F-3, F-5)
**Detection Coverage**: NONE — the harness has no security telemetry
**Recommendation**: Execute Phase 1 mitigations before continuing daily use; specifically M-1a (move OUT of Dropbox) flips the verdict to DEFENSIBLE on its own.

**Steel-man for HARDENED**: The harness DOES have several real controls — `set -euo pipefail`, explicit symlink/non-symlink discrimination in install/uninstall, pre-validation of restore source before clobber (a genuinely nice safety pattern in `nvim-rollback.sh:38-68`), backup before destructive replace, refusal to clobber non-symlink directories on side-by-side install, lazy-lock.json for plugin SHA pinning, idempotent install, separate side-by-side vs daily-driver paths with different gates, `DAILY_DRIVER_NONINTERACTIVE` requiring exact `"1"` (not "true" or "yes"), prompt-before-rollback. The underlying script discipline is above average. What it's missing is the SUPPLY-CHAIN layer (F-1..F-3, F-11..F-12) and the local-attacker layer (F-4, F-7, F-13). Those are not script-quality issues; they are architectural assumptions that this is a single-machine, well-networked, never-compromised box. Move the repo out of Dropbox + pin lazy.nvim + pin Mason versions + lock PATH and the verdict reverses.

**Tandem Recommendations** (for coordinator):
- `el-demoledor` — code-level review of the `awk` symlink parser in `nvim-rollback.sh:43-49` (it's clever but has corner cases worth destroying)
- `sre-maniac` — failure-path on `nvim-sync.sh` `|| true` (F-6) for production-reliability angle
- `simplicity-maniac` — the `vim.deprecate` override (F-9) braids policy (which deprecations to hide) with mechanism (prefix match); worth un-complecting

---
*Neo-Hacker: Architecture-level offensive security — trust boundaries, attack chains, detection gaps, mitigations*
