{
  config,
  lib,
  ...
}:

{
  options.nixos = {
    base.tools.cdemu = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable CDEmu.";
      };
    };
  };

  config = lib.mkIf config.nixos.base.tools.cdemu.enable {
    programs.cdemu = {
      enable = true;
      gui = lib.mkIf (!config.nixos.desktop.enable) false; # This option is true by default
    };
  };
}
