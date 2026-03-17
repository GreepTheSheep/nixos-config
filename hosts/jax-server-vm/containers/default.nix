{ config, lib, ... }:

{
  imports = [
    ./caddy.nix
    ./watchtower.nix
    ./whoami.nix
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

    virtualisation.oci-containers.backend = "docker";

    host.containers = {
      caddy.enable = lib.mkDefault false;
      watchtower.enable = true;
      whoami.enable = true;
    };
  };
}