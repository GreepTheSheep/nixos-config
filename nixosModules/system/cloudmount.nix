{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.nixos = {
    system.cloudmount = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable mounting of Greep Cloud.";
      };
      useLocalAddress = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Use local address of Greep Cloud.";
      };
    };
  };

  config = lib.mkIf config.nixos.system.cloudmount.enable {
    services.davfs2.enable = true;
    environment.systemPackages = [ pkgs.davfs2 ];

    sops.secrets."nextcloud/password" = { };

    environment.etc."davfs2/secrets".source = config.sops.templates."davfs2-secrets".path;

    sops.templates."davfs2-secrets" = {
      content = ''
        ${lib.optionalString config.nixos.system.cloudmount.useLocalAddress "http://192.168.1.55:8001"}${
          lib.optionalString (!config.nixos.system.cloudmount.useLocalAddress) "https://cloud.greep.fr"
        }/remote.php/webdav/ greep ${config.sops.placeholder."nextcloud/password"}
      '';
      mode = "0600";
    };

    # Créer le point de montage
    systemd.tmpfiles.rules = [
      "d /mnt/cloud 0755 ${config.nixos.system.user.defaultuser.name} users -"
    ];

    # Unité de montage systemd qui se monte/démonte automatiquement avec le réseau
    systemd.mounts = [
      {
        description = "Nextcloud WebDAV Mount";
        what = "${lib.optionalString config.nixos.system.cloudmount.useLocalAddress "http://192.168.1.55:8001"}${
          lib.optionalString (!config.nixos.system.cloudmount.useLocalAddress) "https://cloud.greep.fr"
        }/remote.php/webdav/";
        where = "/mnt/cloud";
        type = "davfs";
        options = "rw,uid=1000,gid=1000,_netdev,noauto,x-systemd.automount,x-systemd.idle-timeout=60";

        # Monte uniquement quand le réseau est disponible
        wantedBy = [ "remote-fs.target" ];
        after = [ "network-online.target" ];
        requires = [ "network-online.target" ];
      }
    ];

    # Automount pour monter à la demande
    systemd.automounts = [
      {
        description = "Nextcloud WebDAV Automount";
        where = "/mnt/cloud";
        wantedBy = [ "multi-user.target" ];
      }
    ];
  };
}
