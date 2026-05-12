#!/usr/bin/env bash
# nvim-uninstall.sh — remove a symlink installed by nvim-install.sh and (when present)
# restore the most recent backup over it. Refuses to delete a real directory.
set -euo pipefail

# Hardened PATH: prefer Homebrew + system bins, exclude $HOME/.local/bin
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

readonly APPNAME="${1:-nvim-pristine}"
readonly XDG_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"
readonly DEST="$XDG_CONFIG/$APPNAME"
readonly BACKUP_ROOT="${BACKUP_ROOT:-$HOME/.local/state/nvim-personal-config/backups}"

echo "🗑️  Uninstalling appname=$APPNAME at $DEST"

if [[ ! -L "$DEST" ]]; then
  if [[ -e "$DEST" ]]; then
    echo "⚠️  $DEST exists but is not a symlink — refusing to delete." >&2
    echo "   If you intend to replace a real directory, do it manually." >&2
    exit 1
  fi
  echo "   · nothing to do (no symlink found)"
  exit 0
fi

current="$(readlink "$DEST")"
rm "$DEST"
echo "   ✂️  removed symlink: $DEST -> $current"

# Restore most recent backup if --appname matches (only when removing nvim daily driver)
if [[ "$APPNAME" == "nvim" ]]; then
  # Timestamped subdirs are YYYYMMDD-HHMMSS (controlled by nvim-backup.sh), so
  # lexicographic descending sort == chronological newest. Safe under `find`.
  latest="$(find "$BACKUP_ROOT" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; 2>/dev/null | sort -r | head -1 || true)"
  if [[ -n "$latest" && -d "$BACKUP_ROOT/$latest/config-nvim" ]]; then
    echo "   ↩️  restoring backup: $latest"
    rsync -a "$BACKUP_ROOT/$latest/config-nvim/" "$DEST/"
    echo "   ✅ restored from $BACKUP_ROOT/$latest"
  else
    echo "   ℹ️  no daily-driver backup found at $BACKUP_ROOT — nvim is now unset"
  fi
fi
