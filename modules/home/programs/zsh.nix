_:

{
  home.file.".zshrc" = {
    enable = true;
    source = "${./zsh/.zshrc}";
  };
  home.file.".p10k.zsh" = {
    enable = true;
    source = "${./zsh/.p10k.zsh}";
  };
}
