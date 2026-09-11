{ pkgs, inputs, ... }:
let
  # The package copies electron's unwrapped dist, dropping nixpkgs' wrapper and
  # the CHROME_DEVEL_SANDBOX it sets, so Chromium traps on startup without this.
  claudeDesktop = inputs.claude-desktop.packages.x86_64-linux.default.overrideAttrs (old: {
    nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ pkgs.makeWrapper ];
    postFixup = (old.postFixup or "") + ''
      wrapProgram $out/bin/claude-desktop \
        --set CHROME_DEVEL_SANDBOX $out/lib/claude-desktop/chrome-sandbox
    '';
  });
in
{
  programs = {
    neovim = {
      enable = true;
      defaultEditor = true;
    };
    firefox = {
      enable = true;
      # Hide tab and url bar on Ctrl+Shift+H
      autoConfig = ''
        // skip 1st line
        try {

          let cmanifest = Cc['@mozilla.org/file/directory_service;1'].getService(Ci.nsIProperties).get('UChrm', Ci.nsIFile);
          cmanifest.append('utils');
          cmanifest.append('chrome.manifest');

          if(cmanifest.exists()){
            Components.manager.QueryInterface(Ci.nsIComponentRegistrar).autoRegister(cmanifest);
            ChromeUtils.importESModule('chrome://userchromejs/content/boot.sys.mjs');
          }

        } catch(ex) {};
      '';
      # Add youtube to quarantined domains
      preferences = {
        "extensions.quarantinedDomains.list" =
          "autoatendimento.bb.com.br,ibpf.sicredi.com.br,ibpj.sicredi.com.br,internetbanking.caixa.gov.br,www.ib12.bradesco.com.br,www2.bancobrasil.com.br,youtube.com,www.youtube.com,m.youtube.com";
      };
    };
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
    claudeDesktop
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
