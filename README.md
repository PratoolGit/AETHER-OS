# AETHER OS

A lightweight, highly customizable Linux distribution focused on developer productivity and broad hardware support.

> **Status:** Early alpha — bootable image and hardware compatibility are under development.

## Project goals

- Target **600–800 MB idle RAM** on the reference laptop, measured under a documented test profile. This is a goal, not a guaranteed result.
- A highly configurable desktop: dock, panel, launcher, themes, window layouts, gestures and appearance controls.
- Linux development support with optional runtimes and tools installed on demand.
- Windows application compatibility through optional Wine, Bottles and Steam/Proton components.
- A beginner-friendly command experience with familiar aliases and guided system tools, without hiding standard Linux commands.
- A persistent live USB workflow that does not automatically mount or modify internal Windows disks.

## Reference hardware

- ASUS VivoBook Go 15
- AMD Ryzen 3
- 8 GB RAM
- AMD integrated graphics
- MediaTek MT7902 Wi-Fi / Bluetooth (hardware validation required)

## Build status

The first milestone is a reproducible Archiso-based live image. The build will run in CI and publish an ISO with SHA-256 checksums only after the build and safety checks pass.

## Safety

AETHER OS is experimental. Test from a USB drive first. Do not install it to an internal disk until the installer and disk-selection safeguards have been independently validated. No software can promise absolute protection against every firmware, hardware or user error.

## Development

See [docs/ROADMAP.md](docs/ROADMAP.md) and [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).
