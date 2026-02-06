_:

{
  imports = [
    ./programs/firefox.nix
    ./programs/zsh.nix
    ./programs/gpg.nix
    ./programs/git.nix
    ./programs/rbw.nix

    # Gestion des AppImages
    ./programs/appimages/appimages.nix
  ];
}