{ config, lib, pkgs, ... }:

{
  options.homeManager = {
    base.shell.bash = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable zsh.";
      };
    };
  };

  config = lib.mkIf config.homeManager.base.shell.zsh.enable {
    programs.zsh = {
      enable = true;
      enableCompletion = true;

      autosuggestions.enable = true;
      syntaxHighlighting.enable = true;

      initContent = "source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme";

      oh-my-zsh = {
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

    home.file.".zshrc" = {
      enable = true;
      source = "${./zsh/.zshrc}";
    };
    home.file.".p10k.zsh" = {
      enable = true;
      source = "${./zsh/.p10k.zsh}";
    };
  };
}