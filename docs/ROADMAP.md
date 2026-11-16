# AETHER OS Roadmap

## Alpha 0.1 — bootable foundation

- [x] Create an Archiso-based x86_64 profile.
- [x] Establish a minimal XFCE desktop baseline.
- [x] Add AMD graphics, firmware, NetworkManager, Bluetooth and PipeWire packages.
- [x] Add a local build script and a GitHub Actions ISO build.
- [ ] Confirm the first CI build completes.
- [ ] Boot-test in a UEFI virtual machine.
- [ ] Boot-test on the ASUS VivoBook Go 15 from USB.
- [ ] Record idle RAM, boot time, CPU, graphics and storage benchmarks.

## Alpha 0.2 — hardware and safety

- Validate MediaTek MT7902 Wi-Fi and Bluetooth independently.
- Test Intel, Realtek and Qualcomm wireless hardware where available.
- Add explicit internal-disk protection for live sessions.
- Design persistence on a separate USB partition; never enable persistence by writing to an internal Windows disk.
- Add safe recovery and diagnostics.

## Alpha 0.3 — AETHER desktop experience

- Build a configurable dock, panel, launcher and control center.
- Add theme, icon, font, animation and window-layout controls.
- Benchmark XFCE, LXQt and KDE Plasma before selecting the long-term desktop foundation.
- Keep optional visual effects disabled on low-memory hardware.

## Alpha 0.4 — compatibility and developer workflow

- Add optional Windows compatibility profiles using Wine/Bottles and Steam/Proton.
- Add guided installation of language runtimes, Git tools and developer applications.
- Add familiar command aliases and beginner-friendly command helpers.
- Preserve standard Linux commands and package-management behavior.

## Release principles

- The 600–800 MB idle-RAM figure is a measurement target, not a guarantee.
- Measure after boot with a documented test profile and report both free and available memory.
- Do not bundle heavy applications or compatibility layers into the base image.
- Do not claim Windows application compatibility without testing individual applications.
- Do not publish an ISO as stable until it passes virtual-machine and real-hardware boot tests.
