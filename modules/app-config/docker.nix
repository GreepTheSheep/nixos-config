{ pkgs, lib, ... }:

{
  virtualisation.docker = {
    enable = true;
    storageDriver = "btrfs";
    extraPackages = with pkgs; [
      lazydocker
      oxker
    ];
  };

  environment.systemPackages = with pkgs; lib.mkAfter [
    lazydocker
    oxker
  ];
}