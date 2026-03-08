{ config, home-manager, specialArgs, plasma-manager, nix-flatpak, ... }:

{
  imports = [
    home-manager.nixosModules.home-manager
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";

    sharedModules = [
      plasma-manager.homeModules.plasma-manager
      nix-flatpak.homeManagerModules.nix-flatpak
    ];

    extraSpecialArgs = specialArgs;

    users.${config.nixos.system.user.defaultuser.name} = import ./default.nix;
  };

  programs.dconf.enable = true;
}