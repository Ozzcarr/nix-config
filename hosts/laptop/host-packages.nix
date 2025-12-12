{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # audacity
    nodejs
    libreoffice
    microsoft-edge
    nodejs
    teams-for-linux
    vscode
  ];
}
