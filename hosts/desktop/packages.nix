{ lib, pkgs, ... }:
let
  vesktopDisplay = ":42";
  vesktop = pkgs.symlinkJoin {
    name = "vesktop";
    paths = [ pkgs.unstable.vesktop ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/vesktop \
        --run '${pkgs.util-linux}/bin/taskset -cp "$(cat /sys/devices/cpu_atom/cpus)" $$ >/dev/null' \
        --run '${pkgs.systemd}/bin/systemctl --user start vesktop-xwayland' \
        --run 'for _ in $(seq 50); do [ -S /tmp/.X11-unix/X${lib.removePrefix ":" vesktopDisplay} ] && break; sleep 0.1; done' \
        --set DISPLAY ${vesktopDisplay} \
        --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ pkgs.unstable.libva ]} \
        --add-flags "--ozone-platform=x11 --render-node-override=/dev/dri/by-path/pci-0000:00:02.0-render --disable-gpu-sandbox" \
        --add-flags "--disable-features=AcceleratedVideoDecoder,AcceleratedVideoDecodeLinuxGL,AcceleratedVideoDecodeLinuxZeroCopyGL"
    '';
  };
in
{
  systemd.user.services.vesktop-xwayland = {
    description = "XWayland server for Vesktop";
    after = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.xwayland-satellite}/bin/xwayland-satellite ${vesktopDisplay}";
      Restart = "always";
      RestartSec = 2;
    };
  };

  environment.systemPackages = with pkgs; [
    alsa-scarlett-gui
    audacity
    easyeffects
    keymapp
    libreoffice
    microsoft-edge
    nodejs
    osu-lazer-bin
    teams-for-linux
    # Takes priority over the unwrapped Vesktop from modules/core.
    (lib.hiPrio vesktop)
    (xivlauncher.override { steam = steam.override { privateTmp = false; }; })
    zoom-us
  ];
}
