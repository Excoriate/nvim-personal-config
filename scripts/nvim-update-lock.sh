#!/usr/bin/env bash
# nvim-update-lock.sh — refresh the lazy-lock.json checked into the repo from the
# active install slot. Run after `just sync` produces a known-good state.
set -euo pipefail

# Hardened PATH: prefer Homebrew + system bins, exclude $HOME/.local/bin
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

readonly APPNAME="${1:-nvim-pristine}"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
readonly REPO_LOCK="$REPO_ROOT/nvim-config/lazy-lock.json"
# When installed as a symlink to repo, the live lock IS the repo lock; sync rewrites it.
# Otherwise (not symlinked), fall back to the XDG_CONFIG copy.
readonly XDG_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"
readonly LIVE_LOCK="$XDG_CONFIG/$APPNAME/lazy-lock.json"

if [[ ! -f "$LIVE_LOCK" ]]; then
  echo "❌ No lazy-lock.json at $LIVE_LOCK — run 'just sync $APPNAME' first" >&2
  exit 1
fi

if [[ "$(realpath "$LIVE_LOCK")" == "$(realpath "$REPO_LOCK")" ]]; then
  echo "✅ Live install IS the repo (symlinked) — lazy-lock.json already current"
  echo "   Lock file: $REPO_LOCK ($(wc -l < "$REPO_LOCK") lines)"
  exit 0
fi

echo "🔒 Copying $LIVE_LOCK -> $REPO_LOCK"
cp "$LIVE_LOCK" "$REPO_LOCK"
echo "✅ lazy-lock.json refreshed. Stage with: git add nvim-config/lazy-lock.json"
