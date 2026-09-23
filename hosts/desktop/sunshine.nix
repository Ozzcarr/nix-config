{ pkgs, ... }:
let
  streamingProfile = "Desktop Streaming";
  streamingSensitivity = "-1";

  sunshineStreamingWatch = pkgs.writeShellScript "sunshine-streaming-watch" ''
    hyprmoncfg=${pkgs.unstable.hyprmoncfg}/bin/hyprmoncfg
    hyprctl=${pkgs.hyprland}/bin/hyprctl
    journalctl=${pkgs.systemd}/bin/journalctl
    systemctl=${pkgs.systemd}/bin/systemctl

    "$journalctl" --user -u sunshine -f -n0 -o cat | while IFS= read -r line; do
      case "$line" in
        *"CLIENT CONNECTED"*)
          "$systemctl" --user stop hyprmoncfgd
          "$hyprmoncfg" apply "${streamingProfile}" --confirm-timeout 0
          "$hyprctl" keyword input:sensitivity "${streamingSensitivity}"
          ;;
        *"CLIENT DISCONNECTED"*)
          "$systemctl" --user start hyprmoncfgd
          "$hyprctl" reload
          ;;
      esac
    done
  '';
in
{
  services.sunshine = {
    enable = true;
    autoStart = true;
    openFirewall = true;
    capSysAdmin = true;
    settings = {
      sunshine_name = "desktop";
    };
  };

  systemd.user.services.sunshine-streaming-watch = {
    description = "Switches to the streaming hyprmoncfg profile while a Moonlight client is connected";
    after = [
      "graphical-session.target"
      "sunshine.service"
    ];
    partOf = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${sunshineStreamingWatch}";
      Restart = "on-failure";
      RestartSec = 5;
    };
  };
}
