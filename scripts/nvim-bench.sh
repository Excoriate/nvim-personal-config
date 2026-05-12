#!/usr/bin/env bash
# nvim-bench.sh — cold-start benchmark. Uses hyperfine when available; falls back to
# nvim --startuptime parsing otherwise.
set -euo pipefail

# Hardened PATH: prefer Homebrew + system bins, exclude $HOME/.local/bin
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

readonly APPNAME="${1:-nvim-pristine}"
export NVIM_APPNAME="$APPNAME"

echo "⏱️  Benchmarking nvim cold start (appname=$APPNAME)"
echo ""

if command -v hyperfine >/dev/null 2>&1; then
  hyperfine --warmup 1 --runs 5 \
    --command-name "nvim cold start ($APPNAME)" \
    "nvim --headless +qa"
else
  echo "ℹ️  hyperfine not installed — using nvim --startuptime fallback"
  LOG="$(mktemp /tmp/nvim-startup.XXXXXX.log)"
  nvim --startuptime "$LOG" --headless +qa 2>&1 || true
  echo ""
  echo "Last 5 startup lines (total in ms):"
  tail -5 "$LOG"
  echo ""
  echo "💡 Install hyperfine for proper statistics: brew install hyperfine"
fi
