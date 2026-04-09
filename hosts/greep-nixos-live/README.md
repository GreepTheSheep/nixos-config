**This host is the live iso**

This should not be installed locally. This Live ISO must be built using this command:

```sh
sudo nix build .#nixosConfigurations.greep-nixos-live.config.system.build.isoImage
```

This will build a full live ISO suitable for most configurations and virtual machines.

**Only supported arch is x86_64 at the moment.**

Building the ISO image will take a lot of disk space, I suggest having more than 64GB of space left

After completing the build, you can mount it on a VM or copy it to a USB stick using `dd`

```sh
# Get the sdX value of the USB stick
lsblk

# Copy the ISO image to the USB stick
sudo dd if=./result/iso/nixos*.iso of=/dev/sdX bs=4M status=progress && sync
```