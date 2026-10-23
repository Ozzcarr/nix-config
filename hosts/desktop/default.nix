{
  config,
  inputs,
  lib,
  ...
}:
{
  imports = [
    ./hardware.nix
    ./gamemode.nix
    ./packages.nix
    ./steam.nix
    ./sunshine.nix
    ../../modules/core
    ../../modules/drivers
    inputs.lanzaboote.nixosModules.lanzaboote
  ];

  drivers.nvidia.enable = true;

  boot = {
    loader.systemd-boot.enable = lib.mkForce false;
    lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
    };

    kernelParams = [
      "video=DP-2:2560x1440@165"
      "video=HDMI-A-1:d"
      "nvidia_drm.fbdev=1"
    ];

    kernelModules = [ "v4l2loopback" ];
    extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];
    extraModprobeConfig = ''
      options v4l2loopback devices=1 video_nr=10 card_label="OBS Cam" exclusive_caps=1
    '';
  };

  services.logind.settings.Login = {
    IdleAction = "ignore";
    IdleActionSec = "0";
  };

  # Disable suspend paths (keeps hibernate available)
  systemd.targets.suspend.enable = false;
  systemd.targets.hybrid-sleep.enable = false;
  systemd.targets.sleep.enable = false;
}
