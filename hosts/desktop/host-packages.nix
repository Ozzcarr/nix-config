{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    alsa-scarlett-gui
    # audacity
    easyeffects # Advanced Audio Effects
    keymapp
    libreoffice
    microsoft-edge
    nodejs
    noisetorch # Noise Suppression For Microphones
    osu-lazer-bin
    teams-for-linux
    vscode
    xivlauncher
    zoom-us
  ];
}
