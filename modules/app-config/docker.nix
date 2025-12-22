{ pkgs, ... }:

{
  virtualisation.docker = {
    enable = true;
    storageDriver = "btrfs";
    extraPackages = with pkgs; [
      lazydocker
      oxker
    ];
  };
}