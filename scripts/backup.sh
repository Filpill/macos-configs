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
)

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

echo "Done."
