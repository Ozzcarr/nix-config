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

    ps=${pkgs.procps}/bin/ps
    pgrep=${pkgs.procps}/bin/pgrep
    taskset=${pkgs.util-linux}/bin/taskset

    gamemode() {
      "$busctl" --user call com.feralinteractive.GameMode /com/feralinteractive/GameMode \
        com.feralinteractive.GameMode "$1" i "$2" >/dev/null
    }

    moved="$XDG_RUNTIME_DIR/gamemode-moved-pids"
    isolate() {
      ecores=$(cat /sys/devices/cpu_atom/cpus)
      keep=$("$ps" -eo pid=,ppid=,comm= | ${pkgs.gawk}/bin/awk -v games="$1" '
        { pp[$1] = $2; name[$1] = $3 }
        END {
          n = split(games, g, " ")
          for (i = 1; i <= n; i++) {
            root = g[i]
            for (p = g[i]; p > 1; p = pp[p]) if (name[p] == "reaper") { root = p; break }
            roots[root] = 1
          }
          for (pid in pp) for (p = pid; p > 1; p = pp[p]) if (p in roots) { print pid; break }
        }' | xargs)
      for pid in $("$pgrep" -U "$(id -u)"); do
        case " $keep " in *" $pid "*) continue ;; esac
        case "$(cat /proc/$pid/comm 2>/dev/null)" in .Hyprland-wrapp | Hyprland | Xwayland) continue ;; esac
        "$taskset" -a -cp "$ecores" "$pid" >/dev/null 2>&1 && echo "$pid" >> "$moved"
      done
    }
    # Vesktop stays on the E-cores; its launcher puts it there.
    restore() {
      [ -f "$moved" ] || return 0
      all=$(cat /sys/devices/system/cpu/online)
      for pid in $(sort -u "$moved"); do
        ${pkgs.gnugrep}/bin/grep -qa vesktop /proc/$pid/cmdline 2>/dev/null && continue
        "$taskset" -a -cp "$all" "$pid" >/dev/null 2>&1
      done
      rm -f "$moved"
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
      # Rerun on every event so processes started mid-game get moved too.
      if [ -n "$current" ]; then isolate "$current"; else restore; fi
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
