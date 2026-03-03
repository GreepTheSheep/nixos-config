{ config, lib, pkgs, ... }:

{
  options.homeManager = {
    base.shell.zsh = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable zsh.";
      };
    };
  };

  config = lib.mkIf config.homeManager.base.shell.zsh.enable {
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