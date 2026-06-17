**The "Jax-wsl" host is a WSL2 image that runs on the Jax host (on Windows)**

How-to run NixOS WSL:

0. Make sure WSL is installed and updated:
```cmd
wsl --install --no-distribution
# OR, if installed
wsl --update
```

1. Download and install the [nixos.wsl image](https://github.com/nix-community/NixOS-WSL/releases/latest/download/nixos.wsl)

2. Temporarily edit the default configuration located at `/etc/nixos`:
- Change the user name to your default user `wsl.defaultUser = "greep";`
- Update the hostname of this WSL host `networking.hostName = "jax-wsl";`
- Include the `git` package `programs.git.enable = true;`
- After that, run `sudo nixos-rebuild switch`, then exit and relaunch WSL

3. Clone this repo to your new home diretory that was created

4. Temporarily delete `/etc/nixos` then create a symbolic link from the cloned repo to the host config `ln -s /home/greep/nixos-config /etc/nixos`

5. Run `sudo nix-channel --update` and `sudo nixos-rebuild switch`