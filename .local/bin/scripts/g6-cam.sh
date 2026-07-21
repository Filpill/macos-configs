#!/usr/bin/env bash
#
# g6-cam.sh — start the go2rtc bridge that re-publishes the UniFi G6 Instant
# camera as a low-latency WebRTC stream for use as a meeting camera in OBS.
#
# Usage:  g6-cam.sh
#
# Once running:
#   - Control panel : http://localhost:1984
#   - OBS Browser Source URL : http://localhost:1984/webrtc.html?src=g6
#   - Stop with Ctrl-C
#
set -euo pipefail

CONFIG="${HOME}/.config/go2rtc/go2rtc.yaml"

# --- sanity checks ---------------------------------------------------------
if ! command -v go2rtc >/dev/null 2>&1; then
  echo "error: go2rtc is not installed or not on PATH." >&2
  echo "       install it with:  brew install go2rtc" >&2
  exit 1
fi

if [[ ! -f "${CONFIG}" ]]; then
  echo "error: config not found at ${CONFIG}" >&2
  exit 1
fi

# --- run -------------------------------------------------------------------
echo "starting go2rtc bridge for the G6 Instant..."
echo "  panel : http://localhost:1984"
echo "  OBS   : http://localhost:1984/webrtc.html?src=g6"
echo

exec go2rtc -config "${CONFIG}"
