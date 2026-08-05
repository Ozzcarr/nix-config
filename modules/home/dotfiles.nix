# Config kept in the dotfiles repo rather than in Nix, so it can be edited
# without a rebuild and reused on machines that aren't NixOS.
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  url = "https://github.com/ozzcarr/dotfiles";
  clone = "${config.home.homeDirectory}/dotfiles";

  # "live" symlinks into the clone, so edits apply without a rebuild.
  # "store" uses the revision pinned in flake.lock, read-only.
  mode = "live";

  # Directory names, resolved against both the repo root and ~/.config.
  managed = [
    "yazi"
  ];

  sourceFor =
    name:
    if mode == "live" then
      config.lib.file.mkOutOfStoreSymlink "${clone}/${name}"
    else
      "${inputs.dotfiles}/${name}";
in
{
  xdg.configFile = lib.genAttrs managed (name: {
    source = sourceFor name;
  });

  home.activation = lib.mkIf (mode == "live") {
    cloneDotfiles = lib.hm.dag.entryBefore [ "linkGeneration" ] ''
      if [ ! -e ${lib.escapeShellArg clone} ]; then
        run ${lib.getExe pkgs.git} clone ${lib.escapeShellArg url} ${lib.escapeShellArg clone} \
          || warnEcho "could not clone dotfiles; links under ~/.config will dangle"
      fi
    '';
  };
}
