{ pkgs, lib, ... }:
{
  qt = {
    enable = true;
    platformTheme.name = lib.mkForce "qtct";
    style = {
      name = "kvantum";
      package = pkgs.catppuccin-kvantum.override {
        accent = "mauve";
        variant = "mocha";
      };
    };
  };

  # Selects the installed theme above as Kvantum's active one.
  xdg.configFile."Kvantum/kvantum.kvconfig".text = ''
    [General]
    theme=catppuccin-mocha-mauve
  '';
}
