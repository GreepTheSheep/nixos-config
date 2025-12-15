{ lib, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    enableBashCompletion = true;
    
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;

    promptInit = "source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme";

    ohMyZsh = {
      enable = true;
      # theme = "agnoster"; # Disabled for Powerlevel10k
      plugins = [
        "git"
        "sudo"
        "history"
        "command-not-found"
      ];
    };

    shellAliases = {
      ll = "ls -l";
      "nix-update" = "sudo nixos-rebuild switch";
      ".." = "cd ..";
      "q" = "exit";
      "cls" = "clear";
    };
  };
}