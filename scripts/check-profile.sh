#!/usr/bin/env bash
set -Eeuo pipefail
ROOT_DIR="$(cd -- "$(dirname -- "$0")/.." && pwd)"
cd "$ROOT_DIR"

required_files=(
  profile/profiledef.sh profile/packages.x86_64 profile/pacman.conf
  profile/efiboot/loader/loader.conf profile/efiboot/loader/entries/01-aether-linux.conf
  profile/airootfs/etc/mkinitcpio.conf.d/archiso.conf
  profile/airootfs/etc/pacman.d/hooks/90-aether-live-setup.hook
  profile/airootfs/etc/systemd/zram-generator.conf
  profile/airootfs/etc/profile.d/aether-aliases.sh profile/airootfs/etc/skel/.bashrc
  profile/airootfs/etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml
  profile/airootfs/etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml
  profile/airootfs/etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml
  profile/airootfs/etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml
  profile/airootfs/etc/X11/xorg.conf.d/40-aether-touchpad.conf
  profile/airootfs/etc/lightdm/lightdm-gtk-greeter.conf
  profile/airootfs/etc/sudoers.d/10-aether-live
  profile/airootfs/usr/share/backgrounds/aether/aether-midnight.svg
  profile/airootfs/usr/share/applications/aether-diagnostics.desktop
  profile/airootfs/usr/local/bin/aether profile/airootfs/usr/local/bin/aether-diagnose
  profile/airootfs/usr/local/bin/aether-live-user-setup
  scripts/build-iso.sh scripts/check-iso.sh scripts/vm-smoke-test.sh
)
for file in "${required_files[@]}"; do
  [[ -f "$file" ]] || { echo "Missing required AETHER profile file: $file" >&2; exit 1; }
done

required_packages=(
  base linux linux-firmware linux-firmware-mediatek linux-firmware-amdgpu
  amd-ucode intel-ucode mkinitcpio mkinitcpio-archiso
  networkmanager wpa_supplicant bluez bluez-utils blueman rfkill
  lightdm zram-generator mesa vulkan-radeon
  xfce4-whiskermenu-plugin xfce4-docklike-plugin xfce4-pulseaudio-plugin
  adw-gtk-theme papirus-icon-theme brightnessctl acpi pciutils usbutils
  mesa-utils vulkan-tools xorg-xrandr libinput-tools
)
for package in "${required_packages[@]}"; do
  grep -Fxq "$package" profile/packages.x86_64 || {
    echo "Required package is missing from packages.x86_64: $package" >&2; exit 1;
  }
done

for package in udisks2 gvfs gvfs-mtp thunar-volman; do
  if grep -Eq "^[[:space:]]*$package([[:space:]]|$)" profile/packages.x86_64; then
    echo "$package must stay out of the Alpha live image." >&2; exit 1
  fi
done
if grep -Eq '^[[:space:]]*xfce4([[:space:]]|$)' profile/packages.x86_64; then
  echo "Use the explicit XFCE package subset, not the full xfce4 group." >&2; exit 1
fi

# Keep AETHER XFCE defaults in /etc/skel, never over package-owned /etc/xdg files.
old_xdg_configs=(
  profile/airootfs/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml
  profile/airootfs/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml
  profile/airootfs/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml
  profile/airootfs/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml
)
for file in "${old_xdg_configs[@]}"; do
  [[ ! -e "$file" ]] || { echo "Package-conflicting XFCE override remains: $file" >&2; exit 1; }
done

# User creation and service activation happen once through the build-time pacman hook.
legacy_units=(
  profile/airootfs/etc/systemd/system/aether-live-user.service
  profile/airootfs/etc/systemd/system/default.target
  profile/airootfs/etc/systemd/system/graphical.target.d/10-aether.conf
  profile/airootfs/etc/systemd/system/lightdm.service.d/10-aether.conf
)
for file in "${legacy_units[@]}"; do
  [[ ! -e "$file" ]] || { echo "Redundant boot-time live-user unit remains: $file" >&2; exit 1; }
done

if grep -Eq '(^|[[:space:]])memdisk([[:space:]]|$)' profile/airootfs/etc/mkinitcpio.conf.d/archiso.conf; then
  echo "The Syslinux memdisk initramfs hook is not used in this UEFI build." >&2; exit 1
fi
grep -Fq 'systemd.firstboot=0' profile/profiledef.sh
grep -Fq 'console=ttyS0,115200n8' profile/profiledef.sh

hook="profile/airootfs/etc/pacman.d/hooks/90-aether-live-setup.hook"
setup="profile/airootfs/usr/local/bin/aether-live-user-setup"
grep -Fxq 'Target = lightdm' "$hook"
grep -Fxq 'Exec = /usr/local/bin/aether-live-user-setup' "$hook"
grep -Fq 'useradd --create-home' "$setup"
grep -Fq '/usr/lib/systemd/system/graphical.target' "$setup"
grep -Fq '/usr/lib/systemd/system/NetworkManager.service' "$setup"
grep -Fq '/usr/lib/systemd/system/bluetooth.service' "$setup"
grep -Fq '/usr/lib/systemd/system/lightdm.service' "$setup"
grep -Fq 'rm -f /etc/pacman.d/hooks/90-aether-live-setup.hook' "$setup"
grep -Fq 'exec /usr/local/bin/aether-diagnose' profile/airootfs/usr/local/bin/aether

xfce_dir="profile/airootfs/etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml"
panel="$xfce_dir/xfce4-panel.xml"
grep -Fq 'value="docklike"' "$panel"
grep -Fq 'value="whiskermenu"' "$panel"
grep -Fq 'value="pulseaudio"' "$panel"
grep -Fq 'adw-gtk3-dark' "$xfce_dir/xsettings.xml"
grep -Fq 'Papirus-Dark' "$xfce_dir/xsettings.xml"
grep -Fq 'Exec=xfce4-terminal --hold --execute aether diagnose' profile/airootfs/usr/share/applications/aether-diagnostics.desktop
grep -Fq 'Option "Tapping" "on"' profile/airootfs/etc/X11/xorg.conf.d/40-aether-touchpad.conf
grep -Fq '[multilib]' profile/pacman.conf
grep -Fq 'Include = /etc/pacman.d/mirrorlist' profile/pacman.conf

python3 - <<'PY'
from configparser import ConfigParser
from pathlib import Path
import xml.etree.ElementTree as ET
base = Path("profile/airootfs")
xfce = base / "etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml"
for name in ("xfce4-panel.xml", "xsettings.xml", "xfwm4.xml", "xfce4-desktop.xml"):
    ET.parse(xfce / name)
ET.parse(base / "usr/share/backgrounds/aether/aether-midnight.svg")
desktop = ConfigParser(interpolation=None)
desktop.read(base / "usr/share/applications/aether-diagnostics.desktop")
entry = desktop["Desktop Entry"]
assert entry.get("Name") == "AETHER Hardware Check"
assert entry.get("Exec") == "xfce4-terminal --hold --execute aether diagnose"
assert entry.get("Terminal", "").lower() == "false"
print("AETHER desktop XML, wallpaper SVG and launcher parse successfully.")
PY

bash -n profile/profiledef.sh
bash -n scripts/build-iso.sh
bash -n scripts/check-iso.sh
bash -n scripts/check-profile.sh
bash -n scripts/vm-smoke-test.sh
bash -n profile/airootfs/usr/local/bin/aether
bash -n profile/airootfs/usr/local/bin/aether-diagnose
bash -n profile/airootfs/usr/local/bin/aether-live-user-setup
echo "AETHER profile checks passed."
