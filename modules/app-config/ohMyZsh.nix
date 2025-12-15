{ lib, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    enableBashCompletion = true;
    
    ohMyZsh = {
      enable = true;
    };
  };
}