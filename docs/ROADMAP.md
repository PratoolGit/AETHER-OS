# AETHER OS Roadmap

## Alpha 0.1 — bootable foundation

- [x] Create an Archiso-based x86_64 profile.
- [x] Establish a minimal XFCE desktop baseline.
- [x] Add AMD graphics, firmware, NetworkManager, Bluetooth and PipeWire packages.
- [x] Add a local build script and a GitHub Actions ISO build.
- [x] Confirm the first CI build completes (GitHub Actions run #51).
- [x] Boot-test in a UEFI virtual machine (QEMU reached LightDM).
- [ ] Boot-test on the ASUS VivoBook Go 15 from USB.
- [ ] Record idle RAM, boot time, CPU, graphics and storage benchmarks.

## Alpha 0.2 — laptop support and daily usability

- [x] Include explicit MediaTek firmware for the reference MT7902 adapter.
- [x] Add CI assertions for the MT7902 Wi-Fi PCI ID, Bluetooth USB ID and firmware blobs.
- [x] Add AMDGPU kernel-module and firmware presence checks.
- [x] Add local hardware diagnostics through the aether diagnose command.
- [x] Add laptop-facing battery, brightness, Bluetooth, audio, touchpad and hardware inspection utilities.
- [x] Add OpenGL/Vulkan renderer and display-mode diagnostics for AMD graphics.
- [x] Ship the first dark AETHER theme, custom wallpaper, searchable app menu and dock-style panel.
- [ ] Validate Wi-Fi and Bluetooth independently on the physical ASUS.
- [ ] Test AMD display acceleration, brightness keys, audio, touchpad and suspend/resume.
- [ ] Add explicit internal-disk protection for live sessions.
- [ ] Design persistence on a separate USB partition; never enable persistence by writing to an internal Windows disk.

## Alpha 0.3 — complete AETHER desktop experience

- [x] Establish a dock, panel, launcher and desktop appearance baseline.
- [ ] Build a dedicated control center for network, Bluetooth, power, themes and performance.
- [ ] Add editable dock favorites and richer window-layout controls.
- [ ] Add optional touchpad gestures and more keyboard shortcuts.
- [ ] Benchmark XFCE, LXQt and KDE Plasma before selecting the long-term desktop foundation.
- [ ] Keep optional visual effects disabled on low-memory hardware.

## Alpha 0.4 — compatibility and developer workflow

- [x] Enable multilib repository without installing multilib runtime packages in the base image.
- [x] Add an optional Wine/Winetricks/Bottles setup path; application-level compatibility testing remains open.
- [ ] Add guided installation of language runtimes, Git tools and developer applications.
- [x] Keep familiar command aliases and beginner-friendly command helpers.
- [x] Preserve standard Linux commands and package-management behavior.

## Release principles

- The 600–800 MB idle-RAM figure is a measurement target, not a guarantee.
- Measure after boot with a documented test profile and report both free and available memory.
- Do not bundle heavy applications or compatibility layers into the base image.
- Do not claim Windows application compatibility without testing individual applications.
- Do not publish an ISO as stable until it passes virtual-machine and real-hardware boot tests.
