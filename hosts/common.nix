# Defaults for every host. A host overrides any of these in its variables.nix.
{
  gitUsername = "Oscar Andersson";
  gitEmail = "anderssonoscar03@gmail.com";

  browser = "firefox";
  terminal = "kitty";
  editor = "code";

  keyboardLayout = "se";
  wallpaper = ../wallpapers/cat-waves.png;

  monitors = "";
  hasNvidiaGpu = false;
  hasEdge = false;
}
