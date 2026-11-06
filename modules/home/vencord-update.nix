{ pkgs, ... }:
let
  update = import ./scripts/vencord-update.nix { inherit pkgs; };
in
{
  home.packages = [ update ];

  systemd.user.services.vencord-update = {
    Unit.Description = "Pull and rebuild the Vencord checkout Vesktop loads";
    Service = {
      Type = "oneshot";
      ExecStart = "${update}/bin/vencord-update";
    };
  };

  systemd.user.timers.vencord-update = {
    Unit.Description = "Daily Vencord update";
    Timer = {
      OnStartupSec = "1m";
      OnCalendar = "daily";
    };
    Install.WantedBy = [ "timers.target" ];
  };
}
