{ pkgs, ... }:
{
  systemd.user.services.tmux = {
    Unit = {
      Description = "tmux server (detached), restoring the last saved sessions";
      Documentation = [ "man:tmux(1)" ];
    };
    Service = {
      Type = "forking";
      ExecStart = "${pkgs.tmux}/bin/tmux start-server";
      ExecStop = "${pkgs.tmux}/bin/tmux kill-server";
      KillMode = "control-group";
    };
    Install.WantedBy = [ "hyprland-session.target" ];
  };
}
