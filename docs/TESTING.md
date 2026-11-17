# AETHER OS Testing and Safety

## Current status

The first alpha is a live-session prototype. It is not an installer and must not be used to repartition or install onto the internal disk.

## Build validation

1. Confirm the GitHub Actions build completes.
2. Download the ISO artifact and its SHA256SUMS file.
3. Verify the checksum before writing the image to removable media.
4. Boot in a UEFI virtual machine before using physical hardware.
5. Record any boot errors and attach the relevant log output to the issue.

## USB-first hardware test

- Use a dedicated USB drive; a 32 GB or larger USB 3.x drive is recommended for practical persistence testing.
- Writing an ISO to a USB drive erases that USB drive. Confirm the selected device by model and capacity before writing.
- Do not select the Windows internal SSD.
- The initial profile excludes UDisks2 and Thunar's removable-volume manager, so the desktop does not offer its usual automatic volume-mount workflow.
- Do not create swap, persistence, logs or application data on the Windows disk.
- Keep Secure Boot disabled for the initial prototype unless the image has been signed and verified.
- The first image does not yet provide persistent live storage; persistence is a later milestone. The live account is created during ISO construction by a one-time package hook. It is a disposable aether account with passwordless sudo for the live session; do not use it as a secure personal account.

## Memory benchmark

After the desktop has settled for five minutes, record:

- free -h output, especially available memory.
- swapon --show, to confirm zram and the absence of disk-backed swap.
- systemd-analyze boot time.
- Top resident processes from ps.
- Desktop resolution, connected displays and enabled visual effects.
- Whether the session is running in a VM or on the ASUS VivoBook.

The 600–800 MB idle RAM target is not considered achieved until measured on the real laptop with the exact desktop profile and test method documented. zram capacity must not be counted as physical RAM savings.

## Reference laptop test matrix

- UEFI boot from USB.
- AMD integrated graphics and display brightness.
- Wi-Fi and Bluetooth separately, especially the MediaTek MT7902 adapter.
- Touchpad, gestures, keyboard, audio and microphone.
- Suspend and resume.
- External display and USB peripherals.
- Verify with lsblk that internal storage remains unmounted and inspect mount output for any internal-disk mount. The absence of a GUI mount option is not a substitute for a full block-device write-protection test.

## Reporting

Open a GitHub issue with the ISO version, hardware model, boot mode, test steps, expected result, actual result and logs. Never attach passwords, private keys or personal files.
