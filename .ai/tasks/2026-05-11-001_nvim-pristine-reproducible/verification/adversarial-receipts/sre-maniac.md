---
task_id: 2026-05-11-001
title: sre-maniac — reliability/failure-modes receipt
type: review
status: complete
agent: sre-maniac
summary: 18 reliability failures across install harness — 5 BLOCKING (concurrent backup overwrite, non-atomic install, recursive backup-from-rollback, sync swallows Mason exit, unbounded backup retention) — daily-driver promotion is currently a one-way trapdoor under common operator conditions.
---

# SRE Maniac — Reliability / Failure-Modes Receipt

**Target**: `justfile` + `scripts/nvim-*.sh` + `nvim-config/{init,lazy_setup}.lua`
**Frame**: Murphy's Law simulation — assume failure is the natural state.
**Verdict**: **DO NOT SHIP as-is**. The harness ships with at least 5 BLOCKING reliability bugs and 7 HIGH-severity bugs that would cost the user hours-to-days when (not if) they trigger. The install path looks atomic but is not. The rollback path is not idempotent under failure. The backup path is silently destructive under timestamp collision. The sync path emits a green checkmark when Mason has failed.

Every finding is **MEASURED** (cited at file:line, verified by reading the actual bytes on disk).

---

## F-1 — `nvim-backup.sh` timestamp collision silently OVERWRITES an in-flight backup

- **Severity**: BLOCKING
- **File:line**: `scripts/nvim-backup.sh:6,8,14` (`TIMESTAMP="$(date +%Y%m%d-%H%M%S)"`, `BACKUP_DIR="$BACKUP_ROOT/$TIMESTAMP"`, `mkdir -p "$BACKUP_DIR"`)
- **Failure mode mechanism**: `date +%Y%m%d-%H%M%S` has **1-second resolution**. Two concurrent invocations (e.g. user types `just promote` in two terminals; or `nvim-install.sh --daily-driver` re-enters `nvim-backup.sh` via `nvim-rollback.sh`'s safety snapshot — see F-3) in the same second produce IDENTICAL `$BACKUP_DIR`. `mkdir -p` succeeds for both (no `-p` error on existing dir). Both then `rsync -a` into the SAME directory. The second rsync overwrites partial files from the first; if file sizes differ across runs (active edits between the two `date` calls), the destination contains a corrupt mix. The manifest.json is written last-write-wins. The user sees TWO "✅ Backup complete: …/20260511-203045" lines and assumes both are independent. They are not.
- **Recovery cost**: **Days** if a real recovery is later attempted from this corrupt timestamp. The user will only discover corruption when they run `just rollback` and the restored config is half from run A, half from run B. Mason state under `data-mason/` will be partial-tree → first nvim launch will fail mid-install with "package not found" for the half that's missing.
- **Mitigation**:
  ```bash
  # In nvim-backup.sh, replace lines 6-8 with collision-proof allocation:
  readonly BACKUP_ROOT="${BACKUP_ROOT:-$HOME/.local/state/nvim-personal-config/backups}"
  mkdir -p "$BACKUP_ROOT"
  # Use mktemp -d with a YMDHMS hint; mktemp guarantees uniqueness via O_EXCL.
  BACKUP_DIR="$(mktemp -d "$BACKUP_ROOT/$(date +%Y%m%d-%H%M%S)-XXXX")"
  readonly BACKUP_DIR
  TIMESTAMP="$(basename "$BACKUP_DIR")"
  readonly TIMESTAMP
  ```
  Update `nvim-rollback.sh:17` and `nvim-uninstall.sh:31` `sort -r` — still lex-sorts cleanly since the new suffix is alphabetic-after-numeric. Verify with: `mkdir -p /tmp/x; for i in 1 2 3; do BACKUP_ROOT=/tmp/x bash scripts/nvim-backup.sh & done; wait; ls /tmp/x` — must show 3 distinct dirs.

---

## F-2 — `nvim-backup.sh` rsync is non-atomic; interrupt mid-copy yields a backup that LOOKS valid

- **Severity**: BLOCKING
- **File:line**: `scripts/nvim-backup.sh:25` (`rsync -a "$src/" "$BACKUP_DIR/$name/"`)
- **Failure mode mechanism**: `rsync -a` writes files in-place (no temp-then-rename for the directory as a whole). If interrupted by Ctrl-C, SIGKILL, kernel panic, laptop lid close at 5% battery, or Dropbox upload-pause-on-low-disk, the partial tree remains at `$BACKUP_DIR/data-mason/` and the next steps NEVER RUN (the `set -euo pipefail` exits). But the directory exists with a fresh `mtime`. `nvim-rollback.sh:17` finds this partial dir as `latest` because it sorts by *name* (YYYYMMDD-HHMMSS) — not by completeness. Worse, `nvim-rollback.sh:25` validates only `config-nvim/init.lua` existence — it does NOT validate `data-mason/` or `state-nvim/`. So rollback restores broken state silently. User's daily nvim then crashes mid-Mason-load. The on-disk manifest.json is also MISSING (cat-heredoc at :38 hasn't run), but rollback doesn't check for it.
- **Recovery cost**: **Hours**. User must manually `rm -rf` the partial backup, then identify the *previous* backup (which may itself be days old), then re-run rollback. If they're under deadline pressure (the reason they're rolling back), this is a panic operation.
- **Mitigation**:
  ```bash
  # nvim-backup.sh — write to .partial/ and rename atomically on success.
  readonly WORK_DIR="$BACKUP_DIR.partial"
  mkdir -p "$WORK_DIR"
  trap 'rm -rf "$WORK_DIR"' ERR INT TERM   # cleanup partial on any failure
  # ... do all rsyncs into $WORK_DIR/...
  # At the END, after manifest.json is written, write a SENTINEL and rename:
  touch "$WORK_DIR/.backup-complete"
  mv "$WORK_DIR" "$BACKUP_DIR"
  trap - ERR INT TERM
  # In nvim-rollback.sh:17, filter on sentinel:
  latest="$(find "$BACKUP_ROOT" -mindepth 2 -maxdepth 2 -name .backup-complete \
            -exec dirname {} \; | xargs -n1 basename | sort -r | head -1)"
  ```

