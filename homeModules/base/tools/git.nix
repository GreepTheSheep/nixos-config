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

      signingkey = lib.mkOption {
        type = lib.types.str;
        default = "~/.ssh/id_ed25519.pub";
        example = "~/.ssh/id_ed25519.pub";
        description = "Path to the public SSH key used for signing commits.";
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
          signingkey = config.homeManager.base.tools.git.signingkey;
        };
      };
    };
  };
}