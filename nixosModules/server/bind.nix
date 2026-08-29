{ config, lib, pkgs, ... }:

let
  cfg = config.nixos.server.bind;

  nsList = zone: lib.unique ([ zone.ns ] ++ zone.nameservers);

  mkZoneFile = zone: pkgs.writeText "named.${zone.name}" ''
    $TTL 3600
    @   IN SOA ${zone.ns}.${zone.name}. admin.${zone.name}. (
      ${zone.serial}  ; Serial
      7200            ; Refresh
      3600            ; Retry
      1209600         ; Expire
      300 )           ; Negative Cache TTL

    ${lib.concatStringsSep "\n" (map (ns: ''
      @   IN NS  ${ns}.${zone.name}.
    '') (nsList zone))}
    ${lib.optionalString (zone.ipv4 != null)
      (lib.concatStringsSep "\n" (map (ns: ''
        ${ns} IN A ${zone.ipv4}
      '') (nsList zone)))}
    ${lib.optionalString (zone.ipv6 != null)
      (lib.concatStringsSep "\n" (map (ns: ''
        ${ns} IN AAAA ${zone.ipv6}
      '') (nsList zone)))}
    ${builtins.concatStringsSep "\n" (lib.mapAttrsToList (name: records: ''
      ${name} ${lib.concatStringsSep "\n      " records}
    '') zone.records)}
  '';

  mkReverseZone = zone: pkgs.writeText "named.${zone.prefix}.in-addr.arpa" ''
    $TTL 3600
    @   IN SOA ${zone.ns}.${zone.domain}. admin.${zone.domain}. (
      ${zone.serial}  ; Serial
      7200            ; Refresh
      3600            ; Retry
      1209600         ; Expire
      300 )           ; Negative Cache TTL

    ${lib.concatStringsSep "\n" (map (ns: ''
      @   IN NS  ${ns}.${zone.domain}.
    '') (nsList zone))}
    ${builtins.concatStringsSep "\n" (map (entry: ''
      ${entry.octet}.${zone.prefix}.in-addr.arpa. IN PTR ${entry.fqdn}.
    '') zone.entries)}
  '';

in

