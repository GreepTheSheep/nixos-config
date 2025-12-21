{ pkgs, ... }:

{
  fonts.packages = with pkgs; [
    powerline-fonts
    meslo-lgs-nf
    nerd-fonts.zed-mono
    cascadia-code
    nerd-fonts.caskaydia-cove
    nerd-fonts.caskaydia-mono
  ];
}