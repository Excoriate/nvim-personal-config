#!/usr/bin/env bash
# nvim-rollback.sh — restore the most recent backup as the daily driver (~/.config/nvim).
# Asks for explicit confirmation before clobbering. Reversible by re-running install.
set -euo pipefail

# Hardened PATH: prefer Homebrew + system bins, exclude $HOME/.local/bin
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

readonly XDG_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"
readonly DEST="$XDG_CONFIG/nvim"
readonly BACKUP_ROOT="${BACKUP_ROOT:-$HOME/.local/state/nvim-personal-config/backups}"

if [[ ! -d "$BACKUP_ROOT" ]]; then
  echo "❌ No backup root at $BACKUP_ROOT" >&2
  exit 1
fi

# Timestamped subdirs are YYYYMMDD-HHMMSS (controlled by nvim-backup.sh), so
# lexicographic descending sort == chronological newest.
latest="$(find "$BACKUP_ROOT" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; 2>/dev/null | sort -r | head -1 || true)"
if [[ -z "$latest" ]]; then
  echo "❌ No backups found in $BACKUP_ROOT" >&2
  exit 1
fi

readonly BACKUP_DIR="$BACKUP_ROOT/$latest"

if [[ ! -d "$BACKUP_DIR/config-nvim" && ! -f "$BACKUP_DIR/config-nvim.symlink" ]]; then
  echo "❌ Backup $latest has no recoverable nvim config" >&2
  exit 1
fi

echo "↩️  Latest backup: $BACKUP_DIR"
echo "📦 Contents:"
find "$BACKUP_DIR" -mindepth 1 -maxdepth 1 \
  -exec du -sh {} \; 2>/dev/null | sed 's/^/   /'
echo ""

# PRE-VALIDATE restore source BEFORE destroying $DEST. Refusing here means the user
# keeps their working config; refusing AFTER `rm` would leave them with nothing.
restore_kind=""
restore_target=""
if [[ -f "$BACKUP_DIR/config-nvim.symlink" ]]; then
  # Use awk with NF-1 segmenting + cut on the LAST occurrence of " -> ", which
  # tolerates paths containing the literal " -> " (rare but possible).
  if ! restore_target="$(awk '
    {
      # split on " -> " and take everything after the LAST occurrence
      n = split($0, parts, / -> /)
      if (n >= 2) { out = parts[n]; for (i=n-1; i>1; i--) out = parts[i] " -> " out; print out }
    }
  ' "$BACKUP_DIR/config-nvim.symlink")"; then
    echo "❌ Could not parse symlink record at $BACKUP_DIR/config-nvim.symlink" >&2
    exit 1
  fi
  if [[ -z "$restore_target" || ! -e "$restore_target" ]]; then
    echo "❌ Symlink target does not exist: $restore_target" >&2
    echo "   The original symlink pointed to a path that has since been removed." >&2
    exit 1
  fi
  # Canonicalize + constrain target to $HOME or /opt/homebrew to defend against
  # a tampered backup metadata file pointing the daily-driver symlink at an
  # attacker-controlled path. realpath resolves any intermediate symlinks.
  canonical="$(realpath "$restore_target" 2>/dev/null || true)"
  if [[ -z "$canonical" ]]; then
    echo "❌ Cannot canonicalize restore target: $restore_target" >&2
    exit 1
  fi
  case "$canonical" in
    "$HOME"/*|/opt/homebrew/*|/usr/local/*) : ;;
    *)
      echo "❌ Refusing to point ~/.config/nvim at out-of-allowlist path: $canonical" >&2
      echo "   Allowed prefixes: \$HOME/*, /opt/homebrew/*, /usr/local/*" >&2
      exit 1 ;;
  esac
  restore_target="$canonical"
  restore_kind="symlink"
elif [[ -d "$BACKUP_DIR/config-nvim" ]]; then
  if [[ ! -f "$BACKUP_DIR/config-nvim/init.lua" ]]; then
    echo "❌ Backup snapshot at $BACKUP_DIR/config-nvim has no init.lua — refusing." >&2
    exit 1
  fi
  restore_kind="directory"
else
  echo "❌ Backup $latest has neither config-nvim.symlink nor config-nvim/" >&2
  exit 1
fi

read -rp "Restore this backup over $DEST? [y/N] " answer
case "$(printf '%s' "$answer" | tr '[:upper:]' '[:lower:]')" in
  y|yes) : ;;
  *) echo "Aborted."; exit 0 ;;
esac

# Snapshot current state BEFORE clobber (safety net).
if [[ -L "$DEST" ]]; then
  echo "   ✂️  removing current symlink: $(readlink "$DEST")"
  rm "$DEST"
elif [[ -d "$DEST" ]]; then
  echo "   💾 snapshotting current $DEST before rollback (safety)"
  bash "$(dirname -- "$0")/nvim-backup.sh"
  rm -rf "$DEST"
fi

# Restore — source already validated above.
if [[ "$restore_kind" == "symlink" ]]; then
  ln -s "$restore_target" "$DEST"
  echo "✅ Symlink restored: $DEST -> $restore_target"
else
  rsync -a "$BACKUP_DIR/config-nvim/" "$DEST/"
  echo "✅ Directory restored: $DEST (from $latest)"
fi
