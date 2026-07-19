#!/usr/bin/env bash
# nvim-health.sh — run :checkhealth headlessly, dump to log, grep for ERROR rows.
# Exits non-zero if any ERROR row is present.
set -euo pipefail

# Hardened PATH: prefer Homebrew + system bins, exclude $HOME/.local/bin
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

readonly APPNAME="${1:-nvim-pristine}"
readonly OUT_ROOT="${OUT_DIR:-/tmp/nvim-health-$APPNAME}"
mkdir -p "$OUT_ROOT"
readonly RUN_DIR="$(mktemp -d "$OUT_ROOT/run.XXXXXX")"
readonly LOG="$RUN_DIR/health.log"
readonly NVIM_LOG="$RUN_DIR/nvim.log"
readonly HEADLESS_CHECKS="astrocore astronvim lazy telescope vim.deprecated vim.health vim.lsp vim.pack vim.provider vim.treesitter"

export NVIM_APPNAME="$APPNAME"
export NVIM_HEALTH_LOG="$LOG"

echo "Running headless-safe health providers (appname=$APPNAME); writing $LOG"
set +e
nvim --headless -c "checkhealth $HEADLESS_CHECKS" \
  -c 'lua vim.cmd("silent write! " .. vim.fn.fnameescape(vim.env.NVIM_HEALTH_LOG))' \
  -c "qa!" 2>&1 | tee "$NVIM_LOG"
readonly nvim_status=${PIPESTATUS[0]}
set -e
if (( nvim_status != 0 )); then
  echo "Neovim health command failed (status=$nvim_status)." >&2
  exit "$nvim_status"
fi
tail -3 "$NVIM_LOG"

if [[ ! -s "$LOG" ]]; then
  echo "❌ Health log is empty — :checkhealth probably failed to capture output." >&2
  exit 2
fi

readonly LINES=$(wc -l < "$LOG")
echo "   📄 captured $LINES lines"

# Extract error/warning summary
echo ""
echo "═══ ERROR rows ═══"
errors="$(grep -cE '^- ❌' "$LOG" || true)"
warnings="$(grep -cE '^- ⚠️' "$LOG" || true)"
ok_count="$(grep -cE '^- ✅' "$LOG" || true)"

grep -E '^- ❌' "$LOG" || echo "   (none)"
echo ""
echo "═══ Counts ═══"
printf '   ✅ OK: %s\n' "$ok_count"
printf '   ⚠️  WARNING: %s\n' "$warnings"
printf '   ❌ ERROR: %s\n' "$errors"

if (( errors > 0 )); then
  echo ""
  echo "❌ Health check FAILED: $errors ERROR row(s)"
  echo "   Full log: $LOG"
  exit 1
fi

echo ""
echo "✅ Health check PASSED (no ERROR rows)"
echo "   Full log: $LOG"
