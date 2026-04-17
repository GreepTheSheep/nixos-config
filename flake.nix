{
  description = "Greep NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.11";
    nix-colors.url = "github:misterio77/nix-colors";

    millennium = {
      url = "github:SteamClientHomebrew/Millennium?dir=packages/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence.url = "github:nix-community/impermanence";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    catppuccin.url = "github:catppuccin/nix";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";

    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sc0710.url = "github:Nakildias/sc0710";

    # Blocklists
    ads = {
      url = "https://blocklistproject.github.io/Lists/ads.txt";
      flake = false;
    };
    malware = {
      url = "https://blocklistproject.github.io/Lists/malware.txt";
      flake = false;
    };
    oisd-big = {
      url = "https://big.oisd.nl/";
      flake = false;
    };
    oisd-small = {
      url = "https://small.oisd.nl/";
      flake = false;
    };
    phishing = {
      url = "https://blocklistproject.github.io/Lists/phishing.txt";
      flake = false;
    };
    ransomware = {
      url = "https://blocklistproject.github.io/Lists/ransomware.txt";
      flake = false;
    };
    tracking = {
      url = "https://blocklistproject.github.io/Lists/tracking.txt";
      flake = false;
    };
  };

  outputs = inputs@{
    self,
    nixpkgs,
    catppuccin,
    ...
  }: let
    mkHost =
      hostname: system: nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = inputs // { inherit inputs; };
        modules = (
          if hostname == "greep-nixos-live" then
            [
              ({ pkgs, modulesPath, ... }: {
                imports = [
                  (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
                ];
              })
              ./nixosModules/default.nix
              ./hosts/${hostname}/default.nix
              ./homeModules/homemanager.nix
            ]
          else
            [
              #catppuccin.nixosModules.catppuccin
              ./nixosModules/default.nix
              ./hosts/${hostname}/default.nix
              ./homeModules/homemanager.nix
            ]
        );
      };

    hosts = {
      "jax"                   = "x86_64-linux";
      "pomni"                 = "x86_64-linux";
      "jax-desktop-vm"        = "x86_64-linux";
      "jax-server-vm"         = "x86_64-linux";
      "vigor"                 = "x86_64-linux";
      "varian"                = "aarch64-linux";
      "greep-nixos-live"      = "x86_64-linux";
    };
  in
  {
    nixosConfigurations = builtins.mapAttrs (host: system:
      mkHost host system
    ) hosts;
  };
}
