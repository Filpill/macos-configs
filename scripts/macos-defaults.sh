#!/usr/bin/env bash
#
# Apply macOS system preferences that live in `defaults` domains rather than in
# a config file, so they can't be handled by deploy.sh's plain file copies.
#
# Currently: rewires the built-in screenshot hotkeys off cmd, because the
# defaults (⇧⌘3 / ⇧⌘4 / ⇧⌘5) collide with AeroSpace's cmd-shift-N
# `move-node-to-workspace` bindings in .config/aerospace/aerospace.toml.
#
# Usage:
#   ./macos-defaults.sh          # apply
#   ./macos-defaults.sh -n       # dry run: print what would change
#
# NOTE ON TYPES: com.apple.symbolichotkeys parameters MUST be integers. Writing
# them with `defaults write ... -dict-add <id> "{...}"` stores them as strings
# and macOS silently ignores the entry — hence the plutil -json round-trip below.
#
set -euo pipefail

DRY_RUN=0
for arg in "$@"; do
  case "$arg" in
    -n|--dry-run) DRY_RUN=1 ;;
    *) echo "Unknown option: $arg" >&2; exit 2 ;;
  esac
done

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "macos-defaults.sh: not macOS, skipping." >&2
  exit 0
fi

# --- screenshot hotkeys ---------------------------------------------------
#
# Modifier mask bits:  shift 131072 | control 262144 | option 524288 | command 1048576
#   ctrl+shift      = 131072 + 262144            =  393216
#   ctrl+alt+shift  = 131072 + 262144 + 524288   =  917504
#
# Key codes: 3 = 20, 4 = 21, 5 = 23.  ASCII: '3' = 51, '4' = 52, '5' = 53.
#
# Hotkey IDs (Apple's, from System Settings > Keyboard Shortcuts > Screenshots):
#    28  save picture of screen as file
#    29  copy picture of screen to clipboard
#    30  save picture of selected area as file
#    31  copy picture of selected area to clipboard
#   184  screenshot and recording options UI
#
# id:ascii:keycode:mask:description
SCREENSHOT_HOTKEYS=(
  "28:51:20:393216:ctrl+shift+3      full screen -> file"
  "29:51:20:917504:ctrl+alt+shift+3  full screen -> clipboard"
  "30:52:21:393216:ctrl+shift+4      selection   -> file"
  "31:52:21:917504:ctrl+alt+shift+4  selection   -> clipboard"
  "184:53:23:393216:ctrl+shift+5      screenshot options UI"
)

echo "Screenshot hotkeys (com.apple.symbolichotkeys):"
for entry in "${SCREENSHOT_HOTKEYS[@]}"; do
  IFS=: read -r id _ascii _keycode _mask desc <<<"$entry"
  printf '  %-4s %s\n' "$id" "$desc"
done

if [[ $DRY_RUN -eq 1 ]]; then
  echo "  (dry run — not applied)"
  exit 0
fi

# Edit an exported copy of the whole domain, then import it back in one shot.
# Going through `defaults export/import` keeps cfprefsd in the loop, which a
# direct write to ~/Library/Preferences/*.plist does not.
tmp="$(mktemp -t symbolichotkeys).plist"
trap 'rm -f "$tmp"' EXIT

if ! defaults export com.apple.symbolichotkeys "$tmp" 2>/dev/null; then
  # Domain doesn't exist yet (all hotkeys still at factory defaults).
  /usr/libexec/PlistBuddy -c "Add :AppleSymbolicHotKeys dict" "$tmp" >/dev/null
fi
# An exported domain with no AppleSymbolicHotKeys key needs the parent created.
plutil -extract AppleSymbolicHotKeys xml1 -o /dev/null "$tmp" 2>/dev/null \
  || plutil -insert AppleSymbolicHotKeys -dictionary "$tmp"

# Replace each entry whole. Setting the leaves individually would fail on a
# fresh machine: plutil -replace does not create intermediate dicts, and on a
# Mac that has never had a screenshot hotkey overridden, :<id> doesn't exist.
for entry in "${SCREENSHOT_HOTKEYS[@]}"; do
  IFS=: read -r id ascii keycode mask desc <<<"$entry"
  plutil -replace "AppleSymbolicHotKeys.$id" -json \
    "{\"enabled\":true,\"value\":{\"parameters\":[$ascii,$keycode,$mask],\"type\":\"standard\"}}" \
    "$tmp"
done

defaults import com.apple.symbolichotkeys "$tmp"

# Verify the values took, with the right types.
live="$HOME/Library/Preferences/com.apple.symbolichotkeys.plist"
fail=0
for entry in "${SCREENSHOT_HOTKEYS[@]}"; do
  IFS=: read -r id ascii keycode mask desc <<<"$entry"
  got="$(plutil -extract "AppleSymbolicHotKeys.$id.value.parameters" json -o - "$live" 2>/dev/null || echo '?')"
  if [[ "$got" == "[$ascii,$keycode,$mask]" ]]; then
    printf '  OK    %-4s %s\n' "$id" "$desc"
  else
    printf '  FAIL  %-4s expected [%s,%s,%s], got %s\n' "$id" "$ascii" "$keycode" "$mask" "$got"
    fail=1
  fi
done
[[ $fail -eq 0 ]] || exit 1

# Make the new bindings live without a logout.
/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u

echo "Applied. If the old ⇧⌘4 still fires, log out and back in."
