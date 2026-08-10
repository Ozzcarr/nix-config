{ vars, ... }:
{
  stylix = {
    enable = true;
    image = vars.wallpaper;

    base16Scheme = {
      scheme = "Catppuccin Mocha";
      author = "Catppuccin";
      base00 = "1e1e2e"; # base
      base01 = "181825"; # mantle
      base02 = "313244"; # surface0
      base03 = "45475a"; # surface1
      base04 = "585b70"; # surface2
      base05 = "cdd6f4"; # text
      base06 = "f5e0dc"; # rosewater
      base07 = "b4befe"; # lavender
      base08 = "f38ba8"; # red
      base09 = "fab387"; # peach
      base0A = "f9e2af"; # yellow
      base0B = "a6e3a1"; # green
      base0C = "94e2d5"; # teal
      base0D = "89b4fa"; # blue
      base0E = "cba6f7"; # mauve
      base0F = "f2cdcd"; # flamingo
    };

    # Themed by hand elsewhere, or owned by the dotfiles repo.
    targets = {
      waybar.enable = false;
      kitty.enable = false;
      rofi.enable = false;
      starship.enable = false;
      hyprland.enable = false;
      hyprlock.enable = false;
      ghostty.enable = false;
      yazi.enable = false;
      neovim.enable = false;
      qt = {
        enable = true;
        platform = "qtct";
      };
    };
  };
}
