{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # audacity
    easyeffects # Advanced Audio Effects
    keymapp
    libreoffice
    microsoft-edge
    nodejs
    teams-for-linux
    zoom-us
  ];
}
