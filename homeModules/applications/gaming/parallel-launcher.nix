{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.homeManager = {
    applications.gaming.parallelLauncher = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable parallel launcher.";
      };
    };
  };

  config = lib.mkIf config.homeManager.applications.gaming.parallelLauncher.enable {
    home.packages = with pkgs; [
      (parallel-launcher.override {
        withDiscordRpc = true;
        extraRetroArchSettings = { };
      })
    ];
  };
}