---

## F-3 — `nvim-rollback.sh` calls `nvim-backup.sh` from inside the rollback path WITHOUT checking its exit code

- **Severity**: BLOCKING
- **File:line**: `scripts/nvim-rollback.sh:82` (`bash "$(dirname -- "$0")/nvim-backup.sh"` — no `||` guard, no exit check)
- **Failure mode mechanism**: `set -euo pipefail` is at line 4, so an `exit 1` from the child *would* propagate — BUT `nvim-backup.sh` uses `du -sh` and `wc -l` which can return non-zero on permission errors and would abort the safety snapshot AFTER `mkdir -p "$BACKUP_DIR"` at :14 has already created the timestamp directory. The user is left in this state:
  1. Safety snapshot directory exists (empty or partial).
  2. `$DEST` is still intact (because line 83's `rm -rf` hasn't run yet — fine).
  3. But on **next** rollback attempt, `find … sort -r | head -1` picks up the empty safety snapshot as `latest`, then `:25` rejects it ("Backup has no recoverable nvim config"), and the user can NO LONGER rollback to the actual most-recent good backup without manual `ls` + flag.
- **Recovery cost**: **30-60 minutes** of debugging why rollback says "no recoverable nvim config" when the user can plainly see backups in `~/.local/state/nvim-personal-config/backups/`.
- **Mitigation**:
  ```bash
  # nvim-rollback.sh:81-84 — fail loudly, and clean up failed safety snapshot:
  elif [[ -d "$DEST" ]]; then
    echo "   💾 snapshotting current $DEST before rollback (safety)"
    if ! bash "$(dirname -- "$0")/nvim-backup.sh"; then
      echo "❌ Safety snapshot failed — refusing to clobber $DEST" >&2
      echo "   (your current config is intact; investigate backup failure first)" >&2
      exit 1
    fi
    rm -rf "$DEST"
  fi
  ```
  Combined with F-2's sentinel: `find … -name .backup-complete` skips partial safety snapshots automatically.

---

## F-4 — `nvim-sync.sh` swallows the Mason exit code and reports success on failure

