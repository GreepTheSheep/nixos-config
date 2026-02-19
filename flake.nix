{
  description = "Greep NixOS Configuration ISO";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    nix-flatpak.url = "github:gmodena/nix-flatpak";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, plasma-manager, nix-flatpak, sops-nix, spicetify-nix, ... }@inputs: {
    nixosConfigurations = {
      # Standard NixOS configuration
      laptop-hp-matt = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/laptop-hp-matt/hardware-configuration.nix
          ./configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.sharedModules = [
              plasma-manager.homeModules.plasma-manager
              nix-flatpak.homeManagerModules.nix-flatpak
            ];
          }
          sops-nix.nixosModules.sops
          spicetify-nix.nixosModules.spicetify
        ];
      };

      pc-matt-nix-vm = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/pc-matt-nix-vm/hardware-configuration.nix
          ./configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.sharedModules = [
              plasma-manager.homeModules.plasma-manager
              nix-flatpak.homeManagerModules.nix-flatpak
            ];
          }
          sops-nix.nixosModules.sops
          spicetify-nix.nixosModules.spicetify
        ];
      };

      liveIso = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ({ pkgs, modulesPath, ... }: {
            imports = [
              (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
            ];
          })
          ./hosts/live-iso.nix
          ./configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.sharedModules = [
              plasma-manager.homeModules.plasma-manager
              nix-flatpak.homeManagerModules.nix-flatpak
            ];
          }
          sops-nix.nixosModules.sops
          spicetify-nix.nixosModules.spicetify
        ];
      };
    };
  };
}
