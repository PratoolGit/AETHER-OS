#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "$0")/.." && pwd)"
shopt -s nullglob
images=("$ROOT_DIR"/out/*.iso)

if (( ${#images[@]} != 1 )); then
  echo "Expected exactly one ISO in out/; found ${#images[@]}." >&2
  exit 2
fi
ISO_PATH="${images[0]}"

QEMU_BIN="${QEMU_BIN:-qemu-system-x86_64}"
OVMF_CODE="${OVMF_CODE:-/usr/share/OVMF/OVMF_CODE_4M.fd}"
OVMF_VARS_TEMPLATE="${OVMF_VARS_TEMPLATE:-/usr/share/OVMF/OVMF_VARS_4M.fd}"
BOOT_TIMEOUT="${AETHER_VM_BOOT_TIMEOUT:-360}"

command -v "$QEMU_BIN" >/dev/null 2>&1 || {
  echo "Missing $QEMU_BIN. Install qemu-system-x86." >&2
  exit 127
}
[[ -r "$OVMF_CODE" ]] || { echo "Missing OVMF firmware: $OVMF_CODE" >&2; exit 1; }
[[ -r "$OVMF_VARS_TEMPLATE" ]] || { echo "Missing OVMF variables template: $OVMF_VARS_TEMPLATE" >&2; exit 1; }

WORK_DIR="$(mktemp -d "${TMPDIR:-/tmp}/aether-uefi-smoke.XXXXXX")"
OVMF_VARS="$WORK_DIR/OVMF_VARS.fd"
SERIAL_LOG="$WORK_DIR/serial.log"
QEMU_LOG="$WORK_DIR/qemu.log"
cp "$OVMF_VARS_TEMPLATE" "$OVMF_VARS"

ACCEL=tcg
if [[ -e /dev/kvm && -r /dev/kvm && -w /dev/kvm ]]; then
  ACCEL=kvm
fi

"$QEMU_BIN" \
  -machine "q35,accel=$ACCEL" \
  -cpu max \
  -m 4096 \
  -smp 4 \
  -drive "if=pflash,format=raw,unit=0,readonly=on,file=$OVMF_CODE" \
  -drive "if=pflash,format=raw,unit=1,file=$OVMF_VARS" \
  -cdrom "$ISO_PATH" \
  -boot order=d \
  -display none \
  -serial "file:$SERIAL_LOG" \
  -monitor none \
  -no-reboot \
  -no-shutdown \
  -net none \
  >"$QEMU_LOG" 2>&1 &
QEMU_PID=$!

cleanup() {
  if kill -0 "$QEMU_PID" 2>/dev/null; then
    kill "$QEMU_PID" 2>/dev/null || true
    wait "$QEMU_PID" 2>/dev/null || true
  fi
}
trap cleanup EXIT

elapsed=0
while (( elapsed < BOOT_TIMEOUT )); do
  if grep -Fq "Started Light Display Manager" "$SERIAL_LOG" 2>/dev/null; then
    echo "PASS: AETHER OS reached the LightDM service in UEFI QEMU ($ACCEL)."
    grep -F "Started Light Display Manager" "$SERIAL_LOG" | tail -n 1
    exit 0
  fi

  if ! kill -0 "$QEMU_PID" 2>/dev/null; then
    echo "FAIL: QEMU exited before LightDM started." >&2
    echo "--- QEMU log ---" >&2
    cat "$QEMU_LOG" >&2 || true
    echo "--- Serial log ---" >&2
    cat "$SERIAL_LOG" >&2 || true
    exit 1
  fi

  sleep 1
  elapsed=$((elapsed + 1))
done

echo "FAIL: LightDM did not start within ${BOOT_TIMEOUT}s." >&2
echo "--- QEMU log ---" >&2
cat "$QEMU_LOG" >&2 || true
echo "--- Serial log (last 250 lines) ---" >&2
tail -n 250 "$SERIAL_LOG" >&2 || true
exit 1
