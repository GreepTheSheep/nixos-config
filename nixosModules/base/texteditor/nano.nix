{ config, lib, ... }:

{
  options.nixos = {
    base.texteditor.nano = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable Nano.";
      };
    };
  };

  config = lib.mkIf config.nixos.base.texteditor.nano.enable {
    programs.nano.enable = true;
    programs.nano.syntaxHighlight = true;
  };
}