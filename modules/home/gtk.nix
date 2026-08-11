{ pkgs, lib, ... }:
let
  catppuccinGtk = pkgs.catppuccin-gtk.override {
    accents = [ "mauve" ];
    variant = "mocha";
  };
  themeName = "catppuccin-mocha-mauve-standard";
in
{
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = lib.mkForce "prefer-dark";
      monospace-font-name = lib.mkForce "JetBrainsMonoNF 12";
    };
  };

  gtk = {
    # Icon theme and extraConfig apply without this, but the theme package
    # below is only actually installed (home.packages) when this is true.
    enable = true;
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    # Symbolic icons (tray icons among them) render in whatever color this
    # theme's CSS gives them, which is how they end up Catppuccin-tinted.
    theme = {
      name = themeName;
      package = catppuccinGtk;
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
    gtk4 = {
      extraConfig = {
        gtk-application-prefer-dark-theme = 1;
      };
      theme = {
        name = themeName;
        package = catppuccinGtk;
      };
    };
  };
}
