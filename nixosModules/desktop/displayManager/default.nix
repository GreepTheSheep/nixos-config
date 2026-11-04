{ config, lib, ... }:

{
  imports = [
    ./gdm.nix
    ./sddm.nix
  ];

  options.nixos = {
    desktop.displayManager = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable displayManager modules bundle.";
      };
      defaultSession = lib.mkOption {
        type = lib.types.str;
        example = "plasma";
        description = "Set the default session for display manager.";
      };
      autoLogin = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = false;
          example = true;
          description = "Automatically log in a user at boot.";
        };
        user = lib.mkOption {
          type = lib.types.str;
          default = config.nixos.system.user.defaultuser.name;
          example = "greep";
          description = "The user to log in automatically.";
        };
      };
    };
  };

  config = lib.mkIf config.nixos.desktop.displayManager.autoLogin.enable {
    services.displayManager.autoLogin = {
      enable = true;
      user = config.nixos.desktop.displayManager.autoLogin.user;
    };
  };
}