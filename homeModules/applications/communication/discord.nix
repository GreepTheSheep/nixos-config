{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.homeManager.applications.communication.discord;
in
{
  options.homeManager = {
    applications.communication.discord = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable Discord.";
      };

      useVesktop = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Use Vesktop instread of Discord.";
      };

      installLegcord = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Install Legcord.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    programs = {
      discord.enable = cfg.enable && !cfg.useVesktop;
      vesktop.enable = cfg.enable && cfg.useVesktop;
    };

    home.packages = with pkgs lib.mkIf cfg.installLegcord; [
      legcord # Include Legcord, an alternative lightweight Discord client.
    ];
  };
}
