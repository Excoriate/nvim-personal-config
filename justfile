# 🐚 Default shell + strict error handling
set shell := ["bash", "-uce"]
set dotenv-load := false

# --- Project Variables ---
NVIM_CONFIG_DIR  := "nvim-config"
LIVE_CONFIG_DIR  := env_var_or_default("XDG_CONFIG_HOME", env_var("HOME") + "/.config") + "/nvim"
SIDE_BY_SIDE_APPNAME := "nvim-pristine"
SIDE_CONFIG_DIR  := env_var_or_default("XDG_CONFIG_HOME", env_var("HOME") + "/.config") + "/" + SIDE_BY_SIDE_APPNAME
BACKUP_ROOT      := env_var("HOME") + "/.local/state/nvim-personal-config/backups"

# 📋 Default recipe: list all commands
default:
    @just --list --unsorted

# ════════════════════════════════════════════════════════════════════════════
# 🩺 Health / diagnostics
# ════════════════════════════════════════════════════════════════════════════

# 🩺 Pre-flight: verify all required + recommended tools are installed
doctor:
    @bash {{justfile_directory()}}/scripts/nvim-doctor.sh

# 🩺 Run :checkhealth headlessly; fail on any ERROR row
health appname=SIDE_BY_SIDE_APPNAME:
    @bash {{justfile_directory()}}/scripts/nvim-health.sh {{appname}}

# 🚦 Live status of the side-by-side install (Lazy + Mason)
status appname=SIDE_BY_SIDE_APPNAME:
    @NVIM_APPNAME={{appname}} nvim --headless +"lua print(vim.inspect(require('lazy').stats()))" +qa 2>&1 || true

# ⏱️  Cold-start benchmark (5 runs)
bench appname=SIDE_BY_SIDE_APPNAME:
    @bash {{justfile_directory()}}/scripts/nvim-bench.sh {{appname}}

# ════════════════════════════════════════════════════════════════════════════
# 📦 Dependencies
# ════════════════════════════════════════════════════════════════════════════

# 📦 Install required + recommended Homebrew packages
deps:
    @bash {{justfile_directory()}}/scripts/nvim-deps.sh

# 📦 Install optional doc/image rendering tools (ghostscript, tectonic)
deps-extras:
    @bash {{justfile_directory()}}/scripts/nvim-deps.sh --extras

# ════════════════════════════════════════════════════════════════════════════
# 💾 Backup / restore
# ════════════════════════════════════════════════════════════════════════════

# 💾 Snapshot current ~/.config/nvim + ~/.local/share/nvim to timestamped backup
backup:
    @bash {{justfile_directory()}}/scripts/nvim-backup.sh

# ↩️  Restore the most recent backup over ~/.config/nvim
rollback:
    @bash {{justfile_directory()}}/scripts/nvim-rollback.sh

# 📜 List available backups (most recent first)
list-backups:
    @ls -1t "{{BACKUP_ROOT}}" 2>/dev/null || echo "(no backups yet)"

# ════════════════════════════════════════════════════════════════════════════
# 🚀 Install
# ════════════════════════════════════════════════════════════════════════════

# 🧪 Side-by-side install under NVIM_APPNAME=nvim-pristine (safe; no daily impact)
install-side:
    @bash {{justfile_directory()}}/scripts/nvim-install.sh --appname {{SIDE_BY_SIDE_APPNAME}}

# 🚀 Install as daily driver (backs up existing ~/.config/nvim, symlinks repo)
install:
    @bash {{justfile_directory()}}/scripts/nvim-install.sh --appname nvim --daily-driver

# 🧪 Launch the side-by-side install
try:
    NVIM_APPNAME={{SIDE_BY_SIDE_APPNAME}} nvim

# 🔁 First-run sync: Lazy + Mason tools (headless)
sync appname=SIDE_BY_SIDE_APPNAME:
    @bash {{justfile_directory()}}/scripts/nvim-sync.sh {{appname}}

# 🗑️  Remove symlink + restore most recent backup (mirror of install)
uninstall appname=SIDE_BY_SIDE_APPNAME:
    @bash {{justfile_directory()}}/scripts/nvim-uninstall.sh {{appname}}

# ════════════════════════════════════════════════════════════════════════════
# 🎨 Theme switching
# ════════════════════════════════════════════════════════════════════════════

# 🎨 Switch active colorscheme (kanagawa-wave|kanagawa-dragon|tokyonight-storm|tokyonight-moon|catppuccin-mocha|cyberdream|rose-pine-moon)
theme name:
    @bash {{justfile_directory()}}/scripts/nvim-theme.sh {{name}}

# ════════════════════════════════════════════════════════════════════════════
# 🔒 Lock file management (reproducibility)
# ════════════════════════════════════════════════════════════════════════════

# 🔒 Refresh lazy-lock.json from a successful headless sync
update-lock appname=SIDE_BY_SIDE_APPNAME:
    @bash {{justfile_directory()}}/scripts/nvim-update-lock.sh {{appname}}

# ════════════════════════════════════════════════════════════════════════════
# 🧹 Code quality
# ════════════════════════════════════════════════════════════════════════════

# 🧹 Format Lua + shell sources in-place
format:
    @stylua {{NVIM_CONFIG_DIR}} scripts || true
    @command -v shfmt >/dev/null 2>&1 && shfmt -i 2 -ci -w scripts/*.sh || echo "shfmt not installed (optional)"

# ✅ Lint everything (Lua, shell, markdown)
lint:
    @stylua --check {{NVIM_CONFIG_DIR}} scripts
    @shellcheck scripts/*.sh
    @command -v markdownlint >/dev/null 2>&1 && markdownlint '**/*.md' --ignore _archive --ignore .ai || echo "markdownlint not installed (optional)"

# ✅ Stylua check only (CI-friendly)
lint-lua:
    @stylua --check {{NVIM_CONFIG_DIR}} scripts

# ✅ Shellcheck only
lint-shell:
    @shellcheck scripts/*.sh

# ════════════════════════════════════════════════════════════════════════════
# 🎁 Convenience composites
# ════════════════════════════════════════════════════════════════════════════

# 🚀 Full bootstrap: deps + side-by-side install + sync + health probe
bootstrap: deps install-side sync
    @echo ""
    @echo "✅ Bootstrap complete. Run 'just try' to launch the side-by-side install."
    @echo "   Health probe: just health"
    @echo "   When ready to swap your daily driver: just install"

# 🎉 Daily-driver promotion: backup + install + sync + health
promote: backup install sync
    @echo ""
    @echo "✅ Daily-driver promoted. Run 'nvim' to confirm."
    @echo "   Rollback: just rollback"
