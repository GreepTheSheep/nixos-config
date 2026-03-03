{ config, lib, pkgs, ... }:

{
  options.nixos = {
    userEnvironment.runtimes.bun = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable Bun";
      };
    };
  };

  config = lib.mkIf config.nixos.userEnvironment.runtimes.bun.enable {
    environment.systemPackages = with pkgs; [
      bun
    ];
  };
}