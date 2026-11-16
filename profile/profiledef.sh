#!/usr/bin/env bash
# AETHER OS Alpha 0.1 — initial Archiso profile.
# NOTE: systemd-boot is used only for the first buildable prototype.
# Limine remains the intended bootloader and will replace this after its
# Archiso ISO integration has been implemented and tested.

iso_name="aether-os"
iso_label="AETHER_01"
iso_publisher="AETHER OS Project"
iso_application="AETHER OS Live Environment"
iso_version="0.1.0-alpha-20261116"
install_dir="aether"

buildmodes=('iso')
bootmodes=('uefi.systemd-boot')
