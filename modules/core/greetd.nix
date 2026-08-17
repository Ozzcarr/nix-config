{ pkgs, lib, config, ... }:
let
  sessions = "${config.services.displayManager.sessionData.desktops}/share/wayland-sessions";
  theme = "text=gray;time=gray;greet=gray;input=gray;action=gray;border=lightmagenta;title=lightmagenta;prompt=lightmagenta;button=lightmagenta";

  # Re-probes HDMI-A-1, which is forced off at boot (see hosts/desktop/default.nix), before Hyprland starts.
  hyprlandUwsmReset = pkgs.writeShellScript "hyprland-uwsm-reset-session" ''
    for f in /sys/class/drm/card*-HDMI-A-1/status; do
      [ -e "$f" ] && echo detect > "$f"
    done
    exec ${pkgs.uwsm}/bin/uwsm start -e -D Hyprland hyprland.desktop
  '';

  hyprlandUwsmSession =
    pkgs.writeTextDir "share/wayland-sessions/hyprland-uwsm-reset.desktop" ''
      [Desktop Entry]
      Name=Hyprland (uwsm)
      Comment=An intelligent dynamic tiling Wayland compositor
      Exec=${hyprlandUwsmReset}
      Type=Application
      DesktopNames=Hyprland
    ''
    // {
      providedSessions = [ "hyprland-uwsm-reset" ];
    };
in
{
  # Only expose our Hyprland (uwsm) session in the greeter.
  services.displayManager.sessionPackages = lib.mkForce [ hyprlandUwsmSession ];

  services.greetd = {
    enable = true;
    useTextGreeter = true;
    settings.default_session.command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-session --asterisks --sessions ${sessions} --theme '${theme}'";
  };
}
