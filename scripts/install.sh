#!/usr/bin/env bash
#
# install.sh — bootstrap Homebrew and install all packages from the Brewfile.
#
# Usage:
#   ./install.sh          # install Homebrew (if needed) + everything in ./Brewfile
#   ./install.sh --check  # report what's missing without installing (brew bundle check)
#
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BREWFILE="${REPO_DIR}/Brewfile"

log() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
err() { printf '\033[1;31mError:\033[0m %s\n' "$*" >&2; }

# --- sanity checks --------------------------------------------------------
if [[ "$(uname -s)" != "Darwin" ]]; then
  err "This script is intended for macOS."
  exit 1
fi

if [[ ! -f "$BREWFILE" ]]; then
  err "Brewfile not found at $BREWFILE"
  exit 1
fi

# --- install Homebrew if missing ------------------------------------------
if ! command -v brew >/dev/null 2>&1; then
  log "Homebrew not found — installing…"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Ensure brew is on PATH for this session (Apple Silicon vs Intel prefixes).
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

log "Using $(brew --version | head -n1)"

# --- check-only mode ------------------------------------------------------
if [[ "${1:-}" == "--check" ]]; then
  log "Checking Brewfile (no changes will be made)…"
  brew bundle check --verbose --file="$BREWFILE"
  exit 0
fi

# --- install everything from the Brewfile ---------------------------------
log "Installing packages from Brewfile…"
brew bundle install --file="$BREWFILE"

# --- go2rtc (not in Homebrew; standalone binary from GitHub releases) ------
# Bridges the UniFi G6 camera (RTSPS/H.264) to WebRTC for use as a meeting cam.
install_go2rtc() {
  local bindir="$HOME/.local/bin"
  local bin="$bindir/go2rtc"

  if [[ -x "$bin" ]]; then
    log "go2rtc already installed ($("$bin" --version 2>&1 | head -n1)) — skipping."
    return 0
  fi

  local arch asset
  case "$(uname -m)" in
    arm64) arch="arm64" ;;
    x86_64) arch="amd64" ;;
    *) err "Unsupported arch for go2rtc: $(uname -m)"; return 1 ;;
  esac
  asset="go2rtc_mac_${arch}.zip"

  log "Installing go2rtc ($asset)…"
  mkdir -p "$bindir"
  local tmp
  tmp="$(mktemp -d)"
  curl -fL -o "$tmp/go2rtc.zip" \
    "https://github.com/AlexxIT/go2rtc/releases/latest/download/${asset}"
  unzip -o -q "$tmp/go2rtc.zip" -d "$tmp"
  mv "$tmp/go2rtc" "$bin"
  chmod +x "$bin"
  rm -rf "$tmp"
  log "go2rtc installed to $bin ($("$bin" --version 2>&1 | head -n1))"
}
install_go2rtc

log "Done. All packages from $BREWFILE are installed."
