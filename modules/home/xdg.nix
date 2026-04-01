{ pkgs, lib, host, ... }:
let
  inherit (import ../../hosts/${host}/variables.nix) editor;
  hostPackagesFile = builtins.readFile ../../hosts/${host}/host-packages.nix;
  hasMicrosoftEdge = builtins.any (
    line:
    let
      trimmed = lib.strings.trim line;
    in
    trimmed == "microsoft-edge" || lib.hasPrefix "microsoft-edge " trimmed
  ) (lib.splitString "\n" hostPackagesFile);
in {
  xdg = {
    enable = true;
    desktopEntries = lib.mkIf hasMicrosoftEdge {
      microsoft-edge = {
        name = "Microsoft Edge";
        genericName = "Web Browser";
        exec = "edge-x11 %U";
        terminal = false;
        type = "Application";
        icon = "microsoft-edge";
        categories = [ "Network" "WebBrowser" ];
        mimeType = [
          "text/html"
          "application/xhtml+xml"
          "x-scheme-handler/http"
          "x-scheme-handler/https"
        ];
      };
    };
    mime.enable = true;
    mimeApps = {
      enable = true;
      defaultApplications = {
        "text/html" = "firefox.desktop";
        "application/xhtml+xml" = "firefox.desktop";
        "application/pdf" = "firefox.desktop";
        "x-scheme-handler/http" = "firefox.desktop";
        "x-scheme-handler/https" = "firefox.desktop";
        "x-scheme-handler/about" = "firefox.desktop";
        "x-scheme-handler/unknown" = "firefox.desktop";
      } // lib.optionalAttrs (editor == "code") {
        "text/plain" = "code.desktop";
        "application/json" = "code.desktop";
        "application/ndjson" = "code.desktop";
        "text/javascript" = "code.desktop";
        "application/javascript" = "code.desktop";
      };
    };
    portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
      configPackages = [ pkgs.hyprland ];
    };
  };
}
