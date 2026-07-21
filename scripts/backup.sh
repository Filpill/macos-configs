#!/usr/bin/env bash
#
# Copy macOS app configs from their live locations into this repo,
# preserving their path relative to $HOME (e.g. .config/aerospace/aerospace.toml).
# Run: ./backup.sh
#
set -euo pipefail

# Repo root = parent of the scripts/ dir this script lives in (works from anywhere).
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Source paths (must live under $HOME so the relative path can be mirrored).
CONFIGS=(
  "$HOME/.config/aerospace/aerospace.toml"
  "$HOME/.config/karabiner/karabiner.json"
  "$HOME/.config/snowflake/config.toml"
  "$HOME/.zshrc"
  "$HOME/.zshenv"
  "$HOME/.zprofile"
  "$HOME/.config/lf/lfrc"
  "$HOME/.config/lf/cleaner.sh"
  "$HOME/.config/lf/previewer.sh"
  "$HOME/.config/go2rtc/go2rtc.yaml"
  "$HOME/Library/LaunchAgents/com.filiplivancic.go2rtc.plist"
)

# Pull in every standalone script under ~/.local/bin/scripts so new ones are
# backed up automatically without editing this list.
if [[ -d "$HOME/.local/bin/scripts" ]]; then
  while IFS= read -r -d '' f; do
    CONFIGS+=("$f")
  done < <(find "$HOME/.local/bin/scripts" -type f -print0)
fi

echo "Backing up configs into $REPO_DIR"

for src in "${CONFIGS[@]}"; do
  if [[ ! -f "$src" ]]; then
    echo "  SKIP  $src (not found)"
    continue
  fi

  rel="${src#"$HOME"/}"        # path relative to home, e.g. .config/aerospace/aerospace.toml
  dest="$REPO_DIR/$rel"

  mkdir -p "$(dirname "$dest")"
  cp -p "$src" "$dest"
  echo "  OK    $src -> $rel"
done

# Regenerate a fresh Brewfile in the repo root from the currently-installed packages.
if command -v brew >/dev/null 2>&1; then
  echo "Regenerating Brewfile"
  brew bundle dump --file="$REPO_DIR/Brewfile" --force
  echo "  OK    brew bundle dump -> Brewfile"
else
  echo "  SKIP  Brewfile (brew not found)"
fi

echo "Done."
