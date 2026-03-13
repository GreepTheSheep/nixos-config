_:

{
  networking = {
    hostName = "pomni";
  };

  nixos.system.firewall.extraAllowedTCPPorts = [
    80
    443
  ];
}