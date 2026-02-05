{ pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; lib.mkAfter [
    restic
    backrest
  ];

  # Backrest is accessed via web port 9898, we need to open it up using a firewall rule and environment variable
  networking.firewall.allowedTCPPorts = [ 9898 ];
  environment.variables.BACKREST_PORT = "0.0.0.0:9898";
}