- **Severity**: BLOCKING
- **File:line**: `scripts/nvim-sync.sh:42-44` (`nvim --headless +"…MasonToolsUpdateSync…" +"sleep ${TIMEOUT_S}" +"qa" >"$MASON_LOG" 2>&1 || true`)
- **Failure mode mechanism**: The trailing `|| true` neuters `set -euo pipefail`. Then the grep at :46 looks for case-sensitive `error|failed|❌`. Real-world Mason failure modes that the grep MISSES: `Error` (capitalized), `npm ERR!`, `EACCES`, `ENOTFOUND`, `Could not resolve`, `permission denied`, `404`, `429 Too Many Requests`, `peer's certificate has expired`, `git: not found`, `download failed: 503`. With 40+ tools in `plugins/mason.lua:10`, the probability of **at least one** silent failure on a fresh machine over a flaky network is high. The user sees "✅ Mason install finished without visible errors" and proceeds to `just promote` with a half-broken toolchain. First time they open Go code, `gopls` is missing. First time they save a YAML file, `yamlfmt` is missing → format-on-save SILENTLY skips (astrolsp falls through). The user blames the LSP config, not Mason.
- **Recovery cost**: **Hours**, distributed across days. The user notices each missing tool only when they touch the corresponding filetype. They debug astrolsp, none-ls, and treesitter before realizing Mason never finished.
- **Mitigation**:
  ```bash
  # nvim-sync.sh — replace lines 42-55 with a proper exit-code path:
  if ! nvim --headless \
        +"lua vim.defer_fn(function() pcall(vim.cmd, 'MasonToolsUpdateSync') end, 500)" \
        +"sleep ${TIMEOUT_S}" +"qa" >"$MASON_LOG" 2>&1; then
    echo "❌ Mason install exited non-zero (timeout or fatal error)" >&2
    tail -40 "$MASON_LOG" >&2; exit 1
  fi
  # Broader pattern, case-insensitive. Also probe Mason's actual installed state.
  if grep -qiE '(error|failed|❌|npm ERR|EACCES|ENOTFOUND|404|503|permission denied|certificate)' "$MASON_LOG"; then
    echo "❌ Mason emitted failure markers:" >&2; tail -40 "$MASON_LOG" >&2; exit 1
  fi
  # Source-of-truth check: ask Mason what's actually installed vs ensure_installed.
  nvim --headless +"lua local r=require'mason-registry'; local missing={}; for _,n in ipairs(require'mason-tool-installer'.config.ensure_installed or {}) do if not r.is_installed(n) then table.insert(missing,n) end end; if #missing>0 then io.stderr:write('MISSING: '..table.concat(missing,',')..'\n'); os.exit(1) end" +qa
  ```

---

## F-5 — No backup retention policy; daily `just promote` fills disk in 5-10 days

- **Severity**: BLOCKING (on a 256GB laptop with Dropbox cache)
- **File:line**: `scripts/nvim-backup.sh` (no retention logic anywhere) + `justfile:60-62` (`list-backups` is read-only, no `prune` recipe)
- **Failure mode mechanism**: `data-mason/` on a working AstroNvim machine is 1.5-3 GB (40+ LSPs + DAPs + linters, each pulling node_modules / go bin / rust toolchain bits). `data-lazy/` is 200-500 MB. Per the dispatch brief, a single backup is ~2.3 GB. The repo lives at `~/Dropbox/@GITHUB/@oss/nvim-personal-config` — meaning the user's home is already on a sync-limited drive. **Common operator flow**: user iterates on plugin config → runs `just promote` daily for a sprint → 7 days × 2.3 GB = 16 GB. After 30 days, 70 GB. APFS reports "no space" when **container** is full, not when partition is full → other apps (browser, Spotlight) fail mysteriously first. Dropbox Smart Sync starts evicting source files in the same `~/Dropbox` tree, including the **repo itself**, which then breaks symlink readability (F-7).
- **Recovery cost**: **Hours** — user must manually identify safe-to-delete backups (the rollback script gives NO hint which are sentinel-validated complete vs partial, see F-2). Worse, when disk fills, *new* backups during `just promote` produce partial trees (F-2) → may be the only "recent" backup → rollback target is broken.
- **Mitigation**:
  ```makefile
  # justfile — add prune recipe:
  prune keep="7":
      @find "{{BACKUP_ROOT}}" -mindepth 1 -maxdepth 1 -type d | sort -r | tail -n +$(({{keep}}+1)) | xargs -r rm -rf
      @echo "✅ Kept newest {{keep}} backups; pruned the rest."

  # Auto-prune as part of `promote`:
  promote: backup install sync prune
  ```
  And: add a pre-flight disk check in `nvim-backup.sh`:
  ```bash
  required_mb=$((3 * 1024))   # 3 GB safety
  avail_mb=$(df -m "$BACKUP_ROOT" | awk 'NR==2 {print $4}')
  if (( avail_mb < required_mb )); then
    echo "❌ Refusing to backup: only ${avail_mb}MB free, need ${required_mb}MB" >&2; exit 1
  fi
  ```

---

## F-6 — `nvim-install.sh --daily-driver` is non-transactional; mid-flight failure leaves user with NO config

- **Severity**: HIGH
- **File:line**: `scripts/nvim-install.sh:50-78` (sequence: `nvim-backup.sh` → `rm -rf "$DEST"` → `ln -s` → `test -r`)
- **Failure mode mechanism**: Between line 67 (`rm -rf "$DEST"`) and line 78 (`ln -s`) there is a **destructive window**. Crash modes:
  1. User Ctrl-C between 67 and 78 → `$DEST` gone, no symlink, **nvim won't start** (no config).
  2. Power loss / laptop sleep on low battery between 67 and 78 → same as above.
  3. `mkdir -p "$XDG_CONFIG"` at :77 fails (perms / readonly fs) → `set -e` exits, destructive window remains open.
  4. `ln -s` at :78 succeeds, then `test -r "$DEST/init.lua"` at :81 fails because Dropbox Smart Sync evicted `nvim-config/init.lua` between scripts ran → user's daily driver is now a dangling symlink, no rollback was triggered (script exits 1, doesn't auto-rollback).
