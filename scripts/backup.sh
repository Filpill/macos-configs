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
  # Claude Code AI-gateway settings (base URL, model, apiKeyHelper). Holds no
  # secret itself — the key is read at runtime from ~/.ssh/api/, which is not
  # in this repo and must be provisioned separately on a new machine.
  "$HOME/.claude/gateway.settings.json"
)

# Shell aliases/shortcuts sourced by .zshrc (aliasrc, shortcutrc). Whole dir so
# a new rc file here is picked up without editing the list above.
if [[ -d "$HOME/.config/shortcuts" ]]; then
  while IFS= read -r -d '' f; do
    CONFIGS+=("$f")
  done < <(find "$HOME/.config/shortcuts" -type f -print0)
fi

# Pull in every standalone script under ~/.local/bin/scripts so new ones are
# backed up automatically without editing this list.
if [[ -d "$HOME/.local/bin/scripts" ]]; then
  while IFS= read -r -d '' f; do
    CONFIGS+=("$f")
  done < <(find "$HOME/.local/bin/scripts" -type f -print0)
fi

# Pull in our own LaunchAgents (com.filiplivancic.*) — skips third-party ones
# like Google/displayplacer. Captures go2rtc, obs-headless, and future agents.
for f in "$HOME"/Library/LaunchAgents/com.filiplivancic.*.plist; do
  [[ -f "$f" ]] && CONFIGS+=("$f")
done

# OBS Studio config needed to reproduce the headless virtual-cam setup:
# global/user settings, scene collections, and profiles. Deliberately skips
# logs, crashes, cache, and plugin_config (machine-specific / not needed).
OBS_DIR="$HOME/Library/Application Support/obs-studio"
if [[ -d "$OBS_DIR" ]]; then
  for f in "$OBS_DIR/global.ini" "$OBS_DIR/user.ini"; do
    [[ -f "$f" ]] && CONFIGS+=("$f")
  done
  # scene collections (*.json only — skip the *.bak backups OBS writes)
  while IFS= read -r -d '' f; do CONFIGS+=("$f"); done \
    < <(find "$OBS_DIR/basic/scenes" -type f -name '*.json' -print0 2>/dev/null)
  # profiles (basic.ini + encoder/service settings)
  while IFS= read -r -d '' f; do CONFIGS+=("$f"); done \
    < <(find "$OBS_DIR/basic/profiles" -type f -print0 2>/dev/null)
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
