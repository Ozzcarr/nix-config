{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # audacity
    nodejs
    libreoffice
    # microsoft-edge
    # teams-for-linux
    vscode
    # zoom-us
  ];
}
