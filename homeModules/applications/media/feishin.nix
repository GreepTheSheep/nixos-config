{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.homeManager = {
    applications.media.feishin = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable Feishin.";
      };
    };
  };

  config = lib.mkIf config.homeManager.applications.media.feishin.enable {
    home.packages = with pkgs; [
      nur.repos.Greep.feishin
    ];
  };
}
