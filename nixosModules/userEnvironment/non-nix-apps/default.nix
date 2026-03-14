{ config, lib, ... }:

{
  imports = [
    ./affine.nix
    ./helium.nix
    ./feishin.nix
  ];

  options.nixos = {
    userEnvironment.non-nix-apps = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable non-nix apps bundle.";
      };
    };
  };

  config = lib.mkIf config.nixos.userEnvironment.non-nix-apps.enable {
    nixos.userEnvironment.non-nix-apps = {
      affine.enable = true;
      helium.enable = true;
      feishin.enable = true;
    };
  };
}