{ config, lib, ... }:

{
  options.nixos = {
    system.nh = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable nh.";
      };
    };
  };

  config = lib.mkIf config.nixos.system.nh.enable {
    programs.nh = {
      enable = true;
      flake = "${config.users.users."${config.nixos.system.user.defaultuser.name}".home}/nixos-config";
      clean = lib.mkIf (!config.nixos.system.nixos.garbageCollect) {
        enable = true;
        dates = "weekly";
      };
    };
  };
}