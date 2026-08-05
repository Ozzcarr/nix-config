{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    easyeffects
    keymapp
    libreoffice
    microsoft-edge
    nodejs
    teams-for-linux
    zoom-us
  ];
}
