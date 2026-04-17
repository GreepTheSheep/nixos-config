{ pkgs, config, lib, ... }:

{

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/ad224100-79ad-4d83-8591-c74930470a6b";
      fsType = "btrfs";
      options = [ "subvol=@" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/ADED-F0C2";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/ad224100-79ad-4d83-8591-c74930470a6b";
      fsType = "btrfs";
      options = [ "subvol=@home" ];
    };

  fileSystems."/nix" =
    { device = "/dev/disk/by-uuid/ad224100-79ad-4d83-8591-c74930470a6b";
      fsType = "btrfs";
      options = [ "subvol=@nix" ];
    };

  fileSystems."/var/log" =
    { device = "/dev/disk/by-uuid/ad224100-79ad-4d83-8591-c74930470a6b";
      fsType = "btrfs";
      options = [ "subvol=@log" ];
    };

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