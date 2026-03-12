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
        default = "Hello from ${networking.hostName}";
        example = "Hello !";
        description = "motd content";
      };
    };
  };

  config = lib.mkIf config.nixos.system.motd.enable {
    environment.etc.motd.text = config.nixos.system.motd.content;
  };
}