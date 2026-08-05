{
  monitors = ''
    monitor = DP-2,2560x1440@165,0x0,1
    monitor = HDMI-A-2,1920x1080@60,2560x250,1

    # Bind workspaces to monitors
    workspace = 1, monitor:DP-2
    workspace = 2, monitor:DP-2
    workspace = 3, monitor:DP-2
    workspace = 4, monitor:DP-2
    workspace = 5, monitor:DP-2

    workspace = 6, monitor:HDMI-A-2
    workspace = 7, monitor:HDMI-A-2
    workspace = 8, monitor:HDMI-A-2
    workspace = 9, monitor:HDMI-A-2
    workspace = 10, monitor:HDMI-A-2
  '';

  hasNvidiaGpu = true;
  hasEdge = true;
}
