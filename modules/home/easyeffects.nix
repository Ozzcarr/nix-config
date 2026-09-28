{ ... }:
{
  xdg.configFile."systemd/user/app-easyeffects\\x2dservice@autostart.service.d/restart.conf".text = ''
    [Service]
    Restart=on-failure
    RestartSec=2
  '';
}
