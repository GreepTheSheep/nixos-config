{ config, lib, ... }:

{
  options.homeManager = {
    base.tools.git = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable git.";
      };
    };
  };

  config = lib.mkIf config.homeManager.base.tools.git.enable {
    programs.git = {
      enable = true;
      settings = {
        user = {
          name = "Matthieu";
          email = "greep@greep.fr";
        };
      };
    };
  };
}