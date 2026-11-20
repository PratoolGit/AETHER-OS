# AETHER OS Testing and Safety

## Current status

The alpha is a non-persistent live-session prototype. It is not an installer and must not be used to repartition or install onto the internal disk.

## Build validation

The GitHub Actions workflow builds the image with current Arch packages, checks the actual installed package database, verifies the UEFI kernel boot in QEMU, and performs hardware-support assertions inside the built root filesystem:

- MT7902 Wi-Fi PCI ID 14c3:7902 is matched by mt7921e.
- MT7902 Bluetooth USB ID 13d3:3579 is matched by btusb.
- The MT7902 Wi-Fi patch, Wi-Fi RAM and Bluetooth RAM firmware files are present.
- The AMDGPU kernel module and firmware directory are present.
- GVFS, UDisks2 and Thunar's removable-volume manager remain excluded.

These checks prove that the image contains the expected driver matches and firmware. They do not prove radio operation, firmware loading, suspend/resume or display behavior on physical hardware.

1. Confirm the latest GitHub Actions build completes.
2. Download the ISO artifact and its SHA256SUMS file.
3. Verify the checksum before writing the image to removable media.
4. Boot-test the live image on the ASUS and record hardware results.
5. Record any boot errors and attach only the relevant, privacy-reviewed diagnostic output to the issue.

## USB-first hardware test

- Use a dedicated USB drive. Writing an ISO to a USB drive erases that USB drive; confirm the selected device by model and capacity before writing.
- Do not select the Windows internal SSD.
- The profile omits GVFS, UDisks2 and Thunar's removable-volume manager. The build workflow checks the installed package database to ensure UDisks2 was not pulled in as a transitive dependency. This removes Thunar's usual GUI volume-mount workflow, but it is not block-device write protection.
- Do not manually mount or write to internal Windows partitions. Do not create swap, persistence, logs or application data on the Windows disk.
- Keep Secure Boot disabled for the initial prototype; the image is not signed for Secure Boot.
- Alpha 0.2 has no persistent live storage. The live account is created during ISO construction by a one-time package hook. It is a disposable aether account with passwordless sudo for the live session; do not use it as a secure personal account.

## Quick hardware report

Run:

    aether diagnose

To save a local report:

    aether diagnose --save

The default saved report is placed in /tmp. The diagnostic output avoids SSIDs, IP/MAC addresses, passwords and device serial numbers. It is not uploaded anywhere. Review it before sharing, because hardware models and device names can still identify your configuration.

## Reference laptop test matrix

- **Boot:** UEFI boot from USB; confirm LightDM and the configured XFCE desktop appear.
- **AMD graphics:** inspect lspci -nnk, confirm the amdgpu driver is bound, test the internal display, external display and video playback.
- **MT7902 Wi-Fi:** check rfkill list, nmcli device status, lspci -nnk and kernel messages; connect to a test network only after confirming the adapter appears.
- **MT7902 Bluetooth:** check lsusb, systemctl is-active bluetooth and Blueman; test discovery and a known peripheral separately from Wi-Fi.
- **Laptop controls:** test brightness keys, battery reporting, volume keys, microphone, touchpad, two-finger scrolling and suspend/resume.
- **Storage safety:** inspect lsblk and findmnt; ensure no internal Windows partition has been manually mounted.

## Memory benchmark

After the desktop has settled for five minutes, record:

- free -h output, especially available memory.
- swapon --show, to confirm zram and the absence of disk-backed swap.
- systemd-analyze boot time.
- Top resident processes from ps.
- Desktop resolution, connected displays and enabled visual effects.
- Whether the session is running in a VM or on the ASUS VivoBook.

The 600–800 MB idle RAM target is not considered achieved until measured on the real laptop with the exact desktop profile and test method documented. zram capacity must not be counted as physical RAM savings.

## Reporting

Open a GitHub issue with the ISO version, hardware model, boot mode, test steps, expected result, actual result and privacy-reviewed logs. Never attach passwords, private keys, personal files or unreviewed full diagnostic output.
