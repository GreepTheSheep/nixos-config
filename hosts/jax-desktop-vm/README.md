**The "Jax" host is the main computer**

Configuration:
- AMD Ryzen 7 7700X
- 64GB RAM DDR5 (1x32GB + 2x16GB)
- 2 NVMe disks:
  - WD Blue SN570 2TB
    - Windows 11 Partition under BitLocker (~1TB)
    - Btrfs partition for NixOS under LUKS (~1TB)
  - WD_BLACK SN770 2TB
    - NTFS partition, mostly used for games under Windows (100%).
- NVIDIA GeForce RTX 3060Ti 8GB VRAM
- TPM Chip must be enabled for every encrypted partition
