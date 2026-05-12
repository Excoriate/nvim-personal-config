#!/usr/bin/env bash
# nvim-install.sh — symlink the repo's nvim-config/ into the user's XDG config under
# a chosen NVIM_APPNAME slot. Backups the existing slot first.
#
# Usage:
#   nvim-install.sh --appname nvim-pristine            # side-by-side (default)
#   nvim-install.sh --appname nvim --daily-driver      # promote to daily driver
set -euo pipefail

# Hardened PATH: prefer Homebrew + system bins, exclude $HOME/.local/bin
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
readonly SRC_DIR="$REPO_ROOT/nvim-config"
readonly XDG_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"

appname="nvim-pristine"
daily_driver=false

while (( $# )); do
  case "$1" in
    --appname)        appname="${2:?--appname needs a value}"; shift 2 ;;
    --daily-driver)   daily_driver=true; shift ;;
    -h|--help)
      grep -E '^# ' "$0" | sed 's/^# \{0,1\}//'
      exit 0 ;;
    *) printf 'Unknown arg: %s\n' "$1" >&2; exit 64 ;;
  esac
done

if [[ ! -d "$SRC_DIR" ]]; then
  echo "❌ Source not found: $SRC_DIR" >&2
  echo "   (repo layout broken — expected nvim-config/ in the repo root)" >&2
  exit 1
fi

readonly DEST="$XDG_CONFIG/$appname"
readonly LAZY_LOCK_SRC="$SRC_DIR/lazy-lock.json"

echo "🚀 Installing nvim-config -> $DEST  (appname: $appname)"

# 1) Backup if destination exists and is not already the desired symlink.
if [[ -L "$DEST" ]]; then
  current_target="$(readlink "$DEST")"
  if [[ "$current_target" == "$SRC_DIR" ]]; then
    echo "   ✅ Already symlinked correctly: $DEST -> $SRC_DIR"
    exit 0
  fi
  # F-11: record the previous target before replacement so rollback can find it.
  echo "   🔄 Replacing existing symlink ($current_target) with $SRC_DIR"
  echo "   💾 Recording previous symlink target in backup manifest"
  "$SCRIPT_DIR/nvim-backup.sh"
  rm "$DEST"
elif [[ -e "$DEST" ]]; then
  if $daily_driver; then
    # Daily-driver swap is destructive (replaces real ~/.config/nvim). Require
    # explicit confirmation unless DAILY_DRIVER_NONINTERACTIVE=1 (for CI/automation).
    if [[ "${DAILY_DRIVER_NONINTERACTIVE:-0}" != "1" ]]; then
      printf '\n⚠️  About to replace daily driver:\n   target: %s\n   source: %s\n\n' "$DEST" "$SRC_DIR" >&2
      printf 'A full backup will be taken first (restore with: just rollback).\n' >&2
      read -rp 'Proceed? [y/N] ' answer
      case "$(printf '%s' "$answer" | tr '[:upper:]' '[:lower:]')" in
        y|yes) : ;;
        *) echo "Aborted." >&2; exit 130 ;;
      esac
    fi
    echo "   💾 Backing up existing $DEST via nvim-backup.sh"
    "$SCRIPT_DIR/nvim-backup.sh"
    rm -rf "$DEST"
  else
    echo "❌ $DEST exists and is not a symlink." >&2
    echo "   Side-by-side install refuses to clobber a real directory." >&2
    echo "   Run with --daily-driver to backup-and-replace." >&2
    exit 1
  fi
fi

# 2) Ensure parent + symlink.
mkdir -p "$XDG_CONFIG"
ln -s "$SRC_DIR" "$DEST"

# 3) Verify readability (catches Dropbox Smart Sync evicting files).
if ! test -r "$DEST/init.lua"; then
  echo "❌ Symlink created but $DEST/init.lua is not readable!" >&2
  echo "   (Possible cause: source files evicted by Dropbox Smart Sync / cloud sync)" >&2
  exit 1
fi

echo "   ✅ Symlink in place: $DEST -> $SRC_DIR"

# 4) Confirm lazy-lock.json present (reproducibility anchor)
if [[ -f "$LAZY_LOCK_SRC" ]]; then
  echo "   🔒 lazy-lock.json present: $(wc -l < "$LAZY_LOCK_SRC") lines"
else
  echo "   ⚠️  No lazy-lock.json in repo — plugin versions will float on first sync"
fi

echo ""
echo "📋 Next steps:"
if $daily_driver; then
  echo "   1. Open nvim: nvim"
  echo "   2. Wait for :Lazy to finish auto-sync"
  echo "   3. Run health: just health nvim"
  echo "   4. Rollback if needed: just rollback"
else
  echo "   1. First-run sync: just sync $appname"
  echo "   2. Try it:        just try"
  echo "   3. Health probe:  just health $appname"
  echo "   4. Promote to daily: just promote"
fi
