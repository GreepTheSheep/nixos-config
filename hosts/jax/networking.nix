_:

{
  networking = {
    hostName = "jax";

    interfaces = {
      enp12s0 = {
        wakeOnLan.enable = true;
        ipv4.addresses = [
          {
            address = "192.168.1.50";
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
    localIP = "192.168.1.50";
  };

  # In VM builds, enp12s0 is not available
  virtualisation.vmVariant = {
    networking.interfaces.enp12s0 = lib.mkForce { };
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