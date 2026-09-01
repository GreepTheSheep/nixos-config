{ config, lib, ... }:

{
  imports = [
    ./backrest.nix
    ./caddy.nix
    ./crowdsec.nix
    ./gitea.nix
    ./privatebin.nix
    ./watchtower.nix
  ];

  options.host = {
    containers = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Docker containers for this host";
      };
    };
  };

  config = lib.mkIf (config.host.containers.enable && config.nixos.virtualisation.docker.enable) {
    systemd.tmpfiles.rules = [
      "d ${config.users.users."${config.nixos.system.user.defaultuser.name}".home}/docker-containers 0755 ${config.nixos.system.user.defaultuser.name} users"
    ];

    host.containers = {
      backrest.enable = true;
      caddy.enable = true;
      crowdsec.enable = true;
      gitea.enable = true;
      privatebin.enable = true;
      watchtower.enable = true;
    };
  };
}