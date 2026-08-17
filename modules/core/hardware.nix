{ pkgs, ... }:
{
  hardware = {
    graphics.enable = true;
    enableRedistributableFirmware = true;
    keyboard.qmk.enable = true;
    bluetooth.enable = true;
    bluetooth.powerOnBoot = true;
  };

  services.udev.extraRules = ''
    # Keymapp flashing rules for the ZSA Voyager
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="3297", MODE:="0666", SYMLINK+="ignition_dfu"

    # Let wheel re-probe HDMI-A-1 (force-disconnected at boot, see hosts/desktop/default.nix and modules/core/greetd.nix)

    SUBSYSTEM=="drm", KERNEL=="card*-HDMI-A-1", RUN+="${pkgs.bash}/bin/sh -c 'chgrp wheel /sys%p/status; chmod g+w /sys%p/status'"
  '';
}
