_:

{
  networking = {
    hostName = "varian.greep.fr";
  };

  nixos.system.networking = {
    enable = true;
    localIP = "192.168.1.56";
  };
}
