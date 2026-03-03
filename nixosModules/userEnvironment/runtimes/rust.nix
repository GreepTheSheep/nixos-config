{ config, lib, pkgs, ... }:

{
  options.nixos = {
    userEnvironment.runtimes.rust = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable Rust with rustup";
      };
    };
  };

  config = lib.mkIf config.nixos.userEnvironment.runtimes.rust.enable {
    environment.systemPackages = with pkgs; [
      rustup
    ];
  };
}