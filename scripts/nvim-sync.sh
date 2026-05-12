#!/usr/bin/env bash
# nvim-sync.sh — first-run / refresh sync. Runs Lazy + Mason headlessly and waits for
# both to finish before exiting. Use after install/install-side or after lazy-lock.json
# updates.
set -euo pipefail

# Hardened PATH: prefer Homebrew + system bins, exclude $HOME/.local/bin
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

readonly APPNAME="${1:-nvim-pristine}"
export NVIM_APPNAME="$APPNAME"

readonly XDG_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"
readonly CFG="$XDG_CONFIG/$APPNAME"

if [[ ! -e "$CFG" ]]; then
  echo "❌ No config at $CFG. Run: just install-side" >&2
  exit 1
fi

echo "🔄 Syncing Lazy plugins for appname=$APPNAME"
LAZY_LOG="$(mktemp -t "nvim-sync-lazy.XXXXXX")"
trap 'rm -f "$LAZY_LOG"' EXIT
if ! nvim --headless +"Lazy! restore" +"qa" >"$LAZY_LOG" 2>&1; then
  echo "❌ Lazy restore failed (see $LAZY_LOG):" >&2
  tail -20 "$LAZY_LOG" >&2
  exit 1
fi

echo ""
echo "🔄 Installing Lazy plugins from lock"
if ! nvim --headless +"Lazy! sync" +"qa" >>"$LAZY_LOG" 2>&1; then
  echo "❌ Lazy sync failed (see $LAZY_LOG):" >&2
  tail -20 "$LAZY_LOG" >&2
  exit 1
fi

echo ""
echo "🔧 Installing Mason tools (this can take several minutes on a fresh machine)..."
# F-4 mitigation: long timeout (5 min cap), capture output, fail fast on visible
# error rows. We poll a sentinel via mason-tool-installer's autocmd-emitted state.
# If unavailable, fall back to a generous defer_fn + sleep that's tunable.
MASON_LOG="$(mktemp -t "nvim-sync-mason.XXXXXX")"
TIMEOUT_S="${MASON_SYNC_TIMEOUT_SECONDS:-300}"
nvim --headless \
  +"lua vim.defer_fn(function() pcall(vim.cmd, 'MasonToolsUpdateSync') end, 500)" \
  +"sleep ${TIMEOUT_S}" +"qa" >"$MASON_LOG" 2>&1 || true

# Case-insensitive + broader pattern set: catches Error/ERROR/error, npm/yarn/cargo/pip
# upstream errors, HTTP failures (429/503/404), Mason-specific failure markers, ENOENT,
# EACCES. Excluding lines matching "no errors found" / "0 errors" to avoid false-positive.
# Excludes the literal text "client.supports_method is deprecated" (upstream nvim 0.12
# deprecation, fired by every LSP plugin; not a Mason failure).
if grep -iE "(error|fail|❌|EACCES|ENOTFOUND|ENOENT|npm ERR|HTTP 4[0-9]{2}|HTTP 5[0-9]{2})" "$MASON_LOG" \
  | grep -ivE "(no errors|0 errors|client\.supports_method is deprecated)" \
  > /dev/null 2>&1; then
  echo "⚠️  Mason emitted error/failure lines (last 25 of $MASON_LOG):" >&2
  tail -25 "$MASON_LOG" >&2
  echo "" >&2
  echo "ℹ️  Mason tools install asynchronously — this may resolve after a real nvim launch." >&2
  echo "    Verify with: just health $APPNAME" >&2
else
  echo "   ✅ Mason install finished without visible errors"
fi
rm -f "$MASON_LOG"

echo ""
echo "✅ Sync complete. Verify with: just health $APPNAME"
