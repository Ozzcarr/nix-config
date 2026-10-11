{
  pkgs,
  lib,
  config,
  username,
  vars,
  ...
}:
let
  sessions = "${config.services.displayManager.sessionData.desktops}/share/wayland-sessions";
  theme = "text=gray;time=gray;greet=gray;input=gray;action=gray;border=lightmagenta;title=lightmagenta;prompt=lightmagenta;button=lightmagenta";
  hyprland = config.programs.hyprland.package;

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

  # The wallpaper script copies the current wallpaper here, since the greeter
  # can't read the home directory.
  greeterState = "/var/lib/oz-greeter";

  # The Quickshell greeter: shell.qml, plus the Stylix colors as a QML type.
  scheme = pkgs.writeText "Scheme.qml" ''
    import QtQuick

    QtObject {
    ${lib.concatMapStrings (name: ''
      readonly property color ${name}: "#${config.lib.stylix.colors.${name}}"
    '') (map (i: "base0${lib.toHexString i}") (lib.range 0 15))}}
  '';
  greeter = pkgs.linkFarm "oz-greeter" {
    "shell.qml" = ./greeter/shell.qml;
    "Scheme.qml" = scheme;
  };

  # A bare Hyprland that only runs the greeter, and exits with it.
  greeterHyprland = pkgs.writeText "greeter.lua" ''
    hl.config({
      input = {
        kb_layout = "${vars.keyboardLayout}",
        kb_options = "caps:super",
        numlock_by_default = true,
      },
      misc = {
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
      },
      animations = {
        enabled = false,
      },
      ecosystem = {
        no_update_news = true,
        no_donation_nag = true,
      },
    })

    hl.on("hyprland.start", function()
      hl.exec_cmd("${pkgs.quickshell}/bin/qs -p ${greeter}; ${hyprland}/bin/hyprctl dispatch 'hl.dsp.exit()'")
    end)
  '';

  tuigreet = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-session --asterisks --sessions ${sessions} --theme '${theme}'";

  # Runs the Quickshell greeter, and falls back to tuigreet unless it launched
  # a session: a broken greeter must never be a machine you can't log into.
  greet = pkgs.writeShellScript "oz-greet" ''
    export OZ_GREETER_DONE="$(${pkgs.coreutils}/bin/mktemp -u)"
    export OZ_GREETER_USER=${username}
    export OZ_GREETER_SESSION=${hyprlandUwsmReset}
    export OZ_GREETER_WALLPAPER=${greeterState}/wallpaper
    export OZ_GREETER_AVATAR=${../home/hyprland/avatar.png}

    ${hyprland}/bin/start-hyprland -- -c ${greeterHyprland} >/dev/null 2>&1

    if [ -e "$OZ_GREETER_DONE" ]; then
      rm -f "$OZ_GREETER_DONE"
      exit 0
    fi
    exec ${tuigreet}
  '';
in
{
  # Only expose our Hyprland (uwsm) session in the greeter.
  services.displayManager.sessionPackages = lib.mkForce [ hyprlandUwsmSession ];

  systemd.tmpfiles.rules = [ "d ${greeterState} 0755 ${username} users -" ];

  services.greetd = {
    enable = true;
    # Gives the tuigreet fallback its console.
    useTextGreeter = true;
    settings.default_session.command = "${greet}";
  };
}
