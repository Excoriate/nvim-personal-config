---
task_id: 2026-05-11-001
agent: librarian
status: complete
summary: AstroNvim ecosystem currency check + 2026 plugin recommendations + theme + justfile recipe shape.
---

# Phase 4 — Librarian Currency Findings

## AstroNvim version state
- **Current live**: v5.3.15 (per `:checkhealth`)
- **Latest released**: v6.0.4 (2026-04-07)
- **Drift**: 1 major behind (not 2 — librarian initial assumption was v4)
- **v5 migrations already applied to user's config** (per `lazy-lock.json`): blink.cmp ✓, mini.icons ✓, snacks.dashboard ✓
- **v5 migrations still pending**: nvim-colorizer (still installed, should drop in favor of nvim-highlight-colors which is ALSO installed — duplication)
- **v6 incremental change**: vim-illuminate → snacks.words (user still has vim-illuminate)
- **v6 requires Nvim ≥ 0.11**: user has 0.12.2 ✓
- **Recommended pin**: `version = "^6"` on the AstroNvim spec in `lazy_setup.lua` for semver-major reproducibility.

## Plugin drift / cleanup
| Plugin | Status | Action |
|---|---|---|
| `nvim-colorizer.lua` | Superseded by `nvim-highlight-colors` (v5+ blessed). User has BOTH installed → drift. | **Drop nvim-colorizer** |
| `lsp_signature.nvim` | Redundant — `blink.cmp` ships built-in signature help | **Drop** |
| `git-blame.nvim` | Redundant — `gitsigns` has inline blame (`current_line_blame`) | **Drop or keep — low cost** |
| `vim-illuminate` | Active but AstroNvim v6 prefers `snacks.words` for same UX | **Replace with snacks.words on v6 upgrade** |
| `none-ls.nvim` | "Beta", momentum shifted | **Replace with `nvim-lint` + `conform.nvim`** (already disabled with `if true then return {} end` so neutral) |
| `zen-mode.nvim` | `snacks.zen` consolidates | **Drop or keep — low cost** |
| `vim-fugitive` | Gold standard for `:Git`, but `snacks.lazygit + gitsigns` covers 90% | **Keep** |
| `astrocommunity.pack.python-ruff` | **RENAMED** — module not found in current astrocommunity | **Fix: switch to `astrocommunity.pack.python` (or verify new name)** |

## Killer additions (DevOps stack, 2026)
1. **CodeCompanion.nvim** (v19.13.0, 6.6k★) — Anthropic/OpenAI/Copilot/MCP AI integration. Picked over avante (v0.0.29, "rapid iteration") for stability. **Add if user wants AI**.
2. **which-key.nvim v3** — Already bundled by AstroNvim; we should add explicit `spec` groups for DevOps mappings (`<leader>t*` terraform, `<leader>g*` git, etc.) for discoverability.
3. **snacks consolidation** — Pull in `snacks.zen`, `snacks.input`, `snacks.notifier`, `snacks.scratch`, `snacks.bigfile`, `snacks.bufdelete`, `snacks.words` from existing snacks dep.
4. **fzf-lua** — Optional speed king for huge repos (multiprocessing fzf binary). Keep telescope alongside for `telescope-terraform-doc`.

## Theme decision
Kanagawa Wave + custom highlight overrides is already a tier-1 hacker-dark choice. Plausible alternates:
- `tokyonight.nvim` Storm/Moon (v4.14.1, 8k★) — most polished, broadest plugin coverage
- `cyberdream.nvim` (v5.4.0, 1.3k★) — strongest "neon hacker" aesthetic, transparency-first
- `rose-pine` moon (v3.0.2, 3k★) — explicit TS+LSP semantic tokens

**Verdict**: Keep Kanagawa Wave as default. Add `tokyonight` + `cyberdream` as installed-but-not-active alternates, with a `just nvim-theme <name>` switcher recipe. Hacker mode = `just nvim-theme cyberdream` flips a `colorscheme` setting.

## Justfile recipe shape (synthesized from dotfiles pattern + librarian)
1. `deps` — verify/install brew deps (nvim, stylua, just, rg, fd, lazygit, fzf, coreutils, hyperfine, ghostscript optional, nerd-font cask)
2. `backup` — backup `~/.config/nvim` + `~/.local/share/nvim/{lazy,mason,state}` to `~/Backups/nvim-{timestamp}/`
3. `install-side` — `NVIM_APPNAME=nvim-pristine` side-by-side install for testing
4. `install` — symlink repo's `nvim-config/` → `~/.config/nvim/` with timestamped backup
5. `sync` — headless `+Lazy! sync +MasonToolsUpdateSync +qa`
6. `health` — headless `+checkhealth` to file, grep for `ERROR`/`WARNING`, fail on ERROR
7. `format` — stylua --check + shfmt -d
8. `lint` — stylua + shellcheck + markdownlint
9. `update-lock` — `+Lazy! update +qa` then commit `lazy-lock.json`
10. `rollback` — restore from most-recent `~/Backups/nvim-*/` and prompt for confirmation
11. `uninstall` — remove symlink, restore latest backup
12. `try` — launch the side-by-side install (`NVIM_APPNAME=nvim-pristine nvim`)
13. `doctor` — wraps `health` + reports diagnostic summary
14. `theme name` — switch colorscheme atomically
15. `bench` — `hyperfine 'nvim --headless +qa'` 5 runs

## Confidence / risk
- HIGH: AstroNvim v6 currency, blink.cmp/mini.icons/snacks already in lock, none-ls beta status
- MEDIUM: telescope-terraform-doc has no snacks.picker equivalent verified — keep telescope alongside snacks.picker
- LOW: No formal v5→v6 migration guide — highlight overrides may need re-validation (Kanagawa compile = true catches most)
