{ config, lib, ... }:

{
  imports = [
    ./arr.nix
    ./backrest.nix
    ./caddy.nix
    ./cf-ddns.nix
    ./h5ai.nix
    ./immich.nix
    ./jellyfin.nix
    ./nextcloud.nix
    ./seerr.nix
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

    virtualisation.oci-containers.backend = "docker";

    host.containers = {
      arr.enable = true;
      backrest.enable = true;
      caddy.enable = true;
      cfddns.enable = false;
      h5ai.enable = true;
      immich = {
        enable = true;
        enableGPU = true;
      };
      jellyfin = {
        enable = true;
        enableGPU = true;
      };
      nextcloud.enable = true;
      seerr.enable = true;
      watchtower.enable = true;
    };
  };
}