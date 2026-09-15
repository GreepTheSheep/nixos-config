{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.homeManager = {
    applications.communication.mumble = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable Mumble.";
      };
    };
  };

  config = lib.mkIf config.homeManager.applications.communication.mumble.enable {
    home.packages = with pkgs; [
      mumble
    ];
  };
}