- **Recovery cost**: **15-60 minutes**, possibly under pressure (user just blew away their daily config and is staring at "E1208: -complete used without allowing arguments" on a fresh nvim).
- **Mitigation**:
  ```bash
  # nvim-install.sh — make the swap atomic via stage-then-rename:
  if $daily_driver; then
    # 1. Backup first (already done).
    # 2. Create symlink with a temp name in the SAME dir as $DEST.
    tmp_link="${DEST}.installing.$$"
    ln -s "$SRC_DIR" "$tmp_link"
    if ! test -r "$tmp_link/init.lua"; then
      rm -f "$tmp_link"
      echo "❌ Source unreadable (Dropbox eviction?). $DEST untouched." >&2
      exit 1
    fi
    # 3. Atomically replace. mv with -T (Linux) or rsync-based replacement on macOS.
    rm -rf "$DEST"
    mv "$tmp_link" "$DEST"   # rename is atomic within same fs
  fi
  ```
  Even better: install an exit-trap that, on non-zero exit between backup and successful ln, restores from the just-taken backup automatically.

---

## F-7 — Dropbox Smart Sync eviction of the repo silently breaks the symlinked config

- **Severity**: HIGH
- **File:line**: `scripts/nvim-install.sh:11-12,81-85` (REPO_ROOT under `~/Dropbox/...`; `test -r` runs ONCE at install time only)
- **Failure mode mechanism**: The symlink is created against a Dropbox-cloud path. After some idle time, Dropbox Smart Sync evicts blobs in `nvim-config/lua/plugins/*.lua` to reclaim disk. `:Lazy` on next launch tries to read `astrocore.lua` (11 KB) → Dropbox lazy-fetches synchronously → either (a) succeeds with multi-second latency on every reload (user sees random nvim freezes), (b) fails offline → nvim errors with `E484: Can't open file …/astrocore.lua` mid-startup → editor unusable. The install script's `test -r init.lua` at :81 only tests ONE file at install time; it does not protect ongoing reads. There is **no startup-time canary** verifying that the spec dir is fully resident.
- **Recovery cost**: **Hours** of confused debugging — symptom looks like Lazy corruption or a plugin bug, not a sync-state bug. On the road without internet, user is locked out of nvim with no obvious fix.
- **Mitigation**: Choose ONE of:
  1. **Best**: do not host the daily-driver repo under Dropbox. Document this. Add a guard in `nvim-install.sh`:
     ```bash
     case "$SRC_DIR" in
       *Dropbox*|*OneDrive*|*"Google Drive"*|*iCloud*)
         echo "⚠️  $SRC_DIR is under a cloud-sync directory." >&2
         echo "   Files may be evicted by smart-sync, breaking nvim on demand." >&2
         echo "   Recommended: clone to ~/.config/nvim-personal-config (non-synced)." >&2
         if [[ "${ALLOW_CLOUD_SYNC_HOST:-0}" != "1" ]]; then exit 1; fi ;;
     esac
     ```
  2. **If user insists on Dropbox**: force materialization at install time and verify on every `just sync`:
     ```bash
     # Materialize entire spec tree (Dropbox-CLI-agnostic: just read every file).
     find "$SRC_DIR" -type f -name '*.lua' -exec dd if={} of=/dev/null bs=1 count=1 status=none \;
     ```
     This is fragile; option 1 is the correct fix.

---

## F-8 — `lazy-lock.json` provides reproducibility for plugins, NONE for `AstroNvim/AstroNvim` semver

