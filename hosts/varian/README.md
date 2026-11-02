**The "Varian" host is the Raspberry Pi**

Configuration:
- Raspberry Pi 5 16GB with a microSD card of 64GB

# Installation

1. Download and extract the [NixOS aarch64 SD Card Build on nixpkgs-unstable](https://hydra.nixos.org/job/nixos/unstable/nixos.sd_image_new_kernel_no_zfs.aarch64-linux)

2. Install the image using the Raspberry Pi Imager

3. On the Raspberry, after starting up, on root user, run `nixos-generate-config` to generate the first config

4. Temporarily edit the default configuration located at `/etc/nixos`:
    - Create the default user

```nix
    users.users.greep = {
        uid = 1000;
        isNormalUser = true;
        group = "users";
        createHome = true;
        home = "/home/greep";
        initialHashedPassword = "$6$wpoCAeUVymh0/wJ8$.T2bnLYhQXc8ReqvbPVaH89g9cVeHuQVKHaBTCgTdH0xP6oAdMNWs7R5vkatJClJYbfG1u9EnXr8ELv2fPC.3/";
        extraGroups = [ "wheel" ];
    };
```

    - Update the hostname of this WSL host `networking.hostName = "varian";`
    - Include the `git` package `programs.git.enable = true;`
    - After that, run `sudo nixos-rebuild switch`, then reboot

4. Clone this repo to your new home diretory that was created

5. Temporarily delete `/etc/nixos` then create a symbolic link from the cloned repo to the host config `ln -s /home/greep/nixos-config /etc/nixos`

6. Run `sudo nix-channel --update` and `sudo nixos-rebuild switch`