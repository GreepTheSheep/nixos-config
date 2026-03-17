{ config, lib, ... }:

{
  options.host = {
    containers.watchtower = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Watchtower container for this host";
      };
    };
  };

  config = lib.mkIf config.host.containers.watchtower.enable
  {
    virtualisation.oci-containers.containers.watchtower = {
      image = "nickfedor/watchtower";
      volumes = [
        "/var/run/docker.sock:/var/run/docker.sock"
      ];
      environment = {
        WATCHTOWER_SCHEDULE = "0 0 6 * * *";
        WATCHTOWER_CLEANUP = "true";
        TZ = "Europe/Paris";
      };
      extraOptions = [
        "--network=host"
      ];
    };
  };
}