{ pkgs, ... }:
let
  check = import ./scripts/nix-update-check.nix { inherit pkgs; };
  indicator = import ./scripts/nix-update-waybar.nix { inherit pkgs; };
in
{
  home.packages = [
    check
    indicator
  ];

  systemd.user.services.nix-update-check = {
    Unit.Description = "Check nix-config flake inputs for updates";
    Service = {
      Type = "oneshot";
      # The system nix, so the check talks to the same daemon and store as `nh`.
      Environment = "PATH=/run/current-system/sw/bin";
      ExecStart = "${check}/bin/nix-update-check";
      # Refresh the bar as soon as the check lands, rather than on its next poll.
      ExecStartPost = "-${pkgs.procps}/bin/pkill -RTMIN+9 waybar";
    };
  };

  systemd.user.timers.nix-update-check = {
    Unit.Description = "Periodic nix-config update check";
    Timer = {
      OnStartupSec = "3m";
      OnUnitActiveSec = "3h";
    };
    Install.WantedBy = [ "timers.target" ];
  };
}
