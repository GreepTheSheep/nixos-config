{ pkgs, ... }:

{
  programs.rbw = {
    enable = true;
    settings = {
      base_url = "https://bw.greep.fr";
      email = "greep@greep.fr";
    };
  };
}