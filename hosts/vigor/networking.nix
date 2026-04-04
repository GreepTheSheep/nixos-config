_:

{
  networking = {
    hostName = "vigor";

    interfaces = {
      enp3s0 = {
        wakeOnLan.enable = true;
        ipv4.addresses = [
          {
            address = "192.168.1.55";
            prefixLength = 24;
          }
        ];
        ipv6.addresses = [];
      };
    };

    defaultGateway.interface = "enp12s0";
    defaultGateway6.interface = "enp12s0";
  };

  nixos.system.networking = {
    enable = true;
    localIP = "192.168.1.55";
  };
}