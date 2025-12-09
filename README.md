# NixOS Configuration

This repository contains a modular NixOS configuration with KDE Plasma, Hyprland, and VMware support.

## Structure
- **flake.nix**: Entry point.
- **configuration.nix**: Main system configuration.
- **modules/**: Modular configurations.
  - **desktop/**: KDE, Hyprland.
  - **users/**: User definitions.
  - **apps.nix**: System packages and Flatpak.

## Installation
To install this configuration on a new machine:
1. Boot into a NixOS live environment.
2. Partition and mount your disks to `/mnt`.
3. Generate hardware config: `nixos-generate-config --root /mnt`
4. Copy this repository to `/mnt/etc/nixos/` (or clone it).
5. Install: `nixos-install --flake /mnt/etc/nixos#nixos-custom`

## Linting
A PowerShell script is provided to lint the configuration using Docker:
```powershell
./lint.ps1
```
