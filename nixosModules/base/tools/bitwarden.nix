{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.nixos = {
    base.tools.bitwarden = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable Bitwarden tools.";
      };
    };
  };

  config = lib.mkIf config.nixos.base.tools.bitwarden.enable {
    environment.systemPackages =
      with pkgs;
      [
        bitwarden-cli
      ]
      ++ lib.optionals (config.nixos.desktop.enable) [
        bitwarden-desktop
        bitwarden-menu
      ];
  };
}
