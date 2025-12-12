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
  };

  outputs = { nixpkgs, home-manager, plasma-manager, ... }: {
    nixosConfigurations = {
      # Standard NixOS configuration
      laptop-hp-matt = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          {
            system.stateVersion = "25.11";
            networking.hostName = "laptop-hp-matt";
          }
          ./configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.sharedModules = [ plasma-manager.homeModules.plasma-manager ];
          }
        ];
      };
      pc-matt-nix-vm = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          {
            system.stateVersion = "25.11";
            networking.hostName = "pc-matt-nix-vm";
            virtualisation.vmware.guest.enable = true;
          }
          ./configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.sharedModules = [ plasma-manager.homeModules.plasma-manager ];
          }
        ];
      };
    };
  };
}
