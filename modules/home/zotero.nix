{
  config,
  lib,
  pkgs,
  ...
}:
let
  clone = "${config.home.homeDirectory}/dotfiles";
  source = "${clone}/zotero";
  zoteroDir = "${config.home.homeDirectory}/.zotero/zotero";
  awk = lib.getExe' pkgs.gawk "awk";
in
{
  home.activation.linkZoteroChrome = lib.hm.dag.entryAfter [ "cloneDotfiles" ] ''
    ini="${zoteroDir}/profiles.ini"
    if [ ! -e "$ini" ]; then
      warnEcho "no $ini yet; skipping Zotero chrome symlinks"
    else
      profilePath=$(${awk} -F= '
        /^\[Profile/ { path="" }
        /^Path=/ { path=$2 }
        /^Default=1/ { if (path) print path }
      ' "$ini" | tail -n1)

      if [ -z "$profilePath" ]; then
        warnEcho "could not find a default Zotero profile in $ini; skipping Zotero chrome symlinks"
      else
        profileDir="${zoteroDir}/$profilePath"
        run mkdir -p "$profileDir/chrome"

        for name in user.js chrome/userChrome.css chrome/userContent.css; do
          target="$profileDir/$name"
          case "$name" in
            chrome/userContent.css) src="${source}/chrome/userChrome.css" ;;
            *) src="${source}/$name" ;;
          esac
          if [ -e "$target" ] && [ ! -L "$target" ]; then
            run mv "$target" "$target.pre-dotfiles-backup"
          fi
          run ln -sfn "$src" "$target"
        done
      fi
    fi
  '';
}
