{ config, lib, pkgs, ... }:

{
  options.nixos = {
    userEnvironment.runtimes.nodejs = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable Node.js";
      };
    };
  };

  config = lib.mkIf config.nixos.userEnvironment.runtimes.nodejs.enable {
    environment.systemPackages = with pkgs; [
      nodejs_24
    ];
  };
}