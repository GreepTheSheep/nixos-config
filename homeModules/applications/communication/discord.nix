{ config, lib, pkgs, ... }:

{
  options.homeManager = {
    applications.communication.discord = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable Discord.";
      };
    };
  };

  config = lib.mkIf config.homeManager.applications.communication.discord.enable {
    programs = {
      discord.enable = true;
      vesktop.enable = true;
    };

    home.packages = with pkgs; [
      legcord # Include Legcord, an alternative lightweight Discord client.
    ];
  };
}