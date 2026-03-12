{ config, lib, ... }:

{
  options.nixos = {
    system.motd = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable motd.";
      };

      content = lib.mkOption {
        type = lib.types.str;
        default = "Hello !";
        example = "This is the content of the MOTD";
        description = "motd content";
      };
    };
  };

  config = lib.mkIf config.nixos.system.motd.enable {
    users.motd = config.nixos.system.motd.content;
  };
}