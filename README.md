# Greep's NixOS Configuration

![NixOS](./nixos_greep_cfg_1.png)

## Installation
To install this configuration on a new machine:
1. Boot into a NixOS live environment.
2. Partition and mount your disks to `/mnt`.
3. Generate hardware config: `nixos-generate-config --root /mnt`
4. Copy this repository to `/mnt/etc/nixos/` (or clone it).
5. Install: `nixos-install --flake /mnt/etc/nixos#nixos-custom`


## Sops config (secrets) - To finish

1. Create a GPG key for encrypting secrets (`gpg --full-generate-key`).
2. Retreive the key ID of the generated key (`gpg --list-secret-keys`) and note it down.
3. Export the public key (`gpg --export --armor <key-id>`) and add it to the `.sops.yaml` configuration.