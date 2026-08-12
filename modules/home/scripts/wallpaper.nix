{ pkgs }:

pkgs.writeShellScriptBin "wallpaper" ''
  set -euo pipefail

  DIR="$HOME/dotfiles/wallpapers"
  # hyprlock reads this too, and detects the format from content rather than
  # the name, so the link needs no extension.
  STATE="$HOME/.cache/current-wallpaper"

  apply() {
    ln -sfn "$1" "$STATE"
    ${pkgs.awww}/bin/awww img "$1" \
      --transition-type grow \
      --transition-pos 0.5,0.5 \
      --transition-duration 1 \
      --transition-fps 60
  }

  list() {
    ${pkgs.findutils}/bin/find -L "$DIR" -maxdepth 1 -type f \
      \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \) \
      | sort
  }

  if [ ! -d "$DIR" ]; then
    ${pkgs.libnotify}/bin/notify-send -u critical "wallpaper" "$DIR does not exist"
    exit 1
  fi

  mapfile -t files < <(list)
  if [ ''${#files[@]} -eq 0 ]; then
    ${pkgs.libnotify}/bin/notify-send -u critical "wallpaper" "no images in $DIR"
    exit 1
  fi

  current="$(readlink -f "$STATE" 2>/dev/null || true)"

  case "''${1-}" in
    restore)
      # Falls back to the first image so a missing or stale link still boots
      # with a wallpaper.
      if [ -f "$current" ]; then apply "$current"; else apply "''${files[0]}"; fi
      exit 0
      ;;
  esac

  menu() {
    for f in "''${files[@]}"; do
      name="''${f##*/}"
      name="''${name%.*}"
      name="''${name//_/ }"
      [ "$f" = "$current" ] && name="● $name"
      printf '%s\0icon\x1f%s\n' "$name" "$f"
    done
  }

  # Sized to the real row count; rofi reserves blank rows otherwise. Capped so
  # a large collection scrolls instead of outgrowing the screen.
  cols=3
  rows=$(( (''${#files[@]} + cols - 1) / cols ))
  [ "$rows" -gt 3 ] && rows=3

  # -format i returns the index, so labels stay free-form.
  # Ctrl+n/p step one thumbnail; they have to be taken off row-up/down first,
  # since rofi rejects a key bound to two actions.
  idx="$(menu | ${pkgs.rofi}/bin/rofi -dmenu -i -format i -p "Wallpaper" \
    -kb-row-up "Up" -kb-row-down "Down" \
    -kb-element-next "Control+n" -kb-element-prev "Control+p" \
    -theme-str "
    window { width: 70%; }
    // The shared config also lays out mode-switcher and message, which
    // reserve empty space here.
    mainbox { children: [ inputbar, listview ]; }
    inputbar { children: [ prompt, entry ]; }
    prompt { text-color: @mauve; padding: 0 8px 0 0; }
    listview {
      columns: $cols; lines: $rows;
      flow: horizontal; fixed-columns: true;
      spacing: 12px;
    }
    element { orientation: vertical; padding: 10px; }
    element-icon { size: 240px; horizontal-align: 0.5; }
    element-text { horizontal-align: 0.5; padding: 8px 0 0 0; }
  " || true)"

  [ -n "$idx" ] || exit 0
  apply "''${files[$idx]}"
''
