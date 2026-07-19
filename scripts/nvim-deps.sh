#!/usr/bin/env bash
# nvim-deps.sh — install required Homebrew dependencies for this nvim config.
# Usage: nvim-deps.sh [--extras]
#   --extras  Also install optional ghostscript + tectonic (snacks doc/image rendering).
set -euo pipefail

# Hardened PATH: prefer Homebrew + system bins, exclude $HOME/.local/bin
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

readonly CORE_BREW=(
  neovim
  git
  ripgrep
  fd
  node
  tree-sitter-cli
  asciidoctor # Vale's external processor for AsciiDoc files
  stylua
  just
  lazygit
  fzf
  coreutils # gtimeout
  hyperfine # bench
  shellcheck
  shfmt
)

# Nerd font (cask). Use SymbolsOnly to overlay symbols into any base font, or pick a full font.
readonly CORE_CASK=(
  font-jetbrains-mono-nerd-font
)

readonly EXTRA_BREW=(
  ghostscript # gs for snacks PDF rendering
  tectonic    # snacks LaTeX math rendering
)

want_extras=false
for arg in "$@"; do
  case "$arg" in
    --extras|-x) want_extras=true ;;
    *)           printf 'Unknown arg: %s\n' "$arg" >&2; exit 64 ;;
  esac
done

if ! command -v brew >/dev/null 2>&1; then
  echo "❌ Homebrew not installed. Install from https://brew.sh first." >&2
  exit 1
fi

echo "📦 Installing Homebrew formulae..."
brew install "${CORE_BREW[@]}"

echo ""
echo "🍺 Installing Homebrew casks (Nerd Font)..."
brew install --cask "${CORE_CASK[@]}" || true

if $want_extras; then
  echo ""
  echo "📦 Installing optional extras (snacks doc/image rendering)..."
  brew install "${EXTRA_BREW[@]}"
fi

echo ""
echo "✅ Dependencies installed."
echo "💡 Run 'just doctor' to verify."
