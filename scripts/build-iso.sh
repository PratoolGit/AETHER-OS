#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
PROFILE_DIR="$ROOT_DIR/profile"
WORK_DIR="${AETHER_WORK_DIR:-$ROOT_DIR/.work}"
OUT_DIR="${AETHER_OUT_DIR:-$ROOT_DIR/out}"

if [[ ! -f "$PROFILE_DIR/profiledef.sh" || ! -f "$PROFILE_DIR/packages.x86_64" ]]; then
  echo "AETHER OS profile is incomplete." >&2
  exit 1
fi

if ! command -v mkarchiso >/dev/null 2>&1; then
  echo "mkarchiso is missing. On Arch Linux, install it with:" >&2
  echo "  sudo pacman -S archiso" >&2
  exit 127
fi

mkdir -p "$WORK_DIR" "$OUT_DIR"

if (( EUID != 0 )); then
  if ! command -v sudo >/dev/null 2>&1; then
    echo "Run this script as root or install sudo." >&2
    exit 1
  fi
  exec sudo env AETHER_WORK_DIR="$WORK_DIR" AETHER_OUT_DIR="$OUT_DIR" \
    mkarchiso -v -w "$WORK_DIR" -o "$OUT_DIR" "$PROFILE_DIR"
fi

exec mkarchiso -v -w "$WORK_DIR" -o "$OUT_DIR" "$PROFILE_DIR"
