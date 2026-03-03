{ config, lib, pkgs, ... }:

{
  options.nixos = {
    base.shell.zsh = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable Zsh.";
      };
    };
  };

  config = lib.mkIf config.nixos.base.shell.zsh.enable {
    environment.systemPackages = with pkgs; [
      zsh-powerlevel10k
    ];

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
        "lzd" = "lazydocker";
        "oxd" = "oxker";
      };
    };
  };
}