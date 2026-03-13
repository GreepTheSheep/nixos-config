_:

{
  networking = {
    hostName = "vigor";
  };

  nixos.system.firewall.extraAllowedTCPPorts = [
    80
    443
  ];
}