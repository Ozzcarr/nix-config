{ pkgs, ... }:
let
  check = import ./scripts/nix-update-check.nix { inherit pkgs; };
in
{
  home.packages = [ check ];

  systemd.user.services.nix-update-check = {
    Unit.Description = "Check nix-config flake inputs for updates";
    Service = {
      Type = "oneshot";
      # The system nix, so the check talks to the same daemon and store as `nh`.
      Environment = "PATH=/run/current-system/sw/bin";
      ExecStart = "${check}/bin/nix-update-check";
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
