{ config, lib, ... }:

{
  options.host = {
    containers.wireguard-server = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable the Wireguard server container for this host (wg-easy)";
      };
    };
  };

  config =
    let
      user = config.nixos.system.user.defaultuser.name;
      home = config.users.users."${user}".home;
      directory = "${home}/docker-containers/wireguard-server";
    in
    lib.mkIf config.host.containers.wireguard-server.enable {
      systemd.tmpfiles.rules = [
        "d ${directory} 0755 ${user} users"
        "d ${directory}/etc_wireguard 0755 ${user} users"
      ];

      sops.secrets = {
        "docker/wireguard/admin-username" = { };
        "docker/wireguard/admin-password" = { };
      };

      sops.templates."wireguard-server.env".content = ''
        INIT_USERNAME=${config.sops.placeholder."docker/wireguard/admin-username"}
        INIT_PASSWORD=${config.sops.placeholder."docker/wireguard/admin-password"}
      '';

      virtualisation.oci-containers.containers.wireguard-server = {
        image = "ghcr.io/wg-easy/wg-easy:15";
        volumes = [
          "${directory}/etc_wireguard:/etc/wireguard"
        ];
        environmentFiles = [
          config.sops.templates."wireguard-server.env".path
        ];
        environment = {
          TZ = "Europe/Paris";
          INIT_ENABLED = "true";
          INIT_HOST = "vigor.greep.fr";
          INIT_PORT = "51820";
          INIT_DNS = "1.1.1.1";
          INIT_IPV4_CIDR = "10.8.0.0/24";
          INIT_IPV6_CIDR = "fddd:2c4:1f30:beef::/64";
          INIT_ALLOWED_IPS = "0.0.0.0/0, ::/0";
          # Web UI over HTTP (LAN only)
          INSECURE = "true";
          DISABLE_VERSION_CHECK = "true";
        };
        ports = [
          "51820:51820/udp"
          "51821:51821/tcp"
        ];
        extraOptions = [
          "--network=host"
          "--security-opt=no-new-privileges:true"
          "--sysctl=net.ipv4.conf.all.src_valid_mark=1"
          "--sysctl=net.ipv4.ip_forward=1"
        ];
        capabilities = {
          NET_ADMIN = true;
          SYS_MODULE = true;
        };
      };
    };
}