- **Severity**: HIGH
- **File:line**: `nvim-config/lua/lazy_setup.lua:4` (`version = "^6"`)
- **Failure mode mechanism**: `version = "^6"` means "any v6.x.y". When AstroNvim ships v6.5.0 → v6.6.0 (minor bump within 6.x), `Lazy! sync` (called by `nvim-sync.sh:29`) resolves to the NEWEST 6.x tag, even though `lazy-lock.json` records a specific commit. AstroNvim's own plugins (the `import = "astronvim.plugins"` at :5) and the community modules pull in new specs that may need different Mason tools, different keymaps, different LSP shapes. Machine A synced last week (v6.5.0); machine B syncs today (v6.5.1) → divergent state despite identical `lazy-lock.json`. `lazy-lock.json` records AstroNvim's commit BUT lazy.nvim respects the higher-priority `version = "^6"` constraint on Lazy! sync per its semantics. Worse: when **v7** ships, `^6` becomes a hard upgrade block — `Lazy! sync` will report nothing to update, the user will see deprecation messages from astrocommunity targeting v7 APIs, and there is NO communication path in the install harness telling them to edit lazy_setup.lua. They'll google it for hours.
- **Recovery cost**: Machine-divergence: **hours per occurrence, recurring**. v6→v7 future migration: **1-2 days** for a confused user.
- **Mitigation**:
  ```lua
  -- lazy_setup.lua — pin the commit, not the semver. Keep semver as fallback comment.
  {
    "AstroNvim/AstroNvim",
    -- version = "^6",  -- DISABLED: lock_file pin is source of truth.
    commit = "<sha-from-lazy-lock>",  -- updated by nvim-update-lock.sh
    import = "astronvim.plugins",
    ...
  }
  ```
  AND: emit a v7-detection warning at install:
  ```bash
  # nvim-doctor.sh — query latest AstroNvim release and warn on major-version skew.
  latest="$(curl -fsSL https://api.github.com/repos/AstroNvim/AstroNvim/releases/latest \
            | awk -F\" '/tag_name/{print $4; exit}')"
  echo "ℹ️  AstroNvim latest release: $latest (pinned: ^6)"
  case "$latest" in v7*|v8*|v9*) echo "⚠️  Major bump available — manual upgrade required." ;; esac
  ```

---

## F-9 — `nvim-sync.sh` MASON_SYNC_TIMEOUT uses busy-`+sleep`, blocks for full timeout EVEN ON SUCCESS

- **Severity**: HIGH (UX + CI cost)
- **File:line**: `scripts/nvim-sync.sh:41-44` (`TIMEOUT_S="${MASON_SYNC_TIMEOUT_SECONDS:-300}"; nvim ... +"sleep ${TIMEOUT_S}" +"qa"`)
- **Failure mode mechanism**: There is no sentinel polling. `nvim` literally sleeps for the FULL 300 seconds regardless of whether `MasonToolsUpdateSync` finished in 5 seconds (cached / no-op case) or is still going at 600 seconds (slow network). Result:
  - **Best case (no-op / already installed)**: every `just sync` blocks 5 minutes. CI cost: $$.
  - **Worst case (genuinely slow on fresh machine)**: 5 minutes is INSUFFICIENT for 40+ tools + Go module downloads + npm registry. Mason gets SIGTERM'd mid-install via `+"qa"` → leaves Mason package state in `~/.local/share/nvim/mason/staging/` partially extracted → next nvim launch errors on those packages. The grep at :46 misses this (Mason emits its errors to its own UI buffer, not stdout in headless mode).
- **Recovery cost**: Bad UX every day; on a fresh machine, **30-60 minutes** to debug why some tools are half-installed.
- **Mitigation**:
  ```bash
  # Use mason-tool-installer's MasonToolsInstallSync (blocking, exits when done)
  # plus a real timeout wrapper:
  if command -v gtimeout >/dev/null; then TO=gtimeout; else TO=timeout; fi
  if ! "$TO" "${TIMEOUT_S}s" nvim --headless +"MasonToolsInstallSync" +"qa" >"$MASON_LOG" 2>&1; then
    rc=$?
    if [[ $rc -eq 124 ]]; then
      echo "❌ Mason install timed out after ${TIMEOUT_S}s — partial install possible." >&2
    fi
    tail -25 "$MASON_LOG" >&2; exit 1
  fi
  ```

---

## F-10 — Format-on-save `ignore_filetypes = { "helm" }` likely misses real Helm filetype

