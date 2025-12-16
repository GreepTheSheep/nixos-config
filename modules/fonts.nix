{ pkgs, ... }:

{
  fonts.packages = with pkgs; [
    powerline-fonts
    meslo-lgs-nf
    nerd-fonts.zed-mono
  ];
}