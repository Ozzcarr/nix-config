{ ... }: {
  imports = [
    ./hardware.nix
    ./host-packages.nix
  ];

  services.logind.extraConfig = ''
    HandleLidSwitch=suspend
    HandleLidSwitchExternalPower=suspend
    HandleLidSwitchDocked=ignore
  '';
}
