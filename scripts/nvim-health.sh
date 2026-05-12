#!/usr/bin/env bash
# nvim-health.sh — run :checkhealth headlessly, dump to log, grep for ERROR rows.
# Exits non-zero if any ERROR row is present.
set -euo pipefail

# Hardened PATH: prefer Homebrew + system bins, exclude $HOME/.local/bin
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

readonly APPNAME="${1:-nvim-pristine}"
readonly OUT_DIR="${OUT_DIR:-/tmp/nvim-health-$APPNAME}"
mkdir -p "$OUT_DIR"
readonly LOG="$OUT_DIR/health.log"

export NVIM_APPNAME="$APPNAME"

echo "🩺 Running :checkhealth (appname=$APPNAME) — writing $LOG"
nvim --headless -c "checkhealth" -c "write! $LOG" -c "qa!" 2>&1 | tail -3 || true

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
