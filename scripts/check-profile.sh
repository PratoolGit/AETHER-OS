#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "$0")/.." && pwd)"
cd "$ROOT_DIR"

for file in \
  profile/profiledef.sh \
  profile/packages.x86_64 \
  profile/pacman.conf \
  profile/efiboot/loader/loader.conf \
  profile/efiboot/loader/entries/01-aether-linux.conf \
  profile/airootfs/etc/mkinitcpio.conf.d/archiso.conf \
  profile/airootfs/etc/pacman.d/hooks/90-aether-live-setup.hook \
  profile/airootfs/etc/systemd/zram-generator.conf \
  profile/airootfs/etc/profile.d/aether-aliases.sh \
  profile/airootfs/etc/skel/.bashrc \
  profile/airootfs/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml \
  profile/airootfs/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml \
  profile/airootfs/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml \
  profile/airootfs/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml \
  profile/airootfs/etc/lightdm/lightdm-gtk-greeter.conf \
  profile/airootfs/usr/share/backgrounds/aether/aether-midnight.svg \
  profile/airootfs/usr/local/bin/aether \
  profile/airootfs/usr/local/bin/aether-diagnose \
  profile/airootfs/usr/local/bin/aether-live-user-setup \
  scripts/build-iso.sh \
  scripts/check-iso.sh \
  scripts/vm-smoke-test.sh
do
  if [[ ! -f "$file" ]]; then
    echo "Missing required AETHER profile file: $file" >&2
    exit 1
  fi
done

for package in base linux linux-firmware linux-firmware-mediatek linux-firmware-amdgpu \
               amd-ucode mkinitcpio mkinitcpio-archiso networkmanager wpa_supplicant \
               bluez blueman lightdm zram-generator mesa vulkan-radeon \
               xfce4-whiskermenu-plugin xfce4-docklike-plugin xfce4-pulseaudio-plugin \
               adw-gtk-theme papirus-icon-theme brightnessctl acpi pciutils usbutils
do
  if ! grep -Fxq "$package" profile/packages.x86_64; then
    echo "Required package is missing from packages.x86_64: $package" >&2
    exit 1
  fi
done

for package in udisks2 gvfs gvfs-mtp thunar-volman; do
  if grep -Eq "^[[:space:]]*$package([[:space:]]|$)" profile/packages.x86_64; then
    echo "$package must stay out of the Alpha live image." >&2
    exit 1
  fi
done

if grep -Eq '^[[:space:]]*xfce4([[:space:]]|$)' profile/packages.x86_64; then
  echo "Use the explicit XFCE package subset, not the full xfce4 group." >&2
  exit 1
fi

if grep -Eq '(^|[[:space:]])memdisk([[:space:]]|$)' profile/airootfs/etc/mkinitcpio.conf.d/archiso.conf; then
  echo "The Syslinux memdisk initramfs hook is not used in this UEFI build." >&2
  exit 1
fi

grep -Fq 'kernel_params_x86_64=' profile/profiledef.sh
grep -Fq 'console=ttyS0,115200n8' profile/profiledef.sh
grep -Fq 'systemd.firstboot=0' profile/profiledef.sh
grep -Fq 'aether-diagnose' profile/profiledef.sh
grep -Fq 'exec /usr/local/bin/aether-diagnose' profile/airootfs/usr/local/bin/aether

hook="profile/airootfs/etc/pacman.d/hooks/90-aether-live-setup.hook"
grep -Fxq 'Target = lightdm' "$hook"
grep -Fxq 'Exec = /usr/local/bin/aether-live-user-setup' "$hook"
grep -Fq '/usr/lib/systemd/system/graphical.target' \
  profile/airootfs/usr/local/bin/aether-live-user-setup

panel="profile/airootfs/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml"
grep -Fq 'value="docklike"' "$panel"
grep -Fq 'value="whiskermenu"' "$panel"
grep -Fq 'value="pulseaudio"' "$panel"
grep -Fq 'adw-gtk3-dark' profile/airootfs/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml
grep -Fq 'Papirus-Dark' profile/airootfs/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml

python3 - <<'PY'
from pathlib import Path
import xml.etree.ElementTree as ET

files = [
    Path("profile/airootfs/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml"),
    Path("profile/airootfs/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml"),
    Path("profile/airootfs/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml"),
    Path("profile/airootfs/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml"),
    Path("profile/airootfs/etc/lightdm/lightdm-gtk-greeter.conf"),
]
for path in files[:-1]:
    ET.parse(path)
ET.parse(Path("profile/airootfs/usr/share/backgrounds/aether/aether-midnight.svg"))
print("AETHER desktop XML and wallpaper SVG parse successfully.")
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
