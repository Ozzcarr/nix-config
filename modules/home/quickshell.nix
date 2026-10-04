# Service wiring only; the QML lives in the dotfiles repo.
{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Called by the launcher: qalc for the calculator mode.
  home.packages = [ pkgs.libqalculate ];

  systemd.user.services.quickshell = {
    Unit = {
      Description = "Quickshell desktop shell";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
      # Own the tray watcher before autostart applets look for one.
      Before = [ "xdg-desktop-autostart.target" ];
    };

    Service = {
      ExecStart = "${lib.getExe' pkgs.quickshell "qs"} -c oz";
      Restart = "on-failure";
      RestartSec = 2;
      Slice = "session.slice";
    };

    Install.WantedBy = [ "hyprland-session.target" ];
  };

  # Quickshell only enables qmlls support if this file exists, then replaces it
  # with its own symlink, so it can't be a home-manager link.
  home.activation.quickshellQmlls = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    qmlls="${config.xdg.configHome}/quickshell/oz/.qmlls.ini"
    if [ ! -e "$qmlls" ] && [ ! -L "$qmlls" ]; then
      run mkdir -p "$(dirname "$qmlls")"
      run touch "$qmlls"
    fi
  '';
}
