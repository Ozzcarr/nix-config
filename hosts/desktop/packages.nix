{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    alsa-scarlett-gui
    audacity
    easyeffects
    keymapp
    libreoffice
    microsoft-edge
    nodejs
    osu-lazer-bin
    teams-for-linux
    (xivlauncher.override { steam = steam.override { privateTmp = false; }; })
    zoom-us
  ];
}
