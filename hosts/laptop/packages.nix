{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    easyeffects
    keymapp
    libreoffice
    microsoft-edge
    moonlight-qt
    nodejs
    teams-for-linux
    zoom-us
  ];
}
