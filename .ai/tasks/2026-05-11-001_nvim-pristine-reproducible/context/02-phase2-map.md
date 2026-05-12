---
task_id: 2026-05-11-001
agent: coordinator
status: complete
summary: P2 map — repo state, live deployed config, runtime probes, dotfiles justfile pattern.
---

# Phase 2 — Map Summary

## Map-delta-first (git state at P2 entry)
- branch: `main`
- dirty: `.vscode/settings.json` (pre-existing, not ours)
- untracked: `.ai/` (our task workspace)
- history: 9 commits total, last = `319f896 docs: fix readme`. CI tweaks dominate (stylua-action attempts). Project is early-stage / barely populated.
- No prior `.ai/tasks/` work for this repo — first task. New ground.

## Repo source-of-truth audit (`nvchad-config/` — NvChad-flavored, not deployed)
- `lua/{autocmds,bootstrap,chadrc,mappings,options}.lua` + `lua/configs/{conform,lazy,lspconfig}.lua` + `lua/gale/*` (custom namespace) + `lua/plugins/{init,spec/*,local/*}` (86 spec files)
- **Dead duplicates**: `crates copy.lua`, `gitsigns copy.lua` (clearly abandoned scratch)
- `Makefile` + `scripts/update-lazy-imports.lua` (auto-import generator)
- `themes/catppuccin-frape.lua` (single theme)
- `test_lsp_files/` (live LSP test files in 9 languages — useful for verification)
- `docs/01-gale-custom-configurations.md`, `docs/02-plugins.md`
- **Not deployed anywhere** — orphaned reference design.

## Live deployed config (`~/.config/nvim`)
- **AstroNvim v5.3.15** + Neovim 0.12.2
- Structure: `init.lua` → `lua/lazy_setup.lua` → `lua/community.lua` → `lua/polish.lua` + `lua/plugins/{astrocore,astrolsp,astroui,mason,none-ls,treesitter,user}.lua`
- 14 AstroCommunity language packs (lua, go, rust, typescript, python-ruff, terraform, yaml, docker, helm, bash, json, toml, markdown, just)
- 71 plugins total; 12 eager-loaded (good lazy discipline)
- Theme: kanagawa.nvim "wave", transparent, ~50 custom highlight overrides for TreeSitter / LSP semantic tokens
- Dashboard: snacks.nvim with custom "ASTRO NVIM" ASCII art
- Mason auto-installs ~40 DevOps tools (terraform-ls, gopls, ts_ls, pyright, ruff, yamlls, helm-ls, hadolint, actionlint, etc.)
- `polish.lua`: 14 filetype-specific autocmds (terraform, go, justfile, yaml, markdown, docker, json, toml, ts/js, python, gitcommit) + terminal handling + yank highlight + trailing-whitespace + return-to-last-position

## Runtime probes
- **Startup**: 112.926 ms cold (NVIM STARTED at 112). Lazy `LazyDone = 55ms`, `LazyStart = 11ms`.
- **Lazy stats**: count=71, loaded=12. Lazy-loading discipline is solid.
- **`:checkhealth` results**: full output at `context/probes/live-checkhealth.txt` (452 lines, 23.7 KB). Concrete defects:
  - ❌ `astrocommunity.pack.python-ruff` — module not found (renamed upstream)
  - ❌ snacks `setup did not run`; `vim.ui.input`/`vim.ui.select` not bound to Snacks
  - ❌ Tools missing: `gs` (ghostscript), `tectonic`/`pdflatex`, `luarocks` (snacks docs/image rendering deps)
  - ❌ `polish.lua:42` autocmd: `E21 Cannot make changes, 'modifiable' is off` (trailing-whitespace autocmd fires on non-modifiable buffers — REAL BUG, fires on `:checkhealth` save)
  - ⚠️ `<C-h/j/k/l>` keymap conflict: smart-splits "Move to {dir} split" vs astrocore.lua "Move to {dir} window"
  - ⚠️ Missing Treesitter parsers (snacks image-render dependency)
  - ⚠️ Language providers: pynvim 0.6.0, neovim-ruby-host, Neovim::Ext (Perl) all absent — silenceable if not used
  - ⚠️ `opts.jump.float` deprecated, removal in Nvim 0.14
  - ⚠️ `gdu`/`btm` optional disk/system monitors absent

## Dotfiles justfile pattern (mirror target)
- Located at `/Users/alextorresruiz/Dropbox/@GITHUB/@oss/dotfiles/justfile` (592 lines)
- Patterns to mirror:
  - **Symlink-with-backup** (Ghostty example, lines 453-525): backup existing file with timestamp before symlinking, verify readability post-symlink, restore-on-uninstall pattern
  - **`extract` ↔ `install` recipe pairs** for every tool (zsh, aws, git, npm, go, rust, starship)
  - **Verbose modes** via `-verbose` suffix variants
  - **Orchestrator recipe** `mac-setup-all` chains atomic recipes
  - **Validation recipes** (`aliases-validate`, `aliases-validate-verbose`) check post-install state
  - **Deprecation messages** for old recipe names with redirect (`aliases-install` → see `aliases-validate`)
  - **Common shell prelude**: `set -uce` / `set dotenv-load` / scripts use `#!/usr/bin/env bash` + `set -euo pipefail`
  - **Backups dir convention**: `<tool>/backups/<file>-<timestamp>`
  - **Theme/preset switching** (Ghostty section): `ghostty-switch preset` recipe with backup-before-switch

## Tooling inventory (macOS, Apple Silicon)
- `nvim 0.12.2` ✅ (`/opt/homebrew/bin/nvim`)
- `stylua` ✅, `just` ✅, `rg` ✅, `fd` ✅, `lazygit` ✅, `fzf` ✅
- `node v24.2.0`, `python3`, `go` ✅
- `timeout`, `hyperfine`, `gtimeout` ❌ — need `coreutils` + `hyperfine` from brew
- `gs` (ghostscript), `tectonic`/`pdflatex`, `luarocks` ❌ — only needed if we want snacks PDF/LaTeX rendering (probably not for hacker-aesthetic)

## Decisions ratified by user (P1 → P2 corrections)
- AstroNvim v5 (was v4 in my initial map) is the **chassis**.
- Live `~/.config/nvim` content is **substantive**, not stock — captured into the repo as new source of truth.
- Aggressive modernization on top, refined-hacker-dark aesthetic, macOS-only install, side-by-side testing via `NVIM_APPNAME=nvim-pristine` then backup-and-swap, justfile-driven.
- 3 parallel adversarials at delivery: break-the-config / attack-aesthetic / attack-productivity.

## Open questions deferred to P3
- Snacks consolidation depth — fold dashboard+picker+terminal+notifier into snacks, or keep current toggleterm + telescope + snacks-dashboard split?
- Theme choice: stick with Kanagawa Wave (already excellent) or switch to Tokyo Night Storm / Catppuccin Mocha / Cyberdream for "hackier"?
- Pinning policy: `lazy-lock.json` only, or also branch-pin AstroNvim to `stable` vs `main`?
- Decommission `nvchad-config/` (delete) vs `_archive/nvchad-config/` (preserve)?
