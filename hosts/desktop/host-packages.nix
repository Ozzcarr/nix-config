{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    alsa-scarlett-gui
    # audacity
    nodejs
    vscode
    xivlauncher
  ];
}
