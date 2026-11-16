#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
ISO_PATH="${1:-}"

if [[ -z "$ISO_PATH" ]]; then
  shopt -s nullglob
  candidates=("$ROOT_DIR"/out/*.iso)
  if (( ${#candidates[@]} != 1 )); then
    echo "Usage: $0 path/to/image.iso" >&2
    echo "Or ensure exactly one ISO exists in out/." >&2
    exit 2
  fi
  ISO_PATH="${candidates[0]}"
fi

if [[ ! -f "$ISO_PATH" ]]; then
  echo "ISO not found: $ISO_PATH" >&2
  exit 1
fi

sha256sum "$ISO_PATH"
