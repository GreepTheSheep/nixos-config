{ config, lib, pkgs, ... }:

{
  home.file.".zshrc".source = ./.zshrc;
  home.file.".p10k.zsh".source = ./.p10k.zsh;
}