{
  options.nixos = {
    server.bind = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable BIND nameserver.";
      };

      openFirewall = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Open DNS (TCP/UDP 53) in the firewall.";
      };

      forwarders = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [
          "1.1.1.1"
          "8.8.8.8"
          "9.9.9.9"
          "94.140.14.14"
        ];
        example = [ "192.168.1.1" ];
        description = "Upstream DNS servers used for recursive resolution.";
      };

      allowRecursion = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [
          "127.0.0.0/8"
          "192.168.1.0/24"
          "::1/128"
        ];
        description = "Networks allowed to use recursion.";
      };

      allowQuery = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [
          "localhost"
          "localnets"
        ];
        description = "Networks allowed to query the server.";
      };

      zones = lib.mkOption {
        type = lib.types.listOf (lib.types.submodule {
          options = {
            name = lib.mkOption {
              type = lib.types.str;
              example = "greep.local";
              description = "Zone name (domain).";
            };
            ns = lib.mkOption {
              type = lib.types.str;
              default = "ns1";
              example = "ns2";
              description = "Primary nameserver label for the zone. Automatically included in nameservers.";
            };
            nameservers = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [];
              example = [ "ns1" "ns2" "ns3" ];
              description = "Additional nameserver labels to declare in NS/glue records.";
            };
            serial = lib.mkOption {
              type = lib.types.str;
              default = "1";
              example = "2025082701";
              description = "Zone serial. Bump when editing records.";
            };
            ipv4 = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              example = "192.168.1.55";
              description = "IPv4 of the zone apex (SOA/NS target).";
            };
            ipv6 = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = "IPv6 of the zone apex.";
            };
            records = lib.mkOption {
              type = lib.types.attrsOf (lib.types.listOf lib.types.str);
              default = {};
              example = {
                "nas" = [ "A 192.168.1.60" ];
                "www" = [ "CNAME vigor.greep.local" ];
                "@" = [ "MX 10 mail.greep.local" ];
              };
              description = "DNS records, attribute name -> list of RDATA.";
            };
          };
        });
        default = [];
        example = [
          {
            name = "greep.local";
            ipv4 = "192.168.1.55";
            records."vigor" = [ "A 192.168.1.55" ];
          }
        ];
        description = "Authoritative forward zones served by BIND.";
      };

      forwardZones = lib.mkOption {
        type = lib.types.listOf (lib.types.submodule {
          options = {
            name = lib.mkOption {
              type = lib.types.str;
              example = "greep.fr";
              description = "Domain to forward to an authoritative upstream server.";
            };
            forwarders = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [];
              example = [ "203.0.113.10" ];
              description = "Authoritative servers for this zone. Falls back to cfg.forwarders when empty.";
            };
          };
        });
        default = [];
        example = [
          {
            name = "greep.fr";
            forwarders = [ "203.0.113.10" ];
          }
        ];
        description = "Zones forwarded to a specific authoritative server instead of the default forwarders.";
      };

      reverseZones = lib.mkOption {
        type = lib.types.listOf (lib.types.submodule {
          options = {
            prefix = lib.mkOption {
              type = lib.types.str;
              example = "1.168.192";
              description = "Reversed network octets for the reverse zone.";
            };
            domain = lib.mkOption {
              type = lib.types.str;
              example = "greep.local";
              description = "Domain the PTR records point to.";
            };
            ns = lib.mkOption {
              type = lib.types.str;
              default = "ns1";
              example = "ns2";
              description = "Primary nameserver label for the zone. Automatically included in nameservers.";
            };
            nameservers = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [];
              example = [ "ns1" "ns2" "ns3" ];
              description = "Additional nameserver labels to declare in NS records.";
            };
            serial = lib.mkOption {
              type = lib.types.str;
              default = "1";
              description = "Zone serial. Bump when editing records.";
            };
            entries = lib.mkOption {
              type = lib.types.listOf (lib.types.submodule {
                options = {
                  octet = lib.mkOption {
                    type = lib.types.str;
                    example = "55";
                    description = "Host octet of the address (last part of the IP).";
                  };
                  fqdn = lib.mkOption {
                    type = lib.types.str;
                    example = "vigor";
                    description = "Hostname (relative to the domain).";
                  };
                };
              });
              default = [];
              example = [
                { octet = "55"; fqdn = "vigor"; }
              ];
              description = "PTR records: host octet -> hostname.";
            };
          };
        });
        default = [];
        description = "Authoritative reverse (in-addr.arpa) zones.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.bind = {
      enable = true;
      forwarders = cfg.forwarders;
      zones = map (zone: {
        name = zone.name;
        master = true;
        file = mkZoneFile zone;
        allowQuery = cfg.allowQuery;
      }) cfg.zones
      ++ map (zone: {
        name = "${zone.prefix}.in-addr.arpa";
        master = true;
        file = mkReverseZone zone;
        allowQuery = cfg.allowQuery;
      }) cfg.reverseZones;

      extraOptions = ''
        recursion yes;
        allow-query { ${lib.concatMapStringsSep " " (x: "${x};") cfg.allowQuery} };
        allow-recursion { ${lib.concatMapStringsSep " " (x: "${x};") cfg.allowRecursion} };
        allow-transfer { none; };
        dnssec-validation auto;
        notify no;
      '';

      extraConfig = lib.concatMapStrings (zone: ''
        zone "${zone.name}" {
          type forward;
          forward only;
          forwarders { ${lib.concatMapStringsSep " " (f: "${f};") (if zone.forwarders != [] then zone.forwarders else cfg.forwarders)} };
        };
      '') cfg.forwardZones;
    };

    nixos.system.firewall = lib.mkIf cfg.openFirewall {
      extraAllowedTCPPorts = [ 53 ];
      extraAllowedUDPPorts = [ 53 ];
    };
  };
}
