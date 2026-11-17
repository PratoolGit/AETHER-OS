# AETHER OS

A lightweight, highly customizable Linux distribution focused on developer productivity and broad hardware support.

> **Status:** Early alpha — the first bootable image is being assembled and has not yet passed CI or hardware testing.

## Project goals

- Target **600–800 MB idle RAM** on the reference laptop, measured under a documented test profile. This is a goal, not a guarantee.
- A highly configurable desktop: dock, panel, launcher, themes, window layouts, gestures and appearance controls.
- Linux development support with optional runtimes and tools installed on demand.
- Windows application compatibility through optional Wine/Bottles/Proton components.
- A beginner-friendly command experience with familiar aliases and guided system tools, while retaining standard Linux commands.
- Safe USB-first testing. Alpha 0.1 has no installer or persistent live storage and does not automatically mount internal Windows volumes.

## Current alpha

- Archiso-based x86_64 image profile.
- XFCE desktop baseline selected for low-overhead benchmarking.
- AMD graphics, Linux firmware, NetworkManager, Bluetooth and PipeWire.
- LightDM live session with a temporary AETHER user.
- Friendly AETHER command helper and familiar shell aliases.
- GitHub Actions build workflow.

The initial prototype currently uses UEFI systemd-boot because it is directly supported by Archiso. **Limine remains the intended bootloader** and requires a separately tested ISO integration step before the bootloader choice is finalized.

## Reference hardware

- ASUS VivoBook Go 15
- AMD Ryzen 3
- 8 GB RAM
- AMD integrated graphics
- MediaTek MT7902 Wi-Fi / Bluetooth (hardware validation required)

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
- aether setup developer
- aether setup windows

Familiar aliases are also provided: cls, dir, copy, move, del, ipconfig and tasklist. These are convenience shortcuts; standard Linux commands remain available.

## Build with GitHub Actions

Open the repository's Actions tab and run **Build AETHER OS ISO**, or push a change to the ISO profile. A successful run uploads the ISO and SHA-256 checksum as a temporary workflow artifact.

## Safety

AETHER OS is experimental. Test from a dedicated USB drive first. Alpha 0.1 is not an installer and has no disk-partitioning workflow. GVFS and UDisks2 are excluded from the live package set and checked after image construction, removing Thunar's normal removable-volume mounting integration. This is not block-device write protection. Do not manually mount or write to internal Windows partitions during testing. The current alpha is a live-session prototype, not an installer. No software can promise absolute protection against every firmware, hardware or user error.

## Project documents

- [Architecture](docs/ARCHITECTURE.md)
- [Roadmap](docs/ROADMAP.md)
- [USB and hardware testing](docs/TESTING.md)
