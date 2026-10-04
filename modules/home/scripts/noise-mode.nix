{ pkgs }:
pkgs.writeShellScriptBin "noise-mode" ''
  #!${pkgs.bash}/bin/bash
  set -euo pipefail

  preset_dir="''${XDG_DATA_HOME:-$HOME/.local/share}/easyeffects/input"
  state="''${XDG_RUNTIME_DIR:-/tmp}/noise-mode"

  easyeffects=${pkgs.easyeffects}/bin/easyeffects
  notify=${pkgs.libnotify}/bin/notify-send

  flash() {
    ${pkgs.quickshell}/bin/qs -c oz ipc call osd flash "$@" || true
  }

  current() {
    cat "$state" 2>/dev/null || echo light
  }

  load() {
    local preset="$1"

    if [ ! -f "$preset_dir/$preset.json" ]; then
      "$notify" -u critical "Noise mode" \
        "Missing preset '$preset'. Save your input chain under that name in EasyEffects."
      exit 1
    fi

    "$easyeffects" -l "$preset"
  }

  mode="''${1:-toggle}"
  if [ "$mode" = toggle ]; then
    if [ "$(current)" = deep ]; then mode=light; else mode=deep; fi
  fi

  case "$mode" in
    status)
      current
      exit 0
      ;;
    # EasyEffects 8 exposes no CLI or dbus route to its Reset History button,
    # but loading the preset rebuilds the plugin, which is what that button
    # does internally (DeepFilterNet::clear_data), so switching to deep always
    # starts from a clean history.
    deep)
      load voice-deep
      flash graphic_eq "Noise removal: deep"
      ;;
    light)
      load voice-light
      flash graphic_eq "Noise removal: light"
      ;;
    *)
      echo "usage: noise-mode [deep|light|toggle|status]" >&2
      exit 2
      ;;
  esac

  printf '%s\n' "$mode" > "$state"
''
