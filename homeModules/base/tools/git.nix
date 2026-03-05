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
        default = "/etc/ssh/ssh_host_ed25519_key.pub";
        example = "/home/greep/.ssh/ssh_host_ed25519_key.pub";
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