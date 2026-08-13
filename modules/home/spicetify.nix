{ inputs, pkgs, ... }:
let
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.system};
in
{
  imports = [ inputs.spicetify-nix.homeManagerModules.default ];

  nixpkgs.config.allowUnfree = true;

  programs.spicetify = {
    enable = true;
    theme = spicePkgs.themes.text;
    colorScheme = "CatppuccinMocha";
    enabledExtensions = with spicePkgs.extensions; [
      adblockify
      hidePodcasts
      keyboardShortcut
      shuffle
    ];
  };
}
