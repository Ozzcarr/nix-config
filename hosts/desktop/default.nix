{ ... }: {
  imports = [
    ./hardware.nix
    ./host-packages.nix
  ];

  # Never auto-sleep on desktop
  services.logind.settings.Login = {
    IdleAction = "ignore";
    IdleActionSec = "0";
  };

  # Disable suspend paths (keeps hibernate available)
  systemd.targets.suspend.enable = false;
  systemd.targets.hybrid-sleep.enable = false;
  systemd.targets.sleep.enable = false;
}
