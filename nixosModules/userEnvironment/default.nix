{ config, lib, ... }:

{
  imports = [
    ./config
    #./game
    ./io
    ./non-nix-apps

    ./appimage.nix
    ./fonts.nix
    ./kdeconnect.nix
    ./samba-client.nix
  ];

  options.nixos = {
    userEnvironment = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable userEnvironment modules bundle.";
      };
    };
  };

  config = lib.mkIf config.nixos.userEnvironment.enable {
    nixos.userEnvironment = {
      config.enable = true;
      #game.enable = lib.mkDefault false;
      io.enable = true;
      non-nix-apps.enable = true;

      appimage.enable = true;
      fonts.enable = true;
      kdeconnect.enable = true;
      samba-client.enable = true;
    };
  };
}