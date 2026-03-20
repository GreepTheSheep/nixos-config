_:

{
  # Le Pi 5 (BCM2712) n'a pas de UEFI natif.
  # Chaîne de boot : EEPROM → U-Boot → extlinux → kernel NixOS
  # U-Boot supporte le boot SD sur Pi 5 depuis v2024.04.
  # Note: boot USB/NVMe via U-Boot non encore supporté (pilote PCIe/RP1 manquant upstream).
  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;
}
