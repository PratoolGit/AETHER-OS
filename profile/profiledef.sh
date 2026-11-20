#!/usr/bin/env bash
# AETHER OS — Archiso profile.
# The current prototype uses UEFI systemd-boot; Limine remains a later, tested migration.

iso_name="aether-os"
iso_label="AETHER_01"
iso_publisher="AETHER OS Project"
iso_application="AETHER OS Live Environment"
iso_version="0.2.0-alpha-20261120"
install_dir="aether"
pacman_conf="pacman.conf"

buildmodes=('iso')
bootmodes=('uefi.systemd-boot')
kernel_params_x86_64="console=tty0 console=ttyS0,115200n8 systemd.show_status=1 systemd.log_target=console systemd.firstboot=0"

# Preserve executable permissions and sudoers safety for live-session helpers.
file_permissions=(
  ["/etc/sudoers.d/10-aether-live"]="0:0:440"
  ["/usr/local/bin/aether-live-user-setup"]="0:0:755"
  ["/usr/local/bin/aether"]="0:0:755"
  ["/usr/local/bin/aether-diagnose"]="0:0:755"
)
