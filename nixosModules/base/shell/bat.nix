{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.nixos = {
    base.shell.bat = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable bat.";
      };

      replaceCat = lib.mkOption {
        type = lib.types.bool;
        default = true;
        example = false;
        description = "Replace cat with bat.";
      };
    };
  };

  config = lib.mkIf config.nixos.base.shell.bat.enable {
    programs.bat = {
      enable = true;
      extraPackages = with pkgs.bat-extras; [
        core
        batdiff
        batman
        batgrep
        prettybat
        batwatch
      ];
    };
  };
}
