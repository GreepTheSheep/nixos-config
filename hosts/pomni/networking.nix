_:

{
  networking = {
    hostName = "pomni";
  };

  nixos.system.firewall = {
      extraAllowedTCPPorts = [
        24800
      ];

      extraAllowedUDPPorts = [
        24800
      ];
  };
}