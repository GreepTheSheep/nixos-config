{ pkgs, config, lib, ... }:

{
  swapDevices = [
    {
      device = "/swapfile";
      size = 8192;
      priority = 10;
    }
  ];

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
    priority = 100;
  };

  # Hibernation — après install, récupérer l'offset avec:
  # sudo btrfs inspect-internal map-swapfile -r /swapfile
  #boot.resumeDevice = "/dev/disk/by-uuid/6fa07085-ca6f-4d6a-8d60-5dddb94d2d4e";
  #boot.kernelParams = [ "resume_offset=12854528" ];
}