{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    alsa-scarlett-gui
    # audacity
    libreoffice
    microsoft-edge
    nodejs
    teams-for-linux
    vscode
    xivlauncher
  ];
}
