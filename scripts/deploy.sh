#!/usr/bin/env bash
#
# Deploy the configs stored in this repo back to their live locations under $HOME.
# Mirrors the repo's layout: <repo>/.config/foo/bar -> $HOME/.config/foo/bar
#
# Existing target files are backed up to <file>.bak.<timestamp> before overwriting.
#
# Usage:
#   ./deploy.sh          # preview, then prompt for confirmation
#   ./deploy.sh -y       # skip the confirmation prompt
#   ./deploy.sh -n       # dry run: show what would happen, change nothing
#
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

ASSUME_YES=0
DRY_RUN=0
for arg in "$@"; do
  case "$arg" in
    -y|--yes) ASSUME_YES=1 ;;
    -n|--dry-run) DRY_RUN=1 ;;
    *) echo "Unknown option: $arg" >&2; exit 2 ;;
  esac
done

# Repo housekeeping files that must NOT be deployed to $HOME.
EXCLUDES=(
  "$REPO_DIR/Brewfile"
  "$REPO_DIR/.gitignore"
  "$REPO_DIR/README.md"
)

is_excluded() {
  local f="$1"
  [[ "$f" == "$REPO_DIR/.git/"* ]] && return 0
  [[ "$f" == "$REPO_DIR/scripts/"* ]] && return 0
  [[ "$f" == "$REPO_DIR/static/"* ]] && return 0
  for e in "${EXCLUDES[@]}"; do [[ "$f" == "$e" ]] && return 0; done
  return 1
}

# Collect the files to deploy.
FILES=()
while IFS= read -r -d '' f; do
  is_excluded "$f" && continue
  FILES+=("$f")
done < <(find "$REPO_DIR" -type f -print0)

if [[ ${#FILES[@]} -eq 0 ]]; then
  echo "Nothing to deploy."
  exit 0
fi

# Preview.
echo "Deploying from $REPO_DIR to \$HOME:"
for src in "${FILES[@]}"; do
  rel="${src#"$REPO_DIR"/}"
  dest="$HOME/$rel"
  if [[ -f "$dest" ]]; then note="(overwrite; backup taken)"; else note="(new)"; fi
  echo "  $rel  ->  ~/$rel  $note"
done

if [[ $DRY_RUN -eq 1 ]]; then
  echo "Dry run — no changes made."
  exit 0
fi

# Confirm.
if [[ $ASSUME_YES -ne 1 ]]; then
  read -r -p "Proceed? [y/N] " reply
  [[ "$reply" =~ ^[Yy]$ ]] || { echo "Aborted."; exit 1; }
fi

ts="$(date +%Y%m%d%H%M%S)"
for src in "${FILES[@]}"; do
  rel="${src#"$REPO_DIR"/}"
  dest="$HOME/$rel"
  mkdir -p "$(dirname "$dest")"
  if [[ -f "$dest" ]]; then cp -p "$dest" "$dest.bak.$ts"; fi
  cp -p "$src" "$dest"
  echo "  OK    ~/$rel"
done

echo "Done."
