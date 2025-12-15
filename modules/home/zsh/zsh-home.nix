_:

{
  home.file.".zshrc" = {
    enable = true;
    source = "${./.zshrc}";
  };
  home.file.".p10k.zsh" = {
    enable = true;
    source = "${./.p10k.zsh}";
  };
}
