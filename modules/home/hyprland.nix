# Session/systemd integration only. The actual hyprland.conf, hyprlock.conf
# and hypridle.conf content is owned by the dotfiles repo (see dotfiles.nix) -
# each of these programs' home-manager modules is kept "enabled" purely to
# retain the systemd session wiring and the runtime package, but with
# settings = {} so home-manager generates no config of its own, and points at
# the dotfiles-managed hyprland.conf via a `source` line instead.
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    awww
    grim
    slurp
    wl-clipboard
    swappy
    ydotool
    hyprpolkitagent
    hyprshot
    hyprland-qtutils # needed for banners and ANR messages
  ];
  systemd.user.targets.hyprland-session.Unit.Wants = [
    "xdg-desktop-autostart.target"
  ];

  systemd.user.sessionVariables.GDK_PIXBUF_MODULE_FILE = "${pkgs.librsvg}/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache";

  home.file = {
    ".avatar.icon".source = ./hyprland/avatar.png;
    ".config/avatar.png".source = ./hyprland/avatar.png;
  };

  wayland.windowManager.hyprland = {
    enable = true;
    package = pkgs.hyprland;
    configType = "hyprlang";
    systemd = {
      enable = true;
      enableXdgAutostart = true;
    };
    xwayland.enable = true;
    settings = { };
    extraConfig = "source = ~/dotfiles/hyprland/.config/hypr/hyprland.conf";
  };

  programs.hyprlock = {
    enable = true;
    package = pkgs.hyprlock;
    settings = { };
  };

  services.hypridle = {
    enable = true;
    package = pkgs.hypridle;
    settings = { };
  };
}
