{
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.drivers.nvidia;
in
{
  options.drivers.nvidia = {
    enable = mkEnableOption "Enable Nvidia Drivers";
  };

  config = mkIf cfg.enable {
    boot.initrd.kernelModules = [
      "nvidia"
      "nvidia_modeset"
      "nvidia_drm"
    ];

    boot.kernelModules = [ "nvidia_uvm" ];

    services.xserver.videoDrivers = [ "nvidia" ];
    hardware.nvidia = {
      modesetting.enable = true;
      # Both are experimental and can break sleep/suspend.
      powerManagement.enable = false;
      powerManagement.finegrained = false;
      open = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };

    environment.sessionVariables = {
      __GL_SHADER_DISK_CACHE = "1";
      __GL_SHADER_DISK_CACHE_SIZE = "12000000000";
    };
  };
}
