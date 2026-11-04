{ config, lib, ... }:

{
  imports = [
    ./messaging
  ];

  options.host = {
    hermes-agent = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Hermes Agent config for this host";
      };
    };
  };

  config = lib.mkIf config.host.hermes-agent.enable {
    nixos.userEnvironment.hermes-agent.enable = true;

    services.hermes-agent.settings = {
      webapp = {
        enabled = true;
        host = "0.0.0.0";
        port = 9120;
        public_url = "http://192.168.1.56:9120";
      };
      group_sessions_per_user = false;
      approvals.destructive_slash_confirm = false;
    };

    # We need to open port 9120 for Hermes Webapp
    nixos.system.firewall = {
      extraAllowedTCPPorts = [
        9120
      ];
    };

    host.hermes-agent = {
      messaging.enable = true;
    };
  };
}
