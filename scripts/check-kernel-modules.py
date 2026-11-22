#!/usr/bin/env python3
"""Verify the compiled MediaTek Bluetooth modules contain MT7902 support."""

from __future__ import annotations

import subprocess
import sys
from pathlib import Path


def read_module(path: Path) -> bytes:
    if not path.is_file():
        raise FileNotFoundError(f"Kernel module does not exist: {path}")

    if path.name.endswith(".zst"):
        command = ["zstd", "-q", "-d", "-c", str(path)]
    elif path.name.endswith(".xz"):
        command = ["xz", "-d", "-c", str(path)]
    else:
        return path.read_bytes()

    result = subprocess.run(command, check=True, stdout=subprocess.PIPE)
    return result.stdout


def main() -> int:
    if len(sys.argv) != 3:
        print(
            "Usage: check-kernel-modules.py PATH_TO_BTUSB_MODULE PATH_TO_BTMTK_MODULE",
            file=sys.stderr,
        )
        return 2

    btusb_path = Path(sys.argv[1])
    btmtk_path = Path(sys.argv[2])

    try:
        btusb = read_module(btusb_path)
        btmtk = read_module(btmtk_path)
    except (FileNotFoundError, subprocess.CalledProcessError, OSError) as exc:
        print(f"ERROR: unable to inspect Bluetooth modules: {exc}", file=sys.stderr)
        return 1

    # USB_DEVICE(0x13d3, 0x3579): match flags, vendor and product fields
    # from struct usb_device_id in little-endian order.
    usb_device_record = bytes.fromhex("03 00 d3 13 79 35")
    if usb_device_record not in btusb:
        print(
            "ERROR: compiled btusb module lacks the MT7902 USB ID 13d3:3579.",
            file=sys.stderr,
        )
        return 1

    # The upstream MediaTek helper derives the firmware filename from dev_id.
    firmware_formatter = b"mediatek/BT_RAM_CODE_MT%04x_1_%x_hdr.bin"
    if firmware_formatter not in btmtk:
        print(
            "ERROR: compiled btmtk module lacks the MT79xx firmware path formatter.",
            file=sys.stderr,
        )
        return 1

    # The MT7902 chip ID is 0x7902; compilers may encode the immediate as
    # either a 16-bit or 32-bit little-endian value.
    if b"\x02\x79" not in btmtk:
        print(
            "ERROR: compiled btmtk module lacks the MT7902 controller ID.",
            file=sys.stderr,
        )
        return 1

    print("PASS: compiled btusb module contains MT7902 USB ID 13d3:3579.")
    print("PASS: compiled btmtk module includes MT7902 firmware-selection support.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
