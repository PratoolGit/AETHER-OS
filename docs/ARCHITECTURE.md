# AETHER OS Architecture

## Foundation

AETHER OS is a customized Arch Linux distribution, not a new kernel. It uses the Linux kernel and existing Linux drivers, filesystems, networking, audio and process-management facilities.

## Initial layers

1. **Boot and live image:** Archiso builds a reproducible x86_64 live image. The first prototype uses UEFI systemd-boot because it is directly supported by Archiso. Limine remains the intended bootloader; its ISO integration is a separate engineering task and must be tested before switching.
2. **Base system:** Arch Linux packages, systemd, pacman and NetworkManager.
3. **Graphics stack:** Mesa provides OpenGL; `vulkan-radeon` supplies the open-source RADV Vulkan driver for the reference AMD GPU. Linux kernel AMDGPU support and firmware come from the standard kernel and linux-firmware packages.
4. **Desktop baseline:** a selected subset of XFCE components is used to avoid installing the entire xfce4 package group. This is a low-overhead benchmark baseline, not a final design lock-in.
5. **AETHER experience:** custom dock, panel, launcher, settings, appearance and performance tools will be developed as separate components.
6. **Optional compatibility:** Wine, Bottles, Proton, Flatpak applications and developer toolchains are installed on demand.

## Live-session initialization

A build-only pacman hook runs after LightDM is installed. It creates the disposable aether user, configures LightDM autologin, and enables NetworkManager, Bluetooth and the display-manager service. The hook removes itself after setup so it does not run during later package operations in the live session.

The live user has passwordless sudo for testing convenience. This is acceptable only for a disposable live session, not for a persistent personal account.

## Memory budget

The 600–800 MB idle target applies to a defined, clean desktop session after startup settles. It must be measured on the reference ASUS laptop and in a repeatable virtual-machine configuration. Memory usage depends on kernel, firmware, desktop, drivers, display resolution and background services. No target is guaranteed before measurement.

zram provides compressed swap in RAM to help under memory pressure. It does not reduce the desktop's resident memory footprint and must not be presented as physical RAM savings.

## Windows and development compatibility

- Linux development tools run natively.
- The optional developer setup installs common language runtimes and build tools.
- Windows applications may run through Wine or Bottles; compatibility varies by application.
- Games may use Steam/Proton; anti-cheat and DRM support varies.
- Keep large compatibility stacks optional to protect the base memory and ISO footprint.
- Provide friendly aliases and guided graphical workflows without replacing standard shell commands.

## Disk safety

The live environment must not automatically mount internal disks. The first alpha deliberately omits UDisks2 so the file manager cannot casually mount internal Windows partitions; this is a temporary safety trade-off. Persistence must be explicitly selected on removable media. Installer work is blocked until device-identification, confirmation and destructive-operation safeguards have been tested. No automatic Windows partition resizing or bootloader changes are allowed.

## Build

Use scripts/build-iso.sh on Arch Linux with archiso installed, or run the GitHub Actions workflow. The workflow stores the ISO and SHA-256 checksum as a build artifact.
