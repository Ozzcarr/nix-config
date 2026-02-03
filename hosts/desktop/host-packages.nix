{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    alsa-scarlett-gui
    # audacity
    easyeffects # Advanced Audio Effects
    keymapp
    libreoffice
    microsoft-edge
    nodejs
    osu-lazer-bin
    teams-for-linux
    vscode
    xivlauncher
    zoom-us
  ];
}
