{ lib, vars, ... }:
let
  inherit (vars) editor;
in
{
  xdg = {
    enable = true;

    # Edge renders badly under Wayland, so route its desktop entry through the
    # edge-x11 wrapper instead of the one the package ships.
    desktopEntries = lib.mkIf vars.hasEdge {
      microsoft-edge = {
        name = "Microsoft Edge";
        genericName = "Web Browser";
        exec = "edge-x11 %U";
        terminal = false;
        type = "Application";
        icon = "microsoft-edge";
        categories = [
          "Network"
          "WebBrowser"
        ];
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
      }
      // lib.optionalAttrs (editor == "code") {
        "text/plain" = "code.desktop";
        "application/json" = "code.desktop";
        "application/ndjson" = "code.desktop";
        "text/javascript" = "code.desktop";
        "application/javascript" = "code.desktop";
      };
    };
  };
}
