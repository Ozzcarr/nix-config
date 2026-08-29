# The screenshare picker is xdph's, and Vesktop opens a fresh portal session for
# every getDisplayMedia call, so it gets asked again seconds after a stream
# starts. Restore tokens only cover the sessions Chromium happens to have a token
# for, hence the cache in front of the picker as well.
{ pkgs, ... }:
let
  cacheSeconds = 15;

  picker = pkgs.writeShellScript "xdph-share-picker" ''
    set -euo pipefail

    cache="''${XDG_RUNTIME_DIR:-/tmp}/xdph-share-picker.selection"

    if [ -r "$cache" ]; then
      age=$(( $(${pkgs.coreutils}/bin/date +%s) - $(${pkgs.coreutils}/bin/stat -c %Y "$cache") ))
      if [ "$age" -lt ${toString cacheSeconds} ]; then
        exec ${pkgs.coreutils}/bin/cat "$cache"
      fi
    fi

    set +e
    out="$(${pkgs.xdg-desktop-portal-hyprland}/bin/hyprland-share-picker "$@")"
    status=$?
    set -e

    printf '%s\n' "$out"

    # xdph drops the last character of the selection, so a replay has to keep the
    # trailing newline the picker printed.
    selection="$(printf '%s\n' "$out" | ${pkgs.gnugrep}/bin/grep -o '\[SELECTION\].*' || true)"
    if [ -n "$selection" ]; then
      printf '%s\n' "$selection" > "$cache"
    fi

    exit "$status"
  '';
in
{
  xdg.configFile."hypr/xdph.conf".text = ''
    screencopy {
        allow_token_by_default = true
        custom_picker_binary = ${picker}
    }
  '';
}
