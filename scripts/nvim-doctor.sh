#!/usr/bin/env bash
# nvim-doctor.sh — verify that required + recommended tools for this config are installed.
# Exits 0 if all REQUIRED present; non-zero otherwise. Recommended tools warn only.
set -euo pipefail

# Hardened PATH: prefer Homebrew + system bins, exclude $HOME/.local/bin
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

readonly RED=$'\033[31m'
readonly GREEN=$'\033[32m'
readonly YELLOW=$'\033[33m'
readonly BLUE=$'\033[34m'
readonly DIM=$'\033[2m'
readonly RESET=$'\033[0m'

# Tool sets
readonly REQUIRED_TOOLS=(
  "nvim"      # Neovim editor
  "git"       # plugin manager + version control
  "rg"        # ripgrep, telescope/snacks live grep
  "fd"        # fast file finder
  "node"      # AstroNvim updater + several plugins
  "tree-sitter" # nvim-treesitter parser compiler
  "rustup"      # rustaceanvim's rust-analyzer toolchain owner
  "asciidoctor" # Vale's external processor for AsciiDoc files
)

readonly RECOMMENDED_TOOLS=(
  "stylua"     # Lua formatter
  "just"       # this justfile runner
  "lazygit"    # git TUI invoked by mappings
  "fzf"        # fuzzy finder
  "gtimeout"   # coreutils — needed by some health helpers
  "hyperfine"  # benchmark runner used by `just bench`
  "shellcheck" # shell linter
  "shfmt"      # shell formatter
)

readonly OPTIONAL_TOOLS=(
  "gs"        # ghostscript (snacks PDF rendering)
  "tectonic"  # LaTeX (snacks math rendering)
)

check() {
  local kind="$1" tool="$2" resolved=""
  if [[ "$tool" == "rustup" && -x "$HOME/.cargo/bin/rustup" ]]; then
    resolved="$HOME/.cargo/bin/rustup"
  else
    resolved="$(command -v "$tool" 2>/dev/null || true)"
  fi
  if [[ -n "$resolved" ]]; then
    printf '%s ✅%s %-12s -> %s\n' "$GREEN" "$RESET" "$tool" "$resolved"
    return 0
  fi
  case "$kind" in
    required)    printf '%s ❌%s %-12s MISSING (install: brew install %s)\n' "$RED" "$RESET" "$tool" "$tool" ;;
    recommended) printf '%s ⚠️%s  %-12s missing (recommended)\n' "$YELLOW" "$RESET" "$tool" ;;
    optional)    printf '%s ·%s  %-12s missing (optional)\n' "$DIM" "$RESET" "$tool" ;;
  esac
  return 1
}

printf '%s───%s nvim-personal-config doctor %s───%s\n' "$BLUE" "$DIM" "$BLUE" "$RESET"

# Neovim version check
if command -v nvim >/dev/null 2>&1; then
  nvim_version="$(nvim --version | head -1 | awk '{print $2}')"
  printf '%s ℹ️%s  Neovim: %s (require >= 0.11)\n' "$BLUE" "$RESET" "$nvim_version"
fi

# Nerd font (best-effort heuristic)
if fc-list 2>/dev/null | grep -qi 'nerd font' 2>/dev/null; then
  printf '%s ✅%s nerd-font   installed (fc-list)\n' "$GREEN" "$RESET"
else
  printf '%s ⚠️%s  nerd-font   could not detect via fc-list; visually verify icons render\n' "$YELLOW" "$RESET"
fi

# Terminal capabilities
case "${TERM_PROGRAM:-}" in
  ghostty|Ghostty|kitty|iTerm.app|WezTerm)
    printf '%s ✅%s terminal    %s (modern feature set)\n' "$GREEN" "$RESET" "$TERM_PROGRAM" ;;
  *)
    printf '%s ⚠️%s  terminal    %s (modern terminal recommended for smear-cursor / image render)\n' "$YELLOW" "$RESET" "${TERM_PROGRAM:-unknown}" ;;
esac

echo ""
echo "REQUIRED:"
missing_required=0
for t in "${REQUIRED_TOOLS[@]}"; do check required "$t" || missing_required=$((missing_required + 1)); done

echo ""
echo "RECOMMENDED:"
for t in "${RECOMMENDED_TOOLS[@]}"; do check recommended "$t" || true; done

echo ""
echo "OPTIONAL (snacks image rendering):"
for t in "${OPTIONAL_TOOLS[@]}"; do check optional "$t" || true; done

echo ""
if (( missing_required > 0 )); then
  printf '%s ❌ %d required tool(s) missing — run: just deps%s\n' "$RED" "$missing_required" "$RESET"
  exit 1
fi
printf '%s ✅ All required tools present.%s\n' "$GREEN" "$RESET"
