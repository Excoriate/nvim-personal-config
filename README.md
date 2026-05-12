# nvim-personal-config

[![License](https://img.shields.io/github/license/Excoriate/nvim-personal-config)](LICENSE)
[![CI](https://github.com/Excoriate/nvim-personal-config/actions/workflows/ci.yml/badge.svg)](https://github.com/Excoriate/nvim-personal-config/actions/workflows/ci.yml)

A pristine, production-ready, reproducible Neovim configuration built on **AstroNvim v6** with an opinionated DevOps stack (Terraform, Go, Rust, TypeScript, Python/uv, Kubernetes/Helm, Docker, YAML, Justfile).

## What you get

- **AstroNvim v6.0.4** chassis pinned via semver `^6` + `lazy-lock.json` for bit-identical installs.
- **14 AstroCommunity language packs**: lua, go, rust, typescript, python (base + basedpyright + ruff), terraform, yaml, docker, helm, bash, json, toml, markdown, just.
- **Refined hacker-dark aesthetic**: Kanagawa Wave with 50+ TreeSitter + LSP semantic-token highlight overrides, transparent floats, smear-cursor animation.
- **Snacks consolidation**: dashboard (custom ASCII), bigfile, bufdelete, input, notifier, picker, quickfile, scroll, scratch, words, zen. Replaces nvim-notify, indent-blankline, zen-mode, vim-illuminate.
- **DevOps-grade Mason set**: ~40 tools auto-installed (terraform-ls, gopls, ts_ls, ruff, basedpyright, hadolint, helm-ls, actionlint, shellcheck, shfmt, jq, taplo, vale, etc.).
- **One-command install** via a Homebrew + Justfile pipeline mirroring the dotfiles repo pattern: backup-with-timestamp, side-by-side test under `NVIM_APPNAME=nvim-pristine`, atomic promote, single-command rollback.
- **Cold start ~100 ms** on a 12 eager-loaded / 69-total plugin set.

## Quickstart

```bash
# 1. Verify your machine has the deps
just doctor

# 2. One-shot bootstrap: deps + side-by-side install + first-run sync
just bootstrap

# 3. Try it WITHOUT touching your daily ~/.config/nvim
just try

# 4. Verify health
just health

# 5. When satisfied, promote to daily driver (auto-backup + confirmation prompt)
just promote
```

## Justfile recipe map

```text
just                        # list all recipes
just doctor                 # verify deps + nvim version + terminal capabilities
just deps                   # install required Homebrew formulae + Nerd Font cask
just deps-extras            # + ghostscript / tectonic (snacks PDF/LaTeX rendering)
just backup                 # snapshot ~/.config/nvim + ~/.local/share/nvim
just install-side           # symlink repo -> ~/.config/nvim-pristine (safe)
just install                # symlink repo -> ~/.config/nvim (with backup + prompt)
just sync                   # first-run :Lazy + :MasonToolsUpdateSync (headless)
just health                 # :checkhealth headless; fail on ERROR rows
just bench                  # hyperfine cold-start (or startuptime fallback)
just status                 # Lazy plugin stats
just rollback               # restore most recent backup (interactive)
just uninstall              # remove a symlinked install
just list-backups           # list saved backups (newest first)
just try                    # launch the side-by-side install
just theme <name>           # switch colorscheme (kanagawa-wave|tokyonight-storm|...)
just format                 # stylua + shfmt in-place
just lint                   # stylua --check + shellcheck + markdownlint
just update-lock            # refresh lazy-lock.json after a successful sync
just bootstrap              # deps + install-side + sync (full first-run)
just promote                # backup + install + sync (daily-driver swap)
```

## Architecture

```text
nvim-personal-config/
├── nvim-config/                 # the actual Neovim configuration (source of truth)
│   ├── init.lua                 # bootstraps lazy.nvim, disables unused providers
│   ├── lazy-lock.json           # PINNED plugin commits (committed; reproducible)
│   ├── lua/
│   │   ├── lazy_setup.lua       # AstroNvim spec (version="^6"), rocks disabled
│   │   ├── community.lua        # AstroCommunity language + motion packs
│   │   ├── polish.lua           # filetype autocmds, vim.ui rebind, last-position
│   │   └── plugins/
│   │       ├── astrocore.lua    # vim options + keymaps (smart-splits owns C-hjkl)
│   │       ├── astrolsp.lua     # LSP per-server settings, format_on_save
│   │       ├── astroui.lua      # colorscheme = kanagawa + icons
│   │       ├── mason.lua        # mason-tool-installer DevOps tool set
│   │       ├── treesitter.lua   # (disabled stub; community.lua handles parsers)
│   │       ├── none-ls.lua      # (disabled stub; conform.nvim via community)
│   │       └── user.lua         # kanagawa overrides, snacks, crates, etc.
│   ├── .luarc.json
│   ├── .neoconf.json
│   ├── .stylua.toml
│   └── selene.toml
├── scripts/                     # bash 3.2-portable install helpers
│   ├── nvim-doctor.sh           # tooling/version sanity check
│   ├── nvim-deps.sh             # `brew install` orchestrator (--extras gates LaTeX/PDF)
│   ├── nvim-backup.sh           # timestamped snapshot (~/.local/state/.../backups)
│   ├── nvim-install.sh          # symlink + backup + confirmation (daily-driver mode)
│   ├── nvim-uninstall.sh        # reverse install
│   ├── nvim-rollback.sh         # restore latest backup (validates source first)
│   ├── nvim-sync.sh             # headless :Lazy! + Mason install
│   ├── nvim-health.sh           # headless :checkhealth + ERROR-row grep
│   ├── nvim-bench.sh            # hyperfine cold start
│   ├── nvim-theme.sh            # bash-3.2 portable theme switcher
│   └── nvim-update-lock.sh      # refresh lazy-lock.json from successful sync
├── justfile                     # public command surface (~20 recipes)
└── _archive/                    # historical configs (nvchad-config-pre-2026-05-11)
```

## Reproducibility contract

| Layer | Mechanism | Reproducibility guarantee |
|---|---|---|
| OS deps | `just deps` -> Homebrew formulae list | Same brew = same binaries |
| AstroNvim core | `version = "^6"` in lazy_setup.lua | Semver-minor updates allowed (v6.x); breaking v7 blocked |
| Plugin commits | `lazy-lock.json` committed in repo | `:Lazy! restore` -> exact commit pins |
| Mason tools | `ensure_installed` in `mason.lua` + AstroCommunity packs | Idempotent re-resolve on sync |
| Refresh contract | `just update-lock` regenerates lock after sync, must be committed | Lock evolves only via explicit user action |

## Keybind highlights

- **Leaders**: `<Leader>` = space, `<LocalLeader>` = comma
- **Buffer/window nav**: `H`/`L` next/prev buffer, `<C-h/j/k/l>` smart-split nav (tmux-aware), `<C-\>` toggleterm
- **Save/quit**: `<C-s>` save (needs `stty -ixon` in shell rc), `<Leader>w` portable save, `<C-q>` quit-all with `:confirm` prompt
- **Search**: `n`/`N` centered, `<Esc>` clear hl, `<Leader>fw` ripgrep
- **Git**: `<Leader>gg` Fugitive status, `[x`/`]x` conflict nav, `<Leader>gc{o,t,b,0}` conflict choose (does NOT shadow vim's `c{motion}` operators)
- **LSP**: `<Leader>ti/tv/tp` terraform init/validate/plan, `gd` definition, `gr` references, `K` hover, `<Leader>la` code action
- **Snacks**: `<Leader>z` zen, `<Leader>Z` zen-zoom, `<Leader>.` scratch, `<Leader>n` notification history, `<Leader>bD` delete buffer (keep layout)
- **Motion**: `<A-j>`/`<A-k>` move line(s) in n/v/i modes
- **Telescope**: `<Leader>ftd` Terraform Docs picker
- **Markdown**: `<Leader>mp` toggle preview

Press `<Leader>` and pause to see which-key with all groups.

## Known checkhealth noise (acceptable, non-blocking)

`:checkhealth` reports 6 ERROR rows on a fresh install. **None affect functionality**:

| Origin | Why we accept it |
|---|---|
| `snacks.image` × 4 (gs / tectonic / kitty graphics protocol) | The image module is **explicitly disabled** in our snacks opts. Snacks' checkhealth still probes the deps because the feature is opt-in. Install via `just deps-extras` if you want PDF/LaTeX rendering. |
| `snacks setup did not run` (×1) | Reported for the disabled image module. Same root cause. |
| `vim.ui.input` / `vim.ui.select` not Snacks (×2) | Snacks' wiring of `vim.ui.*` requires `User VeryLazy` to fire; headless `:checkhealth` exits before that event. Interactive sessions get the bindings via polish.lua's `User VeryLazy` autocmd. |

## Terminal recommendations

For best results: **Ghostty**, **WezTerm**, or **kitty**.

- Add to your shell rc to free `<C-s>`: `stty -ixon`
- tmux undercurl support: `set -as terminal-overrides ',*:U8=0:smulx=\E[4::%p1%dm:Smulx=\E[58:5:%p1%dm,Setulc=\E[58:5:%p1%dm'`
- Install a **Nerd Font** — JetBrainsMono Nerd Font is auto-installed by `just deps`

## Rollback / disaster recovery

Anything `just install` overwrites is timestamped at `~/.local/state/nvim-personal-config/backups/YYYYMMDD-HHMMSS/`.

```bash
just list-backups   # see what's available
just rollback       # restore most recent (asks for confirmation)
```

A working `~/.config/nvim` is recoverable as long as backups exist.

## License

MIT — see [LICENSE](LICENSE).

## Credits

- [AstroNvim](https://github.com/AstroNvim/AstroNvim) — the chassis
- [AstroCommunity](https://github.com/AstroNvim/astrocommunity) — language packs
- [orhun/dotfiles](https://github.com/orhun/dotfiles) — keymap inspiration
- [folke/snacks.nvim](https://github.com/folke/snacks.nvim) — UI consolidation
- [rebelot/kanagawa.nvim](https://github.com/rebelot/kanagawa.nvim) — colorscheme
