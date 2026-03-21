_:

{
  networking = {
    hostName = "varian";
  };

  nixos.system.networking = {
    enable = true;
    localIP = "192.168.1.56";
  };
}
