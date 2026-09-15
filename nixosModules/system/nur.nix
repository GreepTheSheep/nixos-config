{
  config,
  lib,
  nur,
  ...
}:

{
  options.nixos = {
    system.nur = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable NUR overrides.";
      };
    };
  };

  config = lib.mkIf config.nixos.system.nur.enable {
    nixpkgs.overlays = [
      nur.overlays.default
    ];
  };
}
