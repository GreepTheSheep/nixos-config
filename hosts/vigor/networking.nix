_:

{
  networking = {
    hostName = "vigor.greep.fr";
  };

  nixos.system.networking = {
    enable = true;
    localIP = "192.168.1.55";
  };
}