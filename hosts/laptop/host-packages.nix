{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # audacity
    libreoffice
    microsoft-edge
    nodejs
    teams-for-linux
    zoom-us
  ];
}
