{
  # Git Configuration ( For Pulling Software Repos )
  gitUsername = "Oscar Andersson";
  gitEmail = "anderssonoscar03@gmail.com";

  # Set Displau Manager
  # `tui` for Text login
  # `sddm` for graphical GUI (default)
  # SDDM background is set with stylixImage
  displayManager = "sddm";

  # Emable/disable bundled applications
  tmuxEnable = false;

  # Hyprland Settings
  # Examples:
  # extraMonitorSettings = "monitor = Virtual-1,1920x1080@60,auto,1";
  # extraMonitorSettings = "monitor = HDMI-A-1,1920x1080@60,auto,1";
  # You can configure multiple monitors.
  # Inside the quotes, create a new line for each monitor.
  extraMonitorSettings = "
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
  ";

  # Waybar Settings
  clock24h = true;

  # Program Options
  browser = "firefox";
  terminal = "kitty";
  editor = "code";

  keyboardLayout = "se";
  consoleKeyMap = "sv-latin1";

  # For hybrid support (Intel/NVIDIA Prime or AMD/NVIDIA)
  intelID = "PCI:1:0:0";
  amdgpuID = "PCI:5:0:0";
  nvidiaID = "PCI:0:2:0";

  # Enable NFS
  enableNFS = true;

  # Enable Printing Support
  printEnable = false;

  # Enable Thunar GUI File Manager
  # Yazi is default File Manager
  thunarEnable = true;

  # Themes, waybar and animation.
  # Only uncomment your selection
  # The others much be commented out.

  # Set Stylix Image
  # This will set your color palette
  # Default background
  # Add new images to ~/nix-config/wallpapers
  stylixImage = ../../wallpapers/AnimeGirlNightSky.jpg;
  # stylixImage = ../../wallpapers/beautifulmountainscape.jpg;
  # stylixImage = ../../wallpapers/mountainscapedark.jpg;
  # stylixImage = ../../wallpapers/Rainnight.jpg;

  # Set Animation style
  # Available options are:
  # animations-def.nix  (default)
  # animations-end4.nix (end-4 project very fluid)
  # animations-dynamic.nix (ml4w project)
  # animations-moving.nix (ml4w project)
  animChoice = ../../modules/home/hyprland/animations-def.nix;
  # animChoice = ../../modules/home/hyprland/animations-end4.nix;
  # animChoice = ../../modules/home/hyprland/animations-dynamic.nix;
  # animChoice = ../../modules/home/hyprland/animations-moving.nix;

  # Set network hostId if required (needed for zfs)
  # Otherwise leave as-is
  hostId = "5ab03f50";
}
