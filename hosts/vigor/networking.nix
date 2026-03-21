_:

{
  networking = {
    hostName = "vigor";
  };

  nixos.system.networking = {
    enable = true;
    localIP = "192.168.1.55";
  };
}