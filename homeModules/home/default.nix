{ config, lib, ... }:

{
  imports = [
    ./accounts

    ./home.nix
  ];

  options.homeManager = {
    home = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable home modules bundle.";
      };
    };
  };

  config = lib.mkIf config.homeManager.home.enable {
    homeManager.home = {
      accounts.enable = true;

      home.enable = true;
    };
  };
}