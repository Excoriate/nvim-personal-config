#!/usr/bin/env bash
# nvim-backup.sh — snapshot ~/.config/nvim + ~/.local/share/nvim into a timestamped backup
# directory. Used by `install --daily-driver`, `rollback`, and on-demand via `just backup`.
set -euo pipefail

# Hardened PATH: prefer Homebrew + system bins, exclude $HOME/.local/bin
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

# Reject unknown args: this script takes NO positional/flag args. Common audit
# scripts (e.g., a reviewer running `--help`) would otherwise create real ~2.3GB
# backups silently, poisoning the rollback queue's lexicographic "newest first".
for arg in "$@"; do
  case "$arg" in
    -h|--help)
      cat <<'EOF'
nvim-backup.sh  --  snapshot ~/.config/nvim + nvim data dirs to a timestamped backup.

Usage: nvim-backup.sh        (no args — runs immediately)

Env:
  BACKUP_ROOT     override backup root (default ~/.local/state/nvim-personal-config/backups)
  BACKUP_RETAIN   keep newest N backups (default 5; 0 disables prune)

Exit codes:
  0  backup complete
  1  config error (collision / unknown arg / missing tool)
EOF
      exit 0 ;;
    *)
      echo "❌ Unknown argument: $arg" >&2
      echo "   nvim-backup.sh takes no arguments. See: nvim-backup.sh --help" >&2
      exit 64 ;;
  esac
done

readonly BACKUP_ROOT="${BACKUP_ROOT:-$HOME/.local/state/nvim-personal-config/backups}"
# 1-sec timestamp + 6-hex suffix avoids collision when two backups land in the same
# second (e.g., promote -> backup chain). Suffix is random per process; mkdir is
# explicit-fail so a (vanishingly unlikely) collision returns non-zero.
TIMESTAMP="$(date +%Y%m%d-%H%M%S)-$(printf '%06x' "$RANDOM$$" | tail -c 6)"
readonly TIMESTAMP
readonly BACKUP_DIR="$BACKUP_ROOT/$TIMESTAMP"
if [[ -e "$BACKUP_DIR" ]]; then
  echo "❌ Backup dir already exists (rare collision): $BACKUP_DIR" >&2
  exit 1
fi
# Retention: prune backups older than the latest N. Disable with BACKUP_RETAIN=0.
readonly BACKUP_RETAIN="${BACKUP_RETAIN:-5}"

readonly XDG_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"
readonly XDG_DATA="${XDG_DATA_HOME:-$HOME/.local/share}"
readonly XDG_STATE="${XDG_STATE_HOME:-$HOME/.local/state}"

mkdir -p "$BACKUP_DIR"
echo "💾 Creating backup at: $BACKUP_DIR"

snapshot() {
  local src="$1" name="$2"
  if [[ -L "$src" ]]; then
    local target
    target="$(readlink "$src")"
    printf '%s -> %s\n' "$src" "$target" > "$BACKUP_DIR/$name.symlink"
    echo "   📎 symlink recorded: $name -> $target"
  elif [[ -d "$src" ]]; then
    rsync -a "$src/" "$BACKUP_DIR/$name/"
    echo "   📦 directory archived: $name ($(du -sh "$BACKUP_DIR/$name" | cut -f1))"
  else
    echo "   · skipped: $name (not present)"
  fi
}

snapshot "$XDG_CONFIG/nvim"               "config-nvim"
snapshot "$XDG_DATA/nvim/lazy"            "data-lazy"
snapshot "$XDG_DATA/nvim/mason"           "data-mason"
snapshot "$XDG_STATE/nvim"                "state-nvim"

# Manifest for rollback recipe to find the latest cleanly
cat > "$BACKUP_DIR/manifest.json" <<EOF
{
  "timestamp": "$TIMESTAMP",
  "user": "$(whoami)",
  "hostname": "$(hostname)",
  "xdg_config_home": "$XDG_CONFIG",
  "xdg_data_home": "$XDG_DATA",
  "xdg_state_home": "$XDG_STATE",
  "nvim_version": "$(nvim --version | head -1)"
}
EOF

echo ""
echo "✅ Backup complete: $BACKUP_DIR"
echo "📂 Total size: $(du -sh "$BACKUP_DIR" | cut -f1)"

# Retention prune (keep newest BACKUP_RETAIN, delete older).
if (( BACKUP_RETAIN > 0 )); then
  mapfile_compat() {
    local -a _items
    while IFS= read -r line; do _items+=("$line"); done
    printf '%s\n' "${_items[@]}"
  }
  all_backups="$(find "$BACKUP_ROOT" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; 2>/dev/null | sort -r)"
  to_prune="$(printf '%s\n' "$all_backups" | tail -n "+$((BACKUP_RETAIN + 1))")"
  if [[ -n "$to_prune" ]]; then
    echo ""
    echo "🧹 Pruning backups older than newest $BACKUP_RETAIN (set BACKUP_RETAIN=0 to disable):"
    while IFS= read -r old; do
      [[ -z "$old" ]] && continue
      echo "   - $old ($(du -sh "$BACKUP_ROOT/$old" | cut -f1))"
      rm -rf "${BACKUP_ROOT:?}/${old:?}"
    done <<< "$to_prune"
  fi
fi
