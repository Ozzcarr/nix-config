{ pkgs, ... }: {
  imports = [
    ./hardware.nix
    ./host-packages.nix
  ];

  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "suspend";
    HandleLidSwitchDocked = "ignore";
  };

  services.interception-tools = {
    enable = true;
    plugins = [
      pkgs.interception-tools-plugins.caps2esc
    ];
    udevmonConfig = ''
      - JOB: "${pkgs.interception-tools}/bin/intercept -g $DEVNODE | ${pkgs.interception-tools-plugins.caps2esc}/bin/caps2esc | ${pkgs.interception-tools}/bin/uinput -d $DEVNODE"
        DEVICE:
          LINK: "/dev/input/by-path/platform-i8042-serio-0-event-kbd"
          EVENTS:
            EV_KEY: [KEY_CAPSLOCK]
    '';
  };
}
