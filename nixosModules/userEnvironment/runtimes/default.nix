{ config, lib, ... }:

{
  imports = [
    ./bun.nix
    ./nodejs.nix
    ./python.nix
    ./rust.nix
  ];

  options.nixos = {
    userEnvironment.runtimes = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable runtimes modules bundle.";
      };
    };
  };

  config = lib.mkIf config.nixos.userEnvironment.runtimes.enable {
    nixos.userEnvironment.runtimes = {
      bun.enable = true;
      nodejs.enable = true;
      python.enable = true;
      rust.enable = true;
    };
  };
}