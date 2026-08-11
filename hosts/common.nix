# Defaults for every host. A host overrides any of these in its variables.nix.
{
  gitUsername = "Oscar Andersson";
  gitEmail = "anderssonoscar03@gmail.com";

  # GUI editor only. $EDITOR is neovim, via programs.neovim.defaultEditor.
  editor = "code";

  keyboardLayout = "se";

  # The desktop wallpaper collection lives in the dotfiles repo (see
  # dotfiles.nix). This one copy stays here only because stylix needs an
  # actual file at build time: it derives the SDDM greeter's colors from it
  # and embeds it as the login background (modules/core/sddm.nix). Keep it in
  # sync by hand with the same file under dotfiles/wallpapers.
  wallpaper = ../wallpapers/lofiwallpaper.png;

  hasEdge = false;
}
