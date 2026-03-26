{ config, lib, inputs, ... }:

let
  fetchBlocklist = name: inputs.${name};

  enabledBlocklists = [
    "ads"
    "malware"
    "phishing"
    "ransomware"
    "tracking"
    # "oisd-big"
    # "oisd-small"
  ];

  localIP = config.nixos.system.networking.localIP or null;

  mkHostEntries =
    ip: hosts:
    let
      effectiveIP = if localIP != null && ip == localIP then "127.0.0.1" else ip;
    in
    {
      ${effectiveIP} = lib.mkDefault hosts;
    };

  # https://github.com/xerhaxs/nixos/blob/main/nixosModules/system/networking.nix#L40
  hostEntries = lib.mkMerge [
    (mkHostEntries "192.168.1.50" [
      "greep.local"
    ])
  ];

in

{
  options.nixos = {
    system.networking = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable networking and network config.";
      };

      localIP = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        example = "192.168.1.50";
        description = "Local IP address of this host. Host entries matching this IP will use 127.0.0.1 instead.";
      };

      blocklists = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable DNS blocklists.";
        };

        urls = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = enabledBlocklists;
          description = "List of blocklist URLs to use.";
        };
      };
    };
  };

  config = lib.mkIf config.nixos.system.networking.enable {
    networking = {
      nftables.enable = true;

      networkmanager = {
        enable = true;
        dns = "default";
        wifi = {
          scanRandMacAddress = true;
          powersave = false;
          macAddress = "stable";
        };
      };

      wireless = {
        enable = true;
        userControlled = true;
      };

      enableIPv6 = true;
      tempAddresses = "default";
      useDHCP = lib.mkDefault (if localIP == null then true else false);

      hosts = hostEntries;

      hostFiles = lib.mkIf config.nixos.system.networking.blocklists.enable (
        map fetchBlocklist config.nixos.system.networking.blocklists.urls
      );

      defaultGateway = if localIP == null then null else "192.168.1.1";
      defaultGateway6 = if localIP == null then null else "fe80::1";

      nameservers = [
        "94.140.14.14"
        "1.1.1.1"
        "94.140.15.15"
        "1.0.0.1"
        "9.9.9.9"
        "2a10:50c0::ad1:ff"
        "2606:4700:4700::1111"
        "2a10:50c0::2:ff"
        "2606:4700:4700::1001"
        "2620:fe::fe"
        "2620:fe::9"
      ];
    };

    users.users."${config.nixos.system.user.defaultuser.name}" = {
      extraGroups = [ "networkmanager" ];
    };
  };
}