{ config, lib, pkgs, ... }:

{
  options.nixos = {
    base.tools.backrest = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable restic and backrest.";
      };

      openFirewall = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Open firewall for backrest.";
      };
    };
  };

  config = lib.mkIf config.nixos.base.tools.backrest.enable {
    environment.systemPackages = with pkgs; lib.mkAfter [
      restic
      backrest
    ];

    # Backrest is accessed via web port 9898, we need to open it up using a firewall rule and environment variable
    nixos.system.firewall.extraAllowedTCPPorts = lib.mkIf config.nixos.base.tools.backrest.openFirewall [ 9898 ];
    environment.variables = {
      BACKREST_PORT = lib.mkIf config.nixos.base.tools.backrest.openFirewall "0.0.0.0:9898";
      BACKREST_RESTIC_COMMAND = "${pkgs.restic}/bin/restic";
    };

    # Create a systemd service to run backrest on startup
    systemd.services.backrest = {
      description = "Backrest Backup Service";
      wantedBy = [ "multi-user.target" ];
      path = with pkgs; [ backrest restic ];
      environment = {
        BACKREST_PORT = lib.mkIf config.nixos.base.tools.backrest.openFirewall "0.0.0.0:9898";
        BACKREST_RESTIC_COMMAND = "${pkgs.restic}/bin/restic";
        HOME = "/root";
        TZ = "Europe/Paris";
      };
      serviceConfig = {
        ExecStart = "${pkgs.backrest}/bin/backrest";
        Restart = "always";
      };
    };

    # Create a host to redirect http://backrest/ to the backrest service
    networking.hosts = {
      "127.0.0.1" = lib.mkAfter [ "backrest.local" ];
    };
  };
}