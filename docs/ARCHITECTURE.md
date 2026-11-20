# AETHER OS Architecture

## Foundation

AETHER OS is a customized Arch Linux distribution, not a new kernel. It uses the Linux kernel and existing Linux drivers, filesystems, networking, audio and process-management facilities. The live ISO tracks current Arch packages so new upstream kernel and firmware support can be used without maintaining a private kernel fork.

## Initial layers

1. **Boot and live image:** Archiso builds a reproducible x86_64 live image. The first prototype uses UEFI systemd-boot because it is directly supported by Archiso. Limine remains the intended bootloader; its ISO integration is a separate engineering task and must be tested before switching.
2. **Base system:** Arch Linux packages, systemd, pacman and NetworkManager.
3. **Graphics stack:** Mesa provides OpenGL; vulkan-radeon supplies the open-source RADV Vulkan driver for the reference AMD GPU. Linux kernel AMDGPU support and AMD firmware come from the standard kernel and linux-firmware packages.
4. **Wireless and Bluetooth:** the standard kernel's mt7921e driver family supports the MT7902 PCI ID on current kernels. The btusb stack handles the MT7902 USB Bluetooth interface. The MediaTek firmware package supplies the MT7902 Wi-Fi and Bluetooth blobs. CI checks the exact PCI/USB aliases and firmware files inside the built root filesystem.
5. **Desktop baseline:** a selected subset of XFCE components is used to avoid installing the entire xfce4 package group. It is styled with a dark Adwaita GTK theme, Papirus icons, a custom wallpaper, a searchable Whisker menu, status panel, audio/power controls and dock-like task switcher.
6. **AETHER experience:** the initial desktop configuration is a lightweight foundation. A dedicated control center, advanced dock favorites, keyboard/gesture settings and more visual customization remain future work.
7. **Optional compatibility:** Wine, Bottles, Proton, Flatpak applications and developer toolchains are installed on demand.

## Laptop compatibility strategy

- **ASUS Ryzen 3 / AMD APU:** include AMD microcode, the AMDGPU kernel module, AMD firmware, Mesa and RADV.
- **MediaTek MT7902:** include MediaTek firmware and fail the ISO build if the kernel no longer advertises PCI ID 14c3:7902 through mt7921e, USB ID 13d3:3579 through btusb, or if any MT7902 firmware blob is missing.
- **Other wireless chipsets:** ship the standard Arch firmware set for Intel, Realtek, Qualcomm/Atheros and other common vendors. Their hardware behavior still needs testing.
- **Laptop controls:** XFCE Power Manager handles session power settings; brightnessctl and ACPI tools are available for direct diagnostics. libinput handles touchpad input, with tap-to-click enabled and touchpad input disabled while typing. The diagnostics tool reports detected input devices and display modes.
- **Graphics verification:** mesa-utils, vulkan-tools and xorg-xrandr are included so the real session can report the OpenGL renderer, Vulkan devices and connected display modes; this makes software rendering or missing GPU acceleration easier to spot.
- **Do not equate package/alias checks with hardware validation:** BIOS/ACPI quirks, antenna/radio state, USB routing, suspend/resume and firmware loading must be tested on the real laptop.

## Live-session initialization

A build-only pacman hook runs after LightDM is installed. It creates the disposable aether user, configures LightDM autologin, enables NetworkManager and Bluetooth, links the display manager, and selects graphical.target as the default boot target. The live kernel command line includes systemd.firstboot=0 so firstboot does not block on interactive timezone or locale questions. The hook removes itself after setup so it does not run during later package operations in the live session.

The live user has passwordless sudo for testing convenience. This is acceptable only for a disposable live session, not for a persistent personal account.

## Diagnostics

The aether diagnose command prints a local report containing CPU, kernel, memory, relevant PCI/USB devices, radio state, kernel module availability, OpenGL/Vulkan renderer information, display modes, input devices, power/brightness, audio services, storage mounts and filtered hardware-related kernel messages. It performs best-effort redaction of common IP, MAC and SSID patterns in the kernel log section. Review reports before sharing; they are never uploaded. The same report is available from the AETHER Hardware Check item in the application menu. Use aether diagnose --save to save a local copy in /tmp.

## Memory budget

The 600–800 MB idle target applies to a defined, clean desktop session after startup settles. It must be measured on the reference ASUS laptop and in a repeatable virtual-machine configuration. Memory usage depends on kernel, firmware, desktop, drivers, display resolution and background services. No target is guaranteed before measurement.

zram provides compressed swap in RAM to help under memory pressure. It does not reduce the desktop's resident memory footprint and must not be presented as physical RAM savings.

## Windows and development compatibility

- Linux development tools run natively.
- The optional developer setup installs common language runtimes and build tools.
- The multilib repository is enabled, but no 32-bit runtime packages are installed in the base image. The optional Windows setup installs Wine, Winetricks, Zenity for the Winetricks GTK dialog and Bottles via Flatpak.
- Windows applications may run through Wine or Bottles; compatibility varies by application.
- Games may use Steam/Proton; anti-cheat and DRM support varies.
- Keep large compatibility stacks optional to protect the base memory and ISO footprint.
- Provide friendly aliases and guided workflows without replacing standard shell commands.

## Disk safety

The live environment must not automatically mount internal disks. The first alpha deliberately omits UDisks2 so the file manager cannot casually mount internal Windows partitions; this is a temporary safety trade-off. Persistence must be explicitly selected on removable media. Installer work is blocked until device-identification, confirmation and destructive-operation safeguards have been tested. No automatic Windows partition resizing or bootloader changes are allowed.

## Build

Use scripts/build-iso.sh on Arch Linux with archiso installed, or run the GitHub Actions workflow. The workflow stores the ISO and SHA-256 checksum as a build artifact after package, hardware-driver, firmware and UEFI VM checks.
