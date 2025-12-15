{ pkgs, ... }:

{
  users.users.greep = {
    isNormalUser = true;
    description = "Greep";
    home = "/home/greep";
    shell = pkgs.zsh;
    hashedPassword = "$6$wpoCAeUVymh0/wJ8$.T2bnLYhQXc8ReqvbPVaH89g9cVeHuQVKHaBTCgTdH0xP6oAdMNWs7R5vkatJClJYbfG1u9EnXr8ELv2fPC.3/";
    extraGroups = [ "networkmanager" "wheel" "video" "audio" ];
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    users = {
      greep = import ./greep-home.nix;
    };
  };
}