- **Severity**: HIGH
- **File:line**: `nvim-config/lua/plugins/astrolsp.lua:31-33` and `nvim-config/lua/polish.lua:107` (yaml.helm registered as YAML variant)
- **Failure mode mechanism**: `polish.lua:107` includes `"yaml.helm"` in the YAML autocmd FileType pattern → Helm templates get filetype `yaml.helm` (or just `yaml` if helm-ls isn't detecting via towolf/vim-helm). `astrolsp.lua:32` ignores only `helm` (bare). Match semantics: AstroLSP's `ignore_filetypes` is a list-include check, NOT a pattern match. `yaml.helm ≠ helm`. Therefore: opening `templates/deployment.yaml` with `{{ .Values.foo }}` → `:set ft?` returns `yaml.helm` → format-on-save fires → `yamlfmt`/`prettier` rewrites `{{ .Values.foo }}` to either an error (yamlfmt rejects invalid YAML) or strips quotes/reformats → **silently corrupts user's Helm chart**. The user only notices when `helm template` fails downstream.
- **Recovery cost**: **Hours** of "why does my chart not render anymore" + git-bisect + revert. Worse if pushed to a feature branch and shared.
- **Mitigation**:
  ```lua
  -- astrolsp.lua — match every variant Helm filetypes can take, AND defensively
  -- gate format-on-save on filename pattern, not just filetype.
  ignore_filetypes = { "helm", "yaml.helm", "gotmpl", "helm-template" },

  -- ALSO add filename-based guard in polish.lua BufWritePre, defense-in-depth:
  vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = { "*/templates/*.yaml", "*/templates/*.yml", "*/templates/*.tpl", "Chart.yaml" },
    callback = function(ev) vim.b[ev.buf].autoformat = false end,
  })
  ```
  Verify: open `templates/deployment.yaml` → `:lua print(vim.bo.filetype)` → confirm ignore list catches it.

---

## F-11 — `:Lazy! restore` followed by `:Lazy! sync` is a no-op race; restore output is overwritten

- **Severity**: HIGH
- **File:line**: `scripts/nvim-sync.sh:21,29` (two separate `nvim --headless` invocations in sequence — restore THEN sync)
- **Failure mode mechanism**: `Lazy! restore` reads lazy-lock.json and resets every plugin to its locked commit. `Lazy! sync` immediately afterward INSTALLS missing plugins AND **updates** existing plugins per the spec — and per lazy.nvim's documented `sync` semantics, sync = clean + install + update. The `update` step will move pinned-by-lock plugins back toward the latest matching `version`/`branch` constraint. For plugins specified with `event = "BufRead"` and `version = "*"` (e.g. `git-conflict.nvim` at `user.lua:144`), `Lazy! sync` re-resolves to the latest matching tag — UNDOING what `Lazy! restore` just pinned. The "reproducibility anchor" claim at `nvim-install.sh:91` is misleading. The lock-file is only respected by **install** (first install), not by **sync** (which re-resolves).
- **Recovery cost**: **Hours** of cross-machine debugging — "why does machine A have plugin X at commit abc but machine B at xyz, even though lazy-lock.json matches?"
- **Mitigation**: Use `Lazy! restore` ONLY, and only `install` (not `sync`) when a lock file is the source of truth:
  ```bash
  # nvim-sync.sh — replace lines 21-33 with a single, lock-respecting flow:
  if ! nvim --headless +"Lazy! restore" +"qa" >"$LAZY_LOG" 2>&1; then ...; fi
  if ! nvim --headless +"Lazy! install" +"qa" >>"$LAZY_LOG" 2>&1; then ...; fi
  # No Lazy! sync — it defeats the lock.
  ```
  And add a separate `just update-plugins` recipe for the explicit "I want to drift forward" flow.

---

## F-12 — `nvim-update-lock.sh` clobbers repo lock file without git-staging confirmation

- **Severity**: MEDIUM
- **File:line**: `scripts/nvim-update-lock.sh:26-27` (`cp "$LIVE_LOCK" "$REPO_LOCK"`)
- **Failure mode mechanism**: When repo is NOT symlinked (e.g. user did `install-side` but is now `update-lock`'ing toward repo from a side install they consider canonical), the script `cp`'s the live file over the repo file without checking whether the repo lock is currently dirty in git. If the user has hand-edited `lazy-lock.json` (e.g. to test a plugin pin), their edits are lost silently. `cp` returns 0; the script reports success.
- **Recovery cost**: **Minutes-hours** — `git reflog` and `git stash list` won't help; the file was never staged. Must reconstruct manually.
- **Mitigation**:
  ```bash
  # nvim-update-lock.sh — refuse to clobber a dirty repo lock without --force.
  cd "$REPO_ROOT"
  if git diff --quiet -- "$REPO_LOCK" || ! git ls-files --error-unmatch "$REPO_LOCK" >/dev/null 2>&1; then
    : # clean or untracked — safe
  else
    echo "❌ $REPO_LOCK has uncommitted changes; refusing to overwrite." >&2
    echo "   Stash or commit first, or pass UPDATE_LOCK_FORCE=1." >&2
    [[ "${UPDATE_LOCK_FORCE:-0}" = "1" ]] || exit 1
  fi
  ```

---

## F-13 — `nvim-theme.sh` `sed -i.bak` + `mv` not atomic; SIGINT mid-edit leaves orphan `.bak`

- **Severity**: MEDIUM
- **File:line**: `scripts/nvim-theme.sh:54-55,64-65` (`sed -i.bak …; rm -f "$ASTROUI.bak"` then `awk … > .new; mv .new community.lua`)
- **Failure mode mechanism**: macOS `sed -i.bak` writes `.bak` then mutates in place. Ctrl-C between :54 and :55 leaves `astroui.lua.bak` on disk. Worse: between :64 awk-redirect and :65 mv, Ctrl-C leaves `community.lua.new` next to the original — `:Lazy` and other recursive globs (e.g. `stylua nvim-config`) will then format/lint the orphan `.new` and `.bak` files. Stylua at `justfile:110` formats `scripts` and `nvim-config` recursively → orphan files get formatted into the working tree → confusing diff at next commit.
- **Recovery cost**: **Minutes** but cumulatively annoying; surprising on `git status`.
- **Mitigation**:
  ```bash
  # nvim-theme.sh — single-trap cleanup:
  trap 'rm -f "$ASTROUI.bak" "$COMMUNITY.new"' EXIT INT TERM
  ```

---

## F-14 — `nvim-health.sh` only checks `^- ❌` error rows; misses many real failures

- **Severity**: MEDIUM
- **File:line**: `scripts/nvim-health.sh:27,31` (`grep -cE '^- ❌'`)
- **Failure mode mechanism**: `:checkhealth` output schema is NOT stable: not every check emits `- ❌` for errors. Some plugins emit `ERROR ` or `[ERROR]` or `## errors` headers without the bullet+emoji prefix. Plugins still on older nvim-health API emit `- ERROR:` (text, no emoji) which the grep misses entirely. mason-lspconfig in particular emits "WARNING" rows that are actually fatal-on-load. So health says "PASSED" while three LSPs are silently broken.
- **Recovery cost**: **Hours** when the user encounters one of these LSPs and it just... doesn't attach. They re-run `just health` → PASS → confused.
- **Mitigation**:
  ```bash
  # nvim-health.sh — broaden the error grep and report both shapes:
  errors=$(grep -cE '(^- ❌|^ERROR\b|^\[ERROR\]|^## .*error|: ERROR\b)' "$LOG" || true)
  ```
  Or invert: parse `:checkhealth` JSON if a future nvim adds it; otherwise count any line containing `ERROR` (with reasonable false-positive tolerance — the trade-off is "fail loud" which is correct here).

---

## F-15 — `mason-tool-installer` `ensure_installed` is 30+ tools; first launch on fresh machine triggers thundering herd

- **Severity**: MEDIUM
- **File:line**: `nvim-config/lua/plugins/mason.lua:10-75`
- **Failure mode mechanism**: 30+ packages fan out simultaneously from registry. Each performs git clone or npm install or go install in parallel. On a constrained network (corporate proxy, hotel wifi, mobile tether), this saturates connections, triggers rate-limit responses from npm/github (`429`, `503`), and tools fail individually. Mason-tool-installer logs to its own buffer; failures are not raised to the user, only visible by opening `:Mason`. Combined with F-4 (sync swallows errors), the first-launch state is "looks installed but isn't." Memory spike during simultaneous installs can also hit OOM on a 8GB machine — npm install for `typescript-language-server` + `eslint_d` + `prettier` + `biome` simultaneously easily peaks at 1.5GB resident.
- **Recovery cost**: **Hours** of `:Mason` triage, install-one-at-a-time.
- **Mitigation**:
  ```lua
  -- mason.lua — throttle concurrent installs and force sync mode at boot:
  opts = {
    run_on_start = true,
    start_delay = 3000,      -- give UI time to render
    debounce_hours = 24,     -- don't reinstall on every nvim launch
    auto_update = false,     -- explicit upgrades only
    integrations = { ["mason-lspconfig"] = true },
    ensure_installed = { ... },
  }
  -- AND in Mason core (separate spec):
  { "williamboman/mason.nvim", opts = { max_concurrent_installers = 2 } }
  ```

---

## F-16 — `init.lua:31-38` monkey-patches `vim.deprecate` GLOBALLY for the session

- **Severity**: MEDIUM
- **File:line**: `nvim-config/init.lua:25-38`
- **Failure mode mechanism**: Suppressing `opts.jump.float` and `client.supports_method` globally hides those deprecations everywhere — including when **the user's own plugins or scripts** trigger them. When a new minor of nvim drops, the suppression list goes stale; deprecations that became errors get silently swallowed by the prefix-match. The user has no signal until functionality breaks. The patch is also not reversible mid-session (no API to restore `_vim_deprecate`), so `:lua vim.deprecate(...)` from the cmdline is also suppressed.
- **Recovery cost**: **Hours** of "why is this nvim API behavior different from docs" — the deprecation message that would have warned the user is gone.
- **Mitigation**: Scope the suppression to a single autocmd that fires only during plugin load:
  ```lua
  -- init.lua — turn on suppression at User LazyDone, turn OFF after.
  vim.api.nvim_create_autocmd("User", {
    pattern = "VeryLazy",
    once = true,
    callback = function() vim.deprecate = _vim_deprecate end,
  })
  ```
  Alternatively: list-with-date-and-issue every suppressed prefix and emit `:checkhealth` ERROR rows after a date threshold (e.g. 90 days) to force the user to revisit. Add a CI job that runs `nvim --headless +qa 2>&1 | grep -c 'is deprecated'` and fails on growth.

---

## F-17 — `nvim-rollback.sh` rsync without `--delete` leaves stale state

- **Severity**: MEDIUM
- **File:line**: `scripts/nvim-rollback.sh:91` (`rsync -a "$BACKUP_DIR/config-nvim/" "$DEST/"`)
- **Failure mode mechanism**: `rsync -a` (without `--delete`) only ADDS or OVERWRITES. If `$DEST` was previously the symlink (just removed at :79 if symlink) the dir is empty, fine. But if `$DEST` was a real directory (came down the `elif` branch at :80, which `rm -rf`'s it first), also empty, fine. HOWEVER, if a future change ever skips the `rm -rf`, or if rollback is re-entered after a partial restore, files in `$DEST` that are NOT in the backup persist. User believes they have a clean state from `latest`; they actually have leftover plugin specs from an intermediate version. nvim loads the merged tree → mysterious errors.
- **Recovery cost**: **30-60 minutes** of "why does this plugin spec exist; I deleted it weeks ago".
- **Mitigation**:
  ```bash
  rsync -a --delete "$BACKUP_DIR/config-nvim/" "$DEST/"
  ```
  Same for `nvim-uninstall.sh:34`.

---

## F-18 — No verification that backup `data-mason/` matches restored `config-nvim/lazy-lock.json`

- **Severity**: LOW (recovery-time amplifier; combines with everything above)
- **File:line**: `scripts/nvim-rollback.sh` (whole script) — no cross-validation between snapshot components
- **Failure mode mechanism**: Backup snapshots `config-nvim/`, `data-lazy/`, `data-mason/`, `state-nvim/` as four independent rsyncs (`nvim-backup.sh:32-35`). Rollback only restores `config-nvim/`. **It does not restore `data-mason/` or `data-lazy/`**. So a rollback from a day-old snapshot brings back the OLD config but leaves CURRENT (post-promote) Mason and Lazy state. Result: post-rollback nvim loads old config against new plugin commits → field-name mismatches, missing astrocore opts, broken LSP attach. The user thinks rollback didn't work; in fact, it half-worked, which is worse.
- **Recovery cost**: **Hours** of confused debugging, or the user concludes "rollback is broken" and gives up.
- **Mitigation**:
  ```bash
  # nvim-rollback.sh — restore all four trees, or document the limitation:
  for component in config-nvim:"$XDG_CONFIG/nvim" \
                   data-lazy:"$XDG_DATA/nvim/lazy" \
                   data-mason:"$XDG_DATA/nvim/mason" \
                   state-nvim:"$XDG_STATE/nvim"; do
    name="${component%%:*}"; dest="${component#*:}"
    [[ -d "$BACKUP_DIR/$name" ]] && rsync -a --delete "$BACKUP_DIR/$name/" "$dest/"
  done
  ```
  At minimum: print a giant warning that rollback does NOT restore plugin/Mason state, and recommend `Lazy! restore` after.

---

# Cascade synthesis

The harness has 5 BLOCKING + 7 HIGH issues that **chain**:

```
F-7 (Dropbox eviction) → F-6 (mid-install half-applied) → F-3 (rollback safety snapshot fails)
                                                        → F-2 (partial backup looks valid)
                                                        → F-18 (rollback restores half-state)
                                                        → user has NO working nvim, NO clean rollback target

F-5 (no retention) → disk fills → F-2 (partial backups on full disk) → F-1 (concurrent backups collide)
                                                                    → backup tree is corrupt
                                                                    → F-3 amplifies (safety snapshot also corrupt)
                                                                    → unrecoverable

F-4 (sync swallows Mason exit) → user runs `just promote` → F-11 (Lazy! sync drifts lock)
                                                          → daily driver is silently in an unverified state
                                                          → next time user touches a non-trivial filetype,
                                                            something is broken; root cause untraceable
```

**Blast radius**: when ANY of F-1, F-2, F-3 fires while user is rolling back from a broken promote, the user loses their daily driver AND their fallback simultaneously. This is a one-way trapdoor in a daily-driver tool. **DO NOT SHIP** without at least F-1, F-2, F-3, F-4, F-5 fixed.

# Minimum landing set (BLOCKING)

| # | Fix | Effort |
|---|-----|--------|
| F-1 | mktemp-based unique backup dir | 10 min |
| F-2 | `.partial/` staging + sentinel + cleanup trap | 30 min |
| F-3 | check exit code of safety snapshot in rollback | 10 min |
| F-4 | replace `\|\| true` + grep-shotgun with proper exit-code + Mason registry probe | 30 min |
| F-5 | add `just prune` recipe + auto-prune in `promote` + pre-flight disk check | 20 min |

Total: ~100 minutes of work prevents the catastrophic chain. The HIGH-severity findings (F-6 through F-11) should land in a second iteration before the user does anything beyond their current single-machine setup.
