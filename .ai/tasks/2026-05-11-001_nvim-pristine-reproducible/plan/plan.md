---
task_id: 2026-05-11-001
agent: coordinator
status: complete
summary: Execution plan — capture live AstroNvim v5 config, surgically modernize, build justfile install harness, run 3 parallel adversarials, verify with headless health.
---

# Phase 5 — Plan

## End-state (vivid)
A user opens a fresh terminal, runs `cd nvim-personal-config && just install`. The justfile backs up the current `~/.config/nvim` to `~/Backups/nvim-{ts}/`, symlinks the repo's `nvim-config/` directory in its place, runs `:Lazy! sync` headless, runs `:checkhealth` headless and reports `✓ 0 ERRORs`. The user opens nvim. The Kanagawa Wave theme loads with smear-cursor animation. Snacks dashboard renders with custom ASCII art. All 14 language servers attach without errors. Cold start measures ≤130ms. Theme can be flipped with `just nvim-theme cyberdream`. Rollback is one command. The repo's `lazy-lock.json` makes every install bit-identical.

## Backward chain (preconditions)
- Working `just install` → justfile + install script + `nvim-config/` source-of-truth all exist
- `nvim-config/` source-of-truth → live `~/.config/nvim` captured + 9 defects fixed + AstroNvim pinned `^6`
- 9 defects fixed → exact diffs identified per file (see Defect Ledger in P3 reqs)
- justfile → mirrors dotfiles pattern (symlink-with-backup, extract↔install pairs, orchestrator, verbose variants)

## 6Q + Q7 attacks (context adequacy + route)

**Q1 — What load-bearing assumption could flip the route?**  
That the user's `~/.config/nvim` is the "good" baseline. If it's already half-broken, capturing it propagates bugs. **Mitigation**: capture FIRST, run health probe BEFORE modifications, fix defects with explicit diffs (not "re-write from scratch").  
Falsifier: if post-capture health shows MORE errors than pre-capture, capture is wrong.

**Q2 — Alternative route worth considering?**  
Start from AstroNvim v6 template + re-author plugin overrides from scratch using the existing config as inspiration. **Rejected**: the user's polish.lua + astrolsp.lua + astrocore.lua are sophisticated and hand-tuned; rewriting risks losing knowledge. **Accepted**: capture then surgically patch.

**Q3 — How could we be wrong?**  
- The AstroNvim v5→v6 pin could break the highlight overrides (kanagawa @lsp.type.* groups may rename)  
- snacks consolidation could break the user's existing dashboard ASCII art  
- The smart-splits keybind drop could remove user muscle memory  
**Mitigation**: pin v6 in side-by-side first; visual smoke test before swap; preserve original ASCII art in dashboard config.

**Q4 — Hidden complexity?**  
- `lazy-lock.json` is currently in `~/.config/nvim/`, not the repo — must migrate it into repo at capture  
- AstroNvim ships its own snapshot system that may conflict with our pinning  
- `mason-tool-installer` requires Lazy to be done before it runs — race conditions in headless `+Lazy! sync +MasonToolsUpdateSync +qa` (need explicit `vim.cmd.MasonToolsUpdateSync` deferred)

**Q5 — Version pinning probed?**  
- AstroNvim spec gets `version = "^6"` (semver caret, allows 6.x.x)  
- `lazy-lock.json` checked in, locks every plugin commit hash  
- Justfile `update-lock` is the only way to mutate lock; commit gates ensure reproducibility  
- Mason tools: stored declaratively in `lua/plugins/mason.lua` `ensure_installed` array

**Q6 — Silent-fail mode?**  
- `:checkhealth ERROR` rows could grow (vs shrink) — caught by SC-1 grep  
- `:Lazy` could be partially-loaded with deferred error — caught by SC-4 explicit `:Lazy` state probe  
- Dashboard could render but no plugins actually attach — caught by SC-3 (open file, see LSP attach)  
- Theme switch could "succeed" but highlights revert on first edit — caught by SC-9 (headless `:colorscheme?` after deferred render)

