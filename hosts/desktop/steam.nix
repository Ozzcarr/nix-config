{ pkgs, ... }:
let
  # Steam opens a new shader bucket per driver/Proton combo and never deletes old ones.
  pruneShaderCache = pkgs.writeShellApplication {
    name = "steam-prune-shader-cache";
    runtimeInputs = with pkgs; [ coreutils findutils gnugrep procps ];
    text = ''
      if pgrep -f '^\S*/fossilize_replay ' >/dev/null; then
        echo "Steam is processing shaders, skipping"
        exit 0
      fi

      shopt -s nullglob
      dryRun=''${1:-}
      maxAge=$((30 * 86400))
      vdf="$HOME/.local/share/Steam/steamapps/libraryfolders.vdf"
      [ -f "$vdf" ] || exit 0

      newest() { find "$1" -type f -printf '%T@\n' | sort -n | tail -n1 | cut -d. -f1; }

      # Drop buckets last written 30+ days before the newest bucket of the same game.
      grep -oP '"path"\s+"\K[^"]+' "$vdf" | while read -r lib; do
        for app in "$lib"/steamapps/shadercache/*/fozpipelinesv6; do
          [ -d "$app" ] || continue
          latest=0
          for b in "$app"/steamapprun_pipeline_cache.*/; do
            t=$(newest "$b"); t=''${t:-0}
            if (( t > latest )); then latest=$t; fi
          done
          for b in "$app"/steamapprun_pipeline_cache.*/; do
            t=$(newest "$b"); t=''${t:-0}
            if (( latest - t > maxAge )); then
              echo "$(du -sh "$b" | cut -f1) $b"
              [ "$dryRun" = "--dry-run" ] || rm -rf "$b"
            fi
          done
        done
      done
    '';
  };
in
{
  programs = {
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = false;
      gamescopeSession.enable = true;
      extraCompatPackages = [ pkgs.proton-ge-bin ];
      package = pkgs.steam.override { privateTmp = false; };
    };

    gamescope = {
      enable = true;
      capSysNice = true;
      args = [
        "--rt"
        "--expose-wayland"
      ];
    };
  };

  environment.systemPackages = [ pruneShaderCache ];

  # Background shader processing on all 20 threads.
  systemd.user.tmpfiles.rules = [
    "f+ %h/.local/share/Steam/steam_dev.cfg - - - - unShaderBackgroundProcessingThreads 20\\n"
  ];

  systemd.user.services.steam-prune-shader-cache = {
    description = "Delete stale Steam shader cache buckets";
    serviceConfig = {
      Type = "oneshot";
      Nice = 19;
      IOSchedulingClass = "idle";
      ExecStart = "${pruneShaderCache}/bin/steam-prune-shader-cache";
    };
  };

  systemd.user.timers.steam-prune-shader-cache = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "weekly";
      Persistent = true;
    };
  };
}
