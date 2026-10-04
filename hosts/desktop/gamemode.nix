{
  config,
  lib,
  pkgs,
  username,
  ...
}:
let
  nvidiaSmi = "${config.hardware.nvidia.package.bin}/bin/nvidia-smi";
  clockRange = "1800,2100";
  lockClocks = "${nvidiaSmi} -lgc ${clockRange}";
  resetClocks = "${nvidiaSmi} -rgc";
  sudo = "${config.security.wrapperDir}/sudo -n";

  # Fullscreen windows whose class starts with one of these are not games.
  ignoredClasses = [
    "firefox"
    "microsoft-edge"
    "chromium"
    "mpv"
    "vlc"
    "kitty"
    "code"
    "thunar"
    "libreoffice"
    "soffice"
  ];

  # Treats every fullscreen window as a game: registers its process with
  # gamemode while it is fullscreen, and unregisters it when it leaves
  # fullscreen or closes. Maximized windows don't count.
  gamemodeFullscreenWatch = pkgs.writeShellScript "gamemode-fullscreen-watch" ''
    hyprctl=${pkgs.hyprland}/bin/hyprctl
    jq=${pkgs.jq}/bin/jq
    socat=${pkgs.socat}/bin/socat
    busctl=${pkgs.systemd}/bin/busctl
    ignore='${builtins.toJSON ignoredClasses}'

    gamemode() {
      "$busctl" --user call com.feralinteractive.GameMode /com/feralinteractive/GameMode \
        com.feralinteractive.GameMode "$1" i "$2" >/dev/null
    }

    registered=""
    sync() {
      current=$("$hyprctl" clients -j | "$jq" -r --argjson ignore "$ignore" '
        .[] | select(.fullscreen == 2)
            | select((.class | ascii_downcase) as $c | any($ignore[]; . as $p | $c | startswith($p)) | not)
            | .pid' | sort -u | xargs)
      for pid in $current; do
        case " $registered " in *" $pid "*) ;; *) gamemode RegisterGame "$pid" ;; esac
      done
      for pid in $registered; do
        case " $current " in *" $pid "*) ;; *) gamemode UnregisterGame "$pid" ;; esac
      done
      registered=$current
    }

    sync
    "$socat" -U - "UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" |
      while IFS= read -r line; do
        case "$line" in
          fullscreen\>\>* | openwindow\>\>* | closewindow\>\>*) sync ;;
        esac
      done
  '';
in
{
  programs.gamemode = {
    enable = true;
    settings.custom = {
      start = "${sudo} ${lockClocks}";
      end = "${sudo} ${resetClocks}";
    };
  };

  systemd.user.services.gamemode-fullscreen-watch = {
    description = "Turns on gamemode while a window is fullscreen";
    after = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${gamemodeFullscreenWatch}";
      Restart = "always";
      RestartSec = 5;
    };
  };

  users.users.${username}.extraGroups = [ "gamemode" ];

  security.sudo.extraRules = [
    {
      users = [ username ];
      commands = [
        {
          # sudoers splits commands on unescaped commas.
          command = "${nvidiaSmi} -lgc ${lib.replaceStrings [ "," ] [ "\\," ] clockRange}";
          options = [ "NOPASSWD" ];
        }
        {
          command = resetClocks;
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
}
