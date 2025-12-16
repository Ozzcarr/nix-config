{ pkgs, host, ... }:
let
  inherit (import ../../hosts/${host}/variables.nix) deviceUnit deviceId;
in
{
  systemd.user.services.noisetorch = {
    Unit = {
      Description = "Noisetorch Noise Cancelling";
      Requires = [ deviceUnit ];
      After = [ "pipewire.service" ];
    };

    Service = {
      Type = "simple";
      RemainAfterExit = true;
      ExecStart = "${pkgs.noisetorch}/bin/noisetorch -i -s ${deviceId} -t 95";
      ExecStop = "${pkgs.noisetorch}/bin/noisetorch -u";
      Restart = "on-failure";
      RestartSec = 3;
    };

    Install.WantedBy = [ "default.target" ];
  };
}