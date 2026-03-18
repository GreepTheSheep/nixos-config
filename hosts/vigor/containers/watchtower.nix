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
    sops.secrets."docker/watchtower/vigor-notification-url" = {};

    sops.templates."watchtower.env".content = ''
      WATCHTOWER_SCHEDULE=0 0 6 * * *;
      WATCHTOWER_CLEANUP=true
      WATCHTOWER_NOTIFICATION_URL=${config.sops.placeholder."docker/watchtower/vigor-notification-url"}
    '';

    virtualisation.oci-containers.containers.watchtower = {
      image = "nickfedor/watchtower";
      volumes = [
        "/var/run/docker.sock:/var/run/docker.sock"
      ];
      environmentFiles = [
        config.sops.templates."watchtower.env".path
      ];
      environment = {
        TZ = "Europe/Paris";
      };
      extraOptions = [
        "--network=host"
      ];
    };
  };
}