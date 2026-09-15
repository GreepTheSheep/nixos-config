{ config, lib, ... }:

{
  imports = [
    ./discord.nix
    ./element.nix
    ./mumble.nix
    ./thunderbird.nix
  ];

  options.homeManager = {
    applications.communication = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable communication modules bundle.";
      };
    };
  };

  config = lib.mkIf config.homeManager.applications.communication.enable {
    homeManager.applications.communication = {
      discord.enable = true;
      element.enable = true;
      mumble.enable = true;
      thunderbird.enable = true;
    };
  };
}
