_:

{
  networking = {
    hostName = "varian";

    interfaces = {
      end0 = {
        wakeOnLan.enable = true;
        ipv4.addresses = [
          {
            address = "192.168.1.56";
            prefixLength = 24;
          }
        ];
        ipv6.addresses = [ ];
      };
    };

    defaultGateway.interface = "end0";
    defaultGateway6.interface = "end0";
  };

  nixos.system.networking = {
    enable = true;
    localIP = "192.168.1.56";
  };
}
