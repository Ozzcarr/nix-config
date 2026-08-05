{
  pkgs,
  inputs,
  ...
}:
let
  unstable = import inputs.nixpkgs-unstable {
    system = pkgs.stdenv.hostPlatform.system;
    config = {
      allowUnfree = true;
    };
  };
in
{
  programs = {
    neovim = {
      enable = true;
      defaultEditor = true;
    };
    firefox.enable = true;
    dconf.enable = true;
    seahorse.enable = true;
    fuse.userAllowOther = true;
    mtr.enable = true;
    hyprlock.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    nix-ld.enable = true;
    direnv = {
      enable = true;
      nix-direnv.enable = true;
      silent = true;
    };
  };

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    android-tools # adb/fastboot
    appimage-run # Needed For AppImage Support
    brightnessctl # For Screen Brightness Control
    clang-tools
    cliphist # Clipboard manager using rofi menu
    cmake
    cmatrix # Matrix Movie Effect In Terminal
    cowsay # Great Fun Terminal Program
    inputs.claude-desktop.packages.x86_64-linux.default
    delta # Syntax-highlighting for git
    docker-compose # Allows Controlling Docker From A Single File
    duf # Utility For Viewing Disk Usage In Terminal
    dysk # Disk space util nice formattting
    fd # A simple, fast and user-friendly alternative to 'find'
    ffmpeg # Terminal Video / Audio Editing
    file-roller # Archive Manager
    gcc
    gimp # Great Photo Editor
    gnumake
    hyprpicker # Color Picker
    hyprshot # Screen capture
    eog # For Image Viewing
    inxi # CLI System Information Tool
    killall # For Killing All Instances Of Programs
    libnotify # For Notifications
    lm_sensors # Used For Getting Hardware Temps
    lolcat # Add Colors To Your Terminal Command Output
    lshw # Detailed Hardware Information
    mesa-demos # needed for inxi diag util
    mpv # Incredible Video Player
    nixfmt # Nix Formatter
    nwg-displays # configure monitor configs via GUI
    pavucontrol # For Editing Audio Levels & Devices
    pciutils # Collection Of Tools For Inspecting PCI Devices
    pkg-config # Wrapper Script For Allowing Packages To Get Info On Others
    playerctl # Allows Changing Media Volume Through Scripts
    ripgrep # Improved Grep
    socat # Needed For Screenshots
    spotify
    unstable.tailscale
    traceroute
    unrar # Tool For Handling .rar Files
    unzip # Tool For Handling .zip Files
    usbutils # Good Tools For USB Devices
    v4l-utils # Used For Things Like OBS Virtual Camera
    vesktop # Alternate client for Discord with Vencord built-in
    unstable.vscode
    waypaper # Change wallpaper
    wget # Tool For Fetching Files With Links
    xrandr # Command line interface to X11 Resize, Rotate, and Reflect (RandR) extension
  ];
}
