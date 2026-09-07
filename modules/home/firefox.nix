{ config, lib, pkgs, ... }:
let
  clone = "${config.home.homeDirectory}/dotfiles";
  source = "${clone}/firefox/chrome";
  mozillaDir = "${config.home.homeDirectory}/.mozilla/firefox";
  awk = lib.getExe' pkgs.gawk "awk";
in
{
  # Symlinks fx-autoconfig's chrome/{utils,JS,userChrome.css} (tracked in the
  # dotfiles repo) into whichever profile profiles.ini marks as default. The
  # profile folder name is a random per-machine hash, so this can't be a
  # static home.file path -- it has to be resolved at activation time. Must
  # run after cloneDotfiles (nix-config/modules/home/dotfiles.nix) puts the
  # source files on disk.
  home.activation.linkFirefoxChrome = lib.hm.dag.entryAfter [ "cloneDotfiles" ] ''
    ini="${mozillaDir}/profiles.ini"
    if [ ! -e "$ini" ]; then
      warnEcho "no $ini yet; skipping Firefox chrome symlinks"
    else
      profilePath=$(${awk} -F= '
        /^\[Profile/ { path="" }
        /^Path=/ { path=$2 }
        /^Default=1/ { if (path) print path }
      ' "$ini" | tail -n1)

      if [ -z "$profilePath" ]; then
        warnEcho "could not find a default Firefox profile in $ini; skipping Firefox chrome symlinks"
      else
        profileDir="${mozillaDir}/$profilePath"
        run mkdir -p "$profileDir/chrome"
        for name in utils JS userChrome.css; do
          target="$profileDir/chrome/$name"
          if [ -e "$target" ] && [ ! -L "$target" ]; then
            run mv "$target" "$target.pre-dotfiles-backup"
          fi
          run ln -sfn "${source}/$name" "$target"
        done
      fi
    fi
  '';
}
