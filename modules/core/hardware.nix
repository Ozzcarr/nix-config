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

  services.udev.packages = [
    (pkgs.writeTextFile {
      name = "wacom-browser-udev-rules";
      destination = "/lib/udev/rules.d/70-wacom-browser.rules";
      text = ''
        SUBSYSTEM=="hidraw", ATTRS{idVendor}=="056a", TAG+="uaccess"
        SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="0ac3", ATTR{idProduct}=="ff0f", TAG+="uaccess"
      '';
    })
    (pkgs.writeTextFile {
      name = "wooting-udev-rules";
      destination = "/lib/udev/rules.d/70-wooting.rules";
      text = ''
        # Wooting One Legacy
        SUBSYSTEM=="hidraw", ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="ff01", MODE:="0660", GROUP="input", TAG+="uaccess"
        SUBSYSTEM=="usb", ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="ff01", MODE:="0660", GROUP="input", TAG+="uaccess"
        # Wooting One update mode
        SUBSYSTEM=="hidraw", ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="2402", MODE:="0660", GROUP="input", TAG+="uaccess"

        # Wooting Two Legacy
        SUBSYSTEM=="hidraw", ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="ff02", MODE:="0660", GROUP="input", TAG+="uaccess"
        SUBSYSTEM=="usb", ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="ff02", MODE:="0660", GROUP="input", TAG+="uaccess"
        # Wooting Two update mode
        SUBSYSTEM=="hidraw", ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="2403", MODE:="0660", GROUP="input", TAG+="uaccess"

        # Generic Wootings
        SUBSYSTEM=="hidraw", ATTRS{idVendor}=="31e3", MODE:="0660", GROUP="input", TAG+="uaccess"
        SUBSYSTEM=="usb", ATTRS{idVendor}=="31e3", MODE:="0660", GROUP="input", TAG+="uaccess"
      '';
    })
  ];

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
