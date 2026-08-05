{ ... }:
{
  programs.yazi = {
    enable = true;
    shellWrapperName = "yy";
    enableZshIntegration = true;
    enableBashIntegration = true;
  };
}
