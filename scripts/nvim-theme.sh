#!/usr/bin/env bash
# nvim-theme.sh — switch the active colorscheme by editing the astroui.lua spec.
# Supported names map to AstroCommunity colorscheme packs that we optionally include.
#
# Portable to macOS system bash 3.2 (no `declare -A`, no `${var,,}`).
set -euo pipefail

# Hardened PATH: prefer Homebrew + system bins, exclude $HOME/.local/bin
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
readonly ASTROUI="$REPO_ROOT/nvim-config/lua/plugins/astroui.lua"
readonly COMMUNITY="$REPO_ROOT/nvim-config/lua/community.lua"

readonly NAME="${1:?Usage: nvim-theme.sh <theme-name>}"

# Resolve theme key -> colorscheme + (optional) astrocommunity import.
# Returns the pair via globals `colorscheme` + `import` (import="local" if bundled).
colorscheme=""
import=""
case "$NAME" in
  kanagawa-wave)    colorscheme="kanagawa"          ; import="local" ;;
  kanagawa-dragon)  colorscheme="kanagawa-dragon"   ; import="local" ;;
  tokyonight-storm) colorscheme="tokyonight-storm"  ; import="astrocommunity.colorscheme.tokyonight-nvim" ;;
  tokyonight-moon)  colorscheme="tokyonight-moon"   ; import="astrocommunity.colorscheme.tokyonight-nvim" ;;
  catppuccin-mocha) colorscheme="catppuccin-mocha"  ; import="astrocommunity.colorscheme.catppuccin" ;;
  cyberdream)       colorscheme="cyberdream"        ; import="astrocommunity.colorscheme.cyberdream-nvim" ;;
  rose-pine-moon)   colorscheme="rose-pine-moon"    ; import="astrocommunity.colorscheme.rose-pine" ;;
  *)
    {
      echo "❌ Unknown theme: $NAME"
      echo ""
      echo "Available:"
      echo "   kanagawa-wave"
      echo "   kanagawa-dragon"
      echo "   tokyonight-storm"
      echo "   tokyonight-moon"
      echo "   catppuccin-mocha"
      echo "   cyberdream"
      echo "   rose-pine-moon"
    } >&2
    exit 64 ;;
esac

echo "🎨 Setting colorscheme = $colorscheme  (theme key: $NAME)"

# Anchored sed: only `^<whitespace>colorscheme = "..."<comma>` (one per file in
# astroui.lua's opts table). Indent is stylua-driven (4 spaces under nested opts);
# match any whitespace prefix but require comma terminator so we cannot match
# any `kanagawa = { ... }` highlight-override keys further down (those use `=`
# without the comma at end of line because they open a block).
if ! grep -qE '^[[:space:]]+colorscheme = "[^"]+",[[:space:]]*$' "$ASTROUI"; then
  echo "❌ Could not locate canonical 'colorscheme = \"...\",' line in $ASTROUI" >&2
  exit 1
fi
sed -i.bak -E "s/^([[:space:]]+)colorscheme = \"[^\"]+\",/\\1colorscheme = \"${colorscheme}\",/" "$ASTROUI"
rm -f "$ASTROUI.bak"

# Ensure the community import is present (idempotent).
if [[ "$import" != "local" ]]; then
  if ! grep -qE "\{ import = \"${import}\"" "$COMMUNITY"; then
    echo "➕ Adding community import: $import"
    awk -v line="  { import = \"${import}\" }," '
      { print }
      /diagnostics\.trouble-nvim/ && !inserted { print line; inserted=1 }
    ' "$COMMUNITY" > "$COMMUNITY.new"
    mv "$COMMUNITY.new" "$COMMUNITY"
  fi
fi

echo ""
echo "✅ Theme staged. Apply by relaunching nvim or run :Lazy sync if a new pack was added."
echo "💡 Reformat with: stylua $REPO_ROOT/nvim-config"
