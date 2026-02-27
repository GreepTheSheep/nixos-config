{ config, lib, ... }:

{
  imports = [
    ./bash.nix
    ./console.nix
    ./tmux.nix
    ./zsh.nix
  ];

  options.nixos = {
    base.shell = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable shell modules bundle.";
      };
    };
  };

  config = lib.mkIf config.nixos.base.shell.enable {
    nixos.base.shell = {
      bash.enable = true;
      console.enable = true;
      tmux.enable = true;
      zsh.enable = true;
    };
  };
}