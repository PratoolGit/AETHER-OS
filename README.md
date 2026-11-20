# AETHER OS

A lightweight, highly customizable Linux distribution focused on developer productivity and broad hardware support.

> **Status:** Early alpha — the first UEFI image passed a QEMU boot test. Alpha 0.2 adds the initial AETHER desktop layout, laptop utilities and build-time driver/firmware checks. Physical ASUS hardware validation is still required.

## Project goals

- Target **600–800 MB idle RAM** on the reference laptop, measured under a documented test profile. This is a goal, not a guarantee.
- A highly configurable desktop: dock, panel, launcher, themes, window layouts, gestures and appearance controls.
- Linux development support with optional runtimes and tools installed on demand.
- Optional Windows app support through Wine, Winetricks and Bottles, with 32-bit compatibility repositories enabled but no 32-bit stack installed by default.
- A beginner-friendly command experience with familiar aliases and guided system tools, while retaining standard Linux commands.
- Safe USB-first testing. The alpha has no installer or persistent live storage and does not automatically mount internal Windows volumes.

## Current alpha

- Archiso-based x86_64 live image using the current Arch kernel and firmware packages.
- AMD integrated graphics support with AMDGPU, Mesa and RADV.
- Explicit MediaTek firmware and CI assertions for the MT7902 Wi-Fi PCI ID, Bluetooth USB ID and all three MT7902 firmware files.
- NetworkManager, Blueman, PipeWire, battery/brightness utilities, tap-to-click defaults, touchpad and input inspection, AMD OpenGL/Vulkan diagnostics and display-mode inspection.
- Dark AETHER appearance using Adwaita GTK 3 styling, Papirus icons, a custom midnight wallpaper, a searchable AETHER menu, top status panel and dock-style task switcher.
- LightDM live session with a temporary AETHER user; automatic firstboot prompts are disabled and the graphical target is selected.
- The AETHER diagnose command prints or saves a local hardware report. It performs best-effort redaction of common network identifiers in filtered kernel logs; review the report before sharing. It is never uploaded.
- GitHub Actions builds the ISO, verifies the installed package set and key hardware driver/firmware files, and boots the image in UEFI QEMU.

The initial prototype currently uses UEFI systemd-boot because it is directly supported by Archiso. **Limine remains the intended bootloader** and requires a separately tested ISO integration step before the bootloader choice is finalized.

## Reference hardware

- ASUS VivoBook Go 15
- AMD Ryzen 3
- 8 GB RAM
- AMD integrated graphics
- MediaTek MT7902 Wi-Fi / Bluetooth

CI verifies that the shipped kernel advertises the expected MT7902 device IDs and that the firmware files are present. This is a stronger image-level check, not proof that Wi-Fi, Bluetooth, suspend or every laptop component works on the physical ASUS.

## Build locally

On an Arch Linux build machine with archiso installed, run:

    sudo pacman -S archiso
    bash scripts/build-iso.sh
    bash scripts/check-iso.sh

The ISO and checksum are written to the out/ directory.

## Friendly commands

In a terminal, use the AETHER helper:

- aether help
- aether update
- aether install PACKAGE
- aether remove PACKAGE
- aether search TERM
- aether info
- aether network
- aether diagnose — inspect hardware, AMD graphics, touchpad, drivers, firmware, power, audio and mounted storage
- aether diagnose --save — save a report under /tmp
- aether setup developer
- aether setup windows — install Wine, Winetricks and Bottles (requires network access)

Familiar aliases are also provided: cls, dir, copy, move, del, ipconfig and tasklist. These are convenience shortcuts; standard Linux commands remain available.

## Build with GitHub Actions

Open the repository's Actions tab and run **Build AETHER OS ISO**, or push a change to the ISO profile. The previous baseline run [#51](https://github.com/PratoolGit/AETHER-OS/actions/runs/44699574544) completed successfully on 20 November 2026 and reached LightDM in UEFI QEMU. The current workflow adds driver-ID and firmware assertions for the ASUS reference hardware; check the latest Actions run for the Alpha 0.2 ISO and checksum artifact.

## Safety

AETHER OS is experimental. Test from a dedicated USB drive first. The alpha is not an installer and has no disk-partitioning workflow. GVFS and UDisks2 are excluded from the live package set and checked after image construction, removing Thunar's normal removable-volume mounting integration. This is not block-device write protection. Do not manually mount or write to internal Windows partitions during testing. The current image is a non-persistent live-session prototype. No software can promise absolute protection against every firmware, hardware or user error.

## Project documents

- [Architecture](docs/ARCHITECTURE.md)
- [Roadmap](docs/ROADMAP.md)
- [USB and hardware testing](docs/TESTING.md)
