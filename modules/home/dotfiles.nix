{
  config,
  lib,
  pkgs,
  ...
}:
let
  url = "https://github.com/ozzcarr/dotfiles";
  clone = "${config.home.homeDirectory}/dotfiles";

  managed = {
    yazi = {
      packages = [ pkgs.yazi ];
      links = [ ".config/yazi" ];
    };
    nvim = {
      packages = with pkgs; [
        tree-sitter
        dwt1-shell-color-scripts
      ];
      links = [ ".config/nvim" ];
    };
    waybar = {
      packages = [ pkgs.waybar ];
      links = [ ".config/waybar" ];
    };
    kitty = {
      packages = [ pkgs.kitty ];
      links = [ ".config/kitty" ];
    };
    zsh = {
      links = [ ".zshrc" ];
    };
    starship = {
      links = [ ".config/starship.toml" ];
    };
    rofi = {
      packages = [
        pkgs.rofi
        pkgs.rofi-calc
        pkgs.libqalculate
      ];
      links = [ ".config/rofi" ];
    };
    hyprland = {
      links = [
        ".config/hypr/hyprlock.conf"
        ".config/hypr/hypridle.conf"
        ".config/hypr/mocha.conf"
      ];
    };
    wlogout = {
      packages = [ pkgs.wlogout ];
      links = [ ".config/wlogout" ];
    };
  };

  sourceFor = path: config.lib.file.mkOutOfStoreSymlink "${clone}/${path}";
in
{
  home.packages = lib.concatMap (entry: entry.packages or [ ]) (lib.attrValues managed);

  home.file = lib.concatMapAttrs (
    name: entry:
    lib.listToAttrs (
      map (link: lib.nameValuePair link { source = sourceFor "${name}/${link}"; }) entry.links
    )
  ) managed;

  systemd.user.sessionVariables.ROFI_PLUGIN_PATH = "${pkgs.rofi-calc}/lib/rofi";

  home.activation.cloneDotfiles = lib.hm.dag.entryBefore [ "linkGeneration" ] ''
    if [ ! -e ${lib.escapeShellArg clone} ]; then
      run ${lib.getExe pkgs.git} clone ${lib.escapeShellArg url} ${lib.escapeShellArg clone} \
        || warnEcho "could not clone dotfiles; links under ~/.config will dangle"
    fi
  '';
}
