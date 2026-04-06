{ config, lib, inputs, pkgs, ... }:

let
  unstablePkgs = import inputs.nixpkgs-unstable {
    system = pkgs.system;
    config.allowUnfree = true;
  };
in
{
  options.homeManager = {
    applications.development.claudecode = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable Claude Code.";
      };
    };
  };

  config = lib.mkIf config.homeManager.applications.development.claudecode.enable {
    programs.claude-code = {
      enable = true;
      package = unstablePkgs.claude-code;
    };
  };
}