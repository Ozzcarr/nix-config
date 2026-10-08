# Session/systemd wiring only; the config itself lives in the dotfiles repo.
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
    hyprsunset
    hyprland-qtutils # needed for banners and ANR messages
  ];
  systemd.user.targets.hyprland-session.Unit.Wants = [
    "xdg-desktop-autostart.target"
  ];

  # Auto-switches hyprmoncfg monitor profiles on hotplug/dock/lid events.
  systemd.user.services.hyprmoncfgd = {
    Unit = {
      Description = "Hyprland monitor profile daemon (hyprmoncfgd)";
      After = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "/run/current-system/sw/bin/hyprmoncfgd";
      Restart = "on-failure";
      RestartSec = 2;
    };
    Install.WantedBy = [ "default.target" ];
  };

  systemd.user.sessionVariables.GDK_PIXBUF_MODULE_FILE = "${pkgs.librsvg}/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache";

  home.file = {
    ".avatar.icon".source = ./hyprland/avatar.png;
    ".config/avatar.png".source = ./hyprland/avatar.png;
  };

  wayland.windowManager.hyprland = {
    enable = true;
    package = pkgs.hyprland;
    configType = "lua";
    systemd = {
      enable = true;
      enableXdgAutostart = true;
    };
    xwayland.enable = true;
    settings = { };
    # The monitors require is duplicated from config/ for hyprmoncfg's sake.
    extraConfig = ''
      require("config")
      if package.searchpath("monitors", package.path) then
        require("monitors")
      end
    '';
  };
}
