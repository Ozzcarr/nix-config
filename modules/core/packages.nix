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
    android-tools
    appimage-run
    brightnessctl
    clang-tools
    cliphist
    cmake
    cmatrix
    cowsay
    claude-code
    inputs.claude-desktop.packages.x86_64-linux.default
    delta
    docker-compose
    duf
    dysk
    eog
    fd
    ffmpeg
    file-roller
    gcc
    gimp
    gnumake
    hyprpicker
    hyprshot
    inxi
    jq
    killall
    libnotify
    lm_sensors
    lolcat
    lshw
    mesa-demos # inxi needs it to report graphics
    mpv
    nixd
    nixfmt
    nwg-displays
    pavucontrol
    pciutils
    pkg-config
    playerctl
    pnpm
    ripgrep
    socat # hyprshot needs it
    unstable.tailscale
    tmux
    traceroute
    unrar
    unzip
    usbutils
    v4l-utils
    unstable.vesktop
    unstable.vscode
    waypaper
    wget
    xrandr
  ];
}
