{ config, lib, pkgs, ... }:

{
  options.nixos = {
    userEnvironment.runtimes.python = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable Python";
      };
    };
  };

  config = lib.mkIf config.nixos.userEnvironment.runtimes.python.enable {
    environment.systemPackages = with pkgs; [
      python315
      virtualenv
    ];
  };
}