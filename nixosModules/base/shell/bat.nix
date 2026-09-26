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
        description = "Replace cat with bat. Cat will be accessible with cat-old";
      };
    };
  };

  config = lib.mkIf config.nixos.base.shell.bat.enable {
    programs.bat = {
      enable = true;
      extraPackages = with pkgs.bat-extras; [
        batdiff
        batman
        batgrep
        prettybat
        batwatch
      ];
    };

    programs.bash.shellAliases = lib.mkIf config.nixos.base.shell.bat.replaceCat {
      cat-old = "${pkgs.coreutils}/bin/cat";
      cat = "${pkgs.bat}/bin/bat";
    };

    programs.zsh.shellAliases = lib.mkIf config.nixos.base.shell.bat.replaceCat {
      cat-old = "${pkgs.coreutils}/bin/cat";
      cat = "${pkgs.bat}/bin/bat";
    };
  };
}
