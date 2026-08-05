{ pkgs }:
pkgs.writeShellScriptBin "emopicker9000" ''
  if pidof rofi > /dev/null; then
    pkill rofi
  fi

  chosen=$(cat $HOME/.config/.emoji | ${pkgs.rofi}/bin/rofi -i -dmenu -config ~/.config/rofi/config-long.rasi | awk '{print $1}')

  [ -z "$chosen" ] && exit

  if [ -n "$1" ]; then
   ${pkgs.ydotool}/bin/ydotool type "$chosen"
  else
      printf "$chosen" | ${pkgs.wl-clipboard}/bin/wl-copy
   ${pkgs.libnotify}/bin/notify-send "'$chosen' copied to clipboard." &
  fi
''
