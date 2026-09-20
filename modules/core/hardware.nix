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

    SUBSYSTEM=="usb", ATTR{idVendor}=="0ac3", ATTR{idProduct}=="ff0f", MODE="0666"
  '';

  # Disable pen buttons
  environment.etc."libinput/local-overrides.quirks".text = ''
    [Wacom CTL-672 Pen Buttons Disable]
    MatchUdevType=tablet
    MatchBus=usb
    MatchVendor=0x056A
    MatchProduct=0x037B
    AttrEventCode=-BTN_STYLUS;-BTN_STYLUS2;
  '';
}
