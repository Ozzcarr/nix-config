{ ... }:
{
  xdg.configFile."systemd/user/app-easyeffects\\x2dservice@autostart.service.d/restart.conf".text = ''
    [Service]
    Restart=on-failure
    RestartSec=2
    # P-cores, like pipewire. DeepFilterNet drops out on the E-cores.
    CPUAffinity=0-11
  '';
}
