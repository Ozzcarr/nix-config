{ pkgs, vars, ... }:
{
  programs = {
    hyprland = {
      enable = true;
      withUWSM = false;
    };

    thunar = {
      enable = true;
      plugins = with pkgs; [
        thunar-archive-plugin
        thunar-volman
      ];
    };
  };

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-hyprland
    ];
    configPackages = [ pkgs.hyprland ];
  };

  # X11 itself is off -- this only sets the layout XWayland and SDDM inherit.
  services.xserver = {
    enable = false;
    xkb = {
      layout = vars.keyboardLayout;
      variant = "";
    };
  };

  environment.systemPackages = with pkgs; [
    ffmpegthumbnailer # video/image thumbnails in Thunar
  ];
}