**Q7 (orthogonal #4) — What if the user's terminal doesn't support advertised features?**  
Smear cursor relies on extmarks; snacks.image needs kitty/sixel graphics protocol; ASCII dashboard needs nerd-font. **Mitigation**: justfile `doctor` recipe checks terminal capabilities + nerd-font + advertises gaps. Snacks image module disabled by default (the source of 6 of 9 health ERRORs). Smear-cursor `enabled = function() return not vim.g.vscode end` already gates it.

## Step DAG (with acceptance + falsifier per step)

### S1 — Capture live config into repo
- **Action**: `cp -R ~/.config/nvim/* nvim-config/` (plus lazy-lock.json). Exclude `.git/` if any. Exclude `lazy/` (state, not config). Keep dotfiles `.luarc.json`, `.neoconf.json`, `.stylua.toml`, `selene.toml`.
- **Acceptance**: `diff -r ~/.config/nvim/lua nvim-config/lua` empty.
- **Falsifier**: any file in `~/.config/nvim/lua` not appearing under `nvim-config/lua/` (excluding `.git`, `lazy/`, `mason/`, `state/`).
- **Rollback**: `rm -rf nvim-config/`.

### S2 — Archive obsolete `nvchad-config/`
- **Action**: `mv nvchad-config _archive/nvchad-config-pre-2026-05-11/`
- **Acceptance**: `ls nvchad-config 2>/dev/null` returns nothing; `_archive/` exists.
- **Falsifier**: git diff shows file deletion of nvchad-config without corresponding addition under `_archive/`.

### S3 — Fix D-1: rename `astrocommunity.pack.python-ruff` → current name
- **Action**: probe `https://github.com/AstroNvim/astrocommunity` for current python pack name; edit `nvim-config/lua/community.lua` line 14.
- **Acceptance**: headless `+Lazy! check +qa` does NOT report `No specs found for module`.
- **Falsifier**: post-edit health probe still shows that error.

### S4 — Fix D-2: guard trailing-whitespace autocmd
- **Action**: edit `nvim-config/lua/polish.lua` line 36-45. Add early return if `not vim.bo.modifiable or vim.bo.buftype ~= ""`.
- **Acceptance**: `nvim --headless +checkhealth +w! /tmp/h.txt +qa` does NOT emit `E21 Cannot make changes`.
- **Falsifier**: same E21 message appears.

### S5 — Fix D-3: complete snacks setup
- **Action**: edit `nvim-config/lua/plugins/user.lua` snacks block (currently only configures `dashboard`). Add: `input = { enabled = true }`, `picker = { ui_select = true }` so `vim.ui.input` / `vim.ui.select` are bound. Optionally enable `bigfile`, `quickfile`, `notifier`, `bufdelete`, `words`, `zen`.
- **Acceptance**: headless health probe shows `vim.ui.input is set to Snacks.input` ✓.
- **Falsifier**: still shows `not set to Snacks.input`.

### S6 — Fix D-4: silence snacks image module (no LaTeX/PDF aesthetic ask)
- **Action**: in snacks opts, set `image = { enabled = false }`. Optionally add ghostscript to `just deps` if user wants doc-image rendering later.
- **Acceptance**: snacks image-related ERRORs disappear from health.
- **Falsifier**: gs/tectonic/kitty errors still present.

### S7 — Fix D-5: drop conflicting `<C-h/j/k/l>` keymaps in astrocore.lua
- **Action**: delete lines 212-215 of `nvim-config/lua/plugins/astrocore.lua` (the `<C-h/j/k/l>` window-nav block). Smart-splits owns these.
- **Acceptance**: health probe Conflicting mappings warning empty.
- **Falsifier**: warning still present.

### S8 — Fix D-6: drop nvim-colorizer (keep nvim-highlight-colors via astrocommunity)
- **Action**: delete the `norcalli/nvim-colorizer.lua` block in `nvim-config/lua/plugins/user.lua` lines 189-207.
- **Acceptance**: `:Lazy` shows only one of the two.
- **Falsifier**: both still present.

### S9 — Fix D-7: address `opts.jump.float` deprecation
- **Action**: grep all plugin opts for `jump = { float = ` and migrate per the plugin's current API. Likely flash.nvim — replace with current jump options.
- **Acceptance**: no deprecation warning in health.
- **Falsifier**: warning persists.

### S10 — Fix D-8: explicitly disable unused providers
- **Action**: add to `nvim-config/init.lua` (after lazy bootstrap, before requires): `vim.g.loaded_python3_provider = 0`, `vim.g.loaded_perl_provider = 0`, `vim.g.loaded_ruby_provider = 0`, `vim.g.loaded_node_provider = 0` (or install pynvim if user uses :py3 — they don't seem to).
- **Acceptance**: provider warnings absent from health.
- **Falsifier**: still listed.

### S11 — Pin AstroNvim version `^6`
- **Action**: edit `nvim-config/lua/lazy_setup.lua` to add `version = "^6"` to the AstroNvim entry. Also set `defaults = { version = "*" }` for non-pinned safety.
- **Acceptance**: `:Lazy` shows AstroNvim version locked to v6.x; `:checkhealth astronvim` shows v6.
- **Falsifier**: stuck on v5 or fails to update.

### S12 — Refresh lazy-lock.json under repo
- **Action**: after S3-S11 edits, run headless `+Lazy! sync +qa` against repo via `NVIM_APPNAME=nvim-pristine` symlink. Copy resulting `~/.config/nvim-pristine/lazy-lock.json` back into repo's `nvim-config/`.
- **Acceptance**: `lazy-lock.json` has commits matching live snapshot.
- **Falsifier**: lazy-lock.json absent or empty.

### S13 — Build `justfile` at repo root
- **Action**: write `justfile` (root) with 15 recipes: `default`, `doctor`, `deps`, `backup`, `install-side`, `install`, `sync`, `health`, `format`, `lint`, `update-lock`, `rollback`, `uninstall`, `try`, `theme`, `bench`. Use dotfiles symlink-with-backup pattern.
- **Acceptance**: `just --list` shows all recipes; `just --evaluate` parses without error; each recipe is documented with `# 🎯 desc` comment.
- **Falsifier**: parse error or missing recipe.

### S14 — Build helper scripts under `scripts/`
- **Action**: `scripts/install-nvim-config.sh` (symlink-with-backup), `scripts/uninstall-nvim-config.sh` (revert), `scripts/nvim-health.sh` (headless + grep ERROR), `scripts/nvim-bench.sh` (hyperfine wrapper). All with `#!/usr/bin/env bash` + `set -euo pipefail`.
- **Acceptance**: `shellcheck scripts/*.sh` passes.
- **Falsifier**: any shellcheck error.

### S15 — Side-by-side test: `just install-side` against fresh slot
- **Action**: `rm -rf ~/.config/nvim-pristine ~/.local/share/nvim-pristine`; run `just install-side`; verify install succeeds.
- **Acceptance**: `~/.config/nvim-pristine` is a symlink to `nvim-config/`; `:Lazy` loads; `:checkhealth` passes SC-1.
- **Falsifier**: any non-zero exit, dangling symlink, or ERROR rows.

### S16 — 3 parallel adversarial reviews (DISPATCH, do not wait)
- **Dispatch in single message**:
  - `el-demoledor` → "Break this nvim config. Find runtime failures, edge cases, race conditions, what happens when user opens a 100MB file, what happens with no internet on first install, what kills startup."
  - `ux-designer-magician` → "Attack the aesthetic and UX. Visual hierarchy, cognitive load, theme readability, dashboard friction, statusline density, motion / animation distraction. Be brutal."
  - `product-genius` → "Attack productivity. Keybind discoverability, time-to-value for new files, friction in core flows (git, LSP, search, file nav), missing essentials, opinionated defaults that fight the user."
- **Acceptance**: 3 receipts under `verification/adversarial-receipts/{el-demoledor,ux-designer-magician,product-genius}.md`.
- **Falsifier**: missing receipt or generic boilerplate.

### S17 — Address adversarial findings
- **Action**: per receipt finding: ACCEPTED (apply fix in nvim-config/) | REBUTTED (with concrete reason) | DEFERRED (with target task). Each finding gets a row in `verification/adversarial-resolutions.md`.
- **Acceptance**: every BLOCKING/HIGH finding has Accepted or Rebutted (Deferred allowed only with explicit reason); ≤50% deferred overall.
- **Falsifier**: any BLOCKING/HIGH left as DEFER without reason.

### S18 — Final health probe + bench
- **Action**: re-run `just health` (zero ERROR check); run `just bench` (hyperfine 5 runs); confirm SC-1 / SC-2.
- **Acceptance**: health log clean; p95 cold start ≤ 130 ms.
- **Falsifier**: any ERROR row; p95 > 130 ms.

### S19 — User decision point: swap live install
- **Action**: ASK user (AskUserQuestion) — "Side-by-side validated. Swap your daily ~/.config/nvim to the new install? (backup auto-created)"
- **Acceptance**: explicit yes → run `just install`; explicit no → leave side-by-side for user to test more.
- **Falsifier**: implicit assumption either way.

### S20 — Commit + close task
- **Action**: stage `nvim-config/`, `justfile`, `scripts/`, `_archive/`, `.ai/tasks/.../`; write commit message; ASK user before commit (NN-4 git mutation).
- **Acceptance**: clean tree post-commit; verification artifacts on disk.

## Frame attacks (Frame composition rule — multiple triggers, all named)
- **el-demoledor**: at S16 (break-config adversarial)
- **ux-designer-magician**: at S16 (aesthetic adversarial)
- **product-genius**: at S16 (productivity adversarial)
- **socrates-contrarian**: at P3 universe-fit (run inline during P3 self-review since we did question route-flips at multiple points via AskUserQuestion — actually [ROI-NEGATIVE: route already locked by user, no further route-flips identified after capture decision; socrates dispatch at S16 alongside ux/product]). **Decision**: replace one of the three above? No — keep 3 user-requested + add socrates if context allows. Plan: dispatch all 3 user-requested in parallel. Save socrates for P8 verification-method attack.
- **kant-cognitive-scientist**: control-plane artifact = yes (this nvim config governs future editing behavior). Trigger applies. **Action**: invoke kant at P8 to attack the verification methodology (not the config itself).
- **linus-torvalds**: architecture review trigger. **[ROI-NEGATIVE: nvim plugin config is not a coupling-prone subsystem; linus output overlap with el-demoledor's break-it stance]**.

## Manifest update commitments
- `created_files`: every new file written gets appended
- `modified_files`: every existing file edited gets appended
- `pending_adversarial_dispatches`: populated at S16 dispatch, cleared at S17 receipt synthesis
- `runtime_attacks`: each step's executable runtime probe (e.g., health log grep) recorded
- `gate_witnesses`: each SC verifier command output saved as evidence

## Risk register
- **R1 — Snacks setup change breaks existing dashboard**: mitigated by keeping current `dashboard.preset.header` ASCII art intact; only adding `input`/`picker.ui_select` keys.
- **R2 — AstroNvim v6 pin breaks blink.cmp**: mitigated by side-by-side install BEFORE swap; SC-3 catches.
- **R3 — `lazy-lock.json` drift between machines**: mitigated by `update-lock` recipe being explicit, gated by commit.
- **R4 — `astrocommunity.pack.python` may not exist either** (D-1 fix): probe the astrocommunity repo before edit; have fallback to `astrocommunity.pack.python-ruff-typed` or to manual ensure_installed list.
