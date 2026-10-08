{ pkgs }:

pkgs.writeShellScriptBin "wallpaper" ''
  set -euo pipefail

  DIR="$HOME/dotfiles/wallpapers"
  # The shell resolves this link for its accent and lock screen, so it needs no
  # extension.
  STATE="$HOME/.cache/current-wallpaper"

  apply() {
    ln -sfn "$1" "$STATE"
    ${pkgs.awww}/bin/awww img "$1" \
      --transition-type grow \
      --transition-pos 0.5,0.5 \
      --transition-duration 1 \
      --transition-fps 60
    # Lets the shell recolor its accent; fine if it isn't running.
    ${pkgs.quickshell}/bin/qs -c oz ipc call wallpaper changed >/dev/null 2>&1 || true
  }

  case "''${1-}" in
    set)
      [ -f "''${2-}" ] || { echo "wallpaper: no such file: ''${2-}" >&2; exit 1; }
      apply "$2"
      ;;
    restore)
      # Falls back to the first image so a missing or stale link still boots
      # with a wallpaper.
      current="$(readlink -f "$STATE" 2>/dev/null || true)"
      if [ -f "$current" ]; then
        apply "$current"
      else
        first="$(${pkgs.findutils}/bin/find -L "$DIR" -maxdepth 1 -type f \
          \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \) \
          | sort | head -n 1)"
        [ -n "$first" ] || { echo "wallpaper: no images in $DIR" >&2; exit 1; }
        apply "$first"
      fi
      ;;
    "")
      ${pkgs.quickshell}/bin/qs -c oz ipc call wallpaper toggle
      ;;
    *)
      echo "usage: wallpaper [set FILE | restore]" >&2
      exit 2
      ;;
  esac
''
