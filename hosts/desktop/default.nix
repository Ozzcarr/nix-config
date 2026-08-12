{ ... }:
{
  imports = [
    ./hardware.nix
    ./packages.nix
    ../../modules/core
    ../../modules/drivers
  ];

  drivers.nvidia.enable = true;

  boot.kernelParams = [
    "video=DP-2:2560x1440@165"
    "video=HDMI-A-2:d"
    "nvidia_drm.fbdev=1"
  ];

  services.logind.settings.Login = {
    IdleAction = "ignore";
    IdleActionSec = "0";
  };

  # Disable suspend paths (keeps hibernate available)
  systemd.targets.suspend.enable = false;
  systemd.targets.hybrid-sleep.enable = false;
  systemd.targets.sleep.enable = false;
}
