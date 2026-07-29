{ config, lib, ... }:

{
  imports = [
    ./greep-gmail.nix
    ./greep.nix
  ];

  options.homeManager.home = {
    accounts = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable accounts bundle.";
      };
    };
  };

  config = lib.mkIf config.homeManager.home.accounts.enable {
    homeManager.home.accounts = {
      greep-gmail.enable = true;
      greep.enable = true;
    };
  };
}