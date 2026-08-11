# Defaults for every host. A host overrides any of these in its variables.nix.
{
  gitUsername = "Oscar Andersson";
  gitEmail = "anderssonoscar03@gmail.com";

  # GUI editor only. $EDITOR is neovim, via programs.neovim.defaultEditor.
  editor = "code";

  keyboardLayout = "se";

  # Catppuccin Mocha, used by anything that colors itself in Nix rather than
  # through a dotfiles-owned theme file (e.g. sddm.nix, fzf.nix, swaync.nix).
  colors = {
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

  hasEdge = false;
}
