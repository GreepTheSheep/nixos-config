{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.homeManager.applications.communication.mumble;
in
{
  options.homeManager = {
    applications.communication.mumble = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable Mumble.";
      };

      enableTMLink = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable Trackmania's Proximity-chat Link app.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages =
      with pkgs;
      [
        mumble
      ]
      ++ lib.optionals cfg.enableTMLink [
        nur.repos.Greep.tm-mumble-link
        nur.repos.Greep.tm-mumble-link-tui
      ];
  };
}
