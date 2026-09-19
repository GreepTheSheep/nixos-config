{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.homeManager = {
    applications.development.cloc = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable cloc.";
      };
    };
  };

  config = lib.mkIf config.homeManager.applications.development.cloc.enable {
    home.packages = with pkgs; [
      cloc
    ];
  };
}
