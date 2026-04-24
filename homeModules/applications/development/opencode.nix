{ config, lib, inputs, pkgs, ... }:

{
  options.homeManager = {
    applications.development.opencode = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable OpenCode Terminal.";
      };

      enableDesktop = lib.mkOption {
        type = lib.types.bool;
        default = true;
        example = false;
        description = "Enable OpenCode Desktop. OpenCode Terminal must be enabled to enable the Desktop App.";
      };
    };
  };

  config = lib.mkIf config.homeManager.applications.development.opencode.enable {
    programs.opencode = {
      enable = true;
    };

    home.packages = with pkgs; lib.mkIf config.homeManager.applications.development.opencode.enableDesktop [
      opencode-desktop
    ];
  };
}