# Config kept in the dotfiles repo rather than in Nix, so it can be edited
# without a rebuild and reused on machines that aren't NixOS.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  url = "https://github.com/ozzcarr/dotfiles";
  clone = "${config.home.homeDirectory}/dotfiles";

  # Stow package -> what its config needs on PATH, and the paths it owns, each
  # relative to $HOME and present verbatim inside the package.
  managed = {
    yazi = {
      packages = [ pkgs.yazi ];
      links = [ ".config/yazi" ];
    };
    nvim = {
      # neovim itself is system-wide, from modules/core/packages.nix.
      packages = with pkgs; [
        tree-sitter # nvim-treesitter shells out to it to build parsers
        dwt1-shell-color-scripts # colorscript, in the snacks dashboard
      ];
      links = [ ".config/nvim" ];
    };
  };

  # Out of store, so edits need no rebuild and programs can write inside their
  # own config directory (vim.pack keeps a lockfile in ~/.config/nvim).
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

  home.activation.cloneDotfiles = lib.hm.dag.entryBefore [ "linkGeneration" ] ''
    if [ ! -e ${lib.escapeShellArg clone} ]; then
      run ${lib.getExe pkgs.git} clone ${lib.escapeShellArg url} ${lib.escapeShellArg clone} \
        || warnEcho "could not clone dotfiles; links under ~/.config will dangle"
    fi
  '';
}
