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
  profile/airootfs/usr/local/bin/aether \
  profile/airootfs/usr/local/bin/aether-live-user-setup \
  scripts/build-iso.sh \
  scripts/check-iso.sh
do
  if [[ ! -f "$file" ]]; then
    echo "Missing required AETHER profile file: $file" >&2
    exit 1
  fi
done

for package in base linux linux-firmware mkinitcpio mkinitcpio-archiso \
               networkmanager wpa_supplicant bluez lightdm zram-generator
do
  if ! grep -Fxq "$package" profile/packages.x86_64; then
    echo "Required package is missing from packages.x86_64: $package" >&2
    exit 1
  fi
done

if grep -Eq '^[[:space:]]*udisks2([[:space:]]|$)' profile/packages.x86_64; then
  echo "UDisks2 must stay out of the Alpha 0.1 image." >&2
  exit 1
fi

if grep -Eq '^[[:space:]]*thunar-volman([[:space:]]|$)' profile/packages.x86_64; then
  echo "Thunar removable-volume auto-management must stay out of Alpha 0.1." >&2
  exit 1
fi

if grep -Eq '^[[:space:]]*xfce4([[:space:]]|$)' profile/packages.x86_64; then
  echo "Use the explicit XFCE package subset, not the full xfce4 group." >&2
  exit 1
fi

hook="profile/airootfs/etc/pacman.d/hooks/90-aether-live-setup.hook"
grep -Fxq 'Target = lightdm' "$hook"
grep -Fxq 'Exec = /usr/local/bin/aether-live-user-setup' "$hook"

bash -n profile/profiledef.sh
bash -n scripts/build-iso.sh
bash -n scripts/check-iso.sh
bash -n scripts/check-profile.sh
bash -n profile/airootfs/usr/local/bin/aether
bash -n profile/airootfs/usr/local/bin/aether-live-user-setup

echo "AETHER profile checks passed."
