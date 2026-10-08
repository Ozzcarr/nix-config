{ pkgs }:
pkgs.writeShellScriptBin "vesktop-stream" ''
  #!${pkgs.bash}/bin/bash
  set -euo pipefail

  # Toggles a Go Live of the running game. gamemode knows which window is the game,
  # xdph's picker is told to pick it (see xdph.nix), and the StreamGame Vencord plugin
  # starts the stream with only the game's audio, or stops the one already running.

  hyprctl=${pkgs.hyprland}/bin/hyprctl
  jq=${pkgs.jq}/bin/jq

  socket="$XDG_RUNTIME_DIR/vesktop-stream.sock"
  preselect="$XDG_RUNTIME_DIR/xdph-share-picker.preselect"

  notify() {
    ${pkgs.libnotify}/bin/notify-send -a Vesktop "Stream" "$1"
  }

  # Without a game in gamemode, stream whatever is focused.
  games="$(${pkgs.systemd}/bin/busctl --user --json=short call com.feralinteractive.GameMode \
    /com/feralinteractive/GameMode com.feralinteractive.GameMode ListGames 2>/dev/null |
    "$jq" -c '[.data[0][][0]]' || echo '[]')"
  window="$("$hyprctl" clients -j | "$jq" -c --argjson games "$games" \
    'map(select(.pid as $pid | $games | index($pid))) | first // empty')"
  if [ -z "$window" ]; then
    window="$("$hyprctl" activewindow -j)"
  fi

  pid="$("$jq" -r '.pid // empty' <<<"$window")"
  if [ -z "$pid" ]; then
    notify "No window to stream"
    exit 1
  fi

  # The game and everything it started, since audio can come from a child process.
  pids="$(${pkgs.procps}/bin/ps -eo pid=,ppid= | ${pkgs.gawk}/bin/awk -v root="$pid" '
    { parent[$1] = $2 }
    END { for (p in parent) for (q = p; q > 1; q = parent[q]) if (q == root) { print p; break } }' |
    "$jq" -sc .)"

  # xdph lists windows by their Hyprland address in decimal.
  printf '%d\n' "$("$jq" -r .address <<<"$window")" > "$preselect"

  reply="$("$jq" -c --argjson pids "$pids" '{ title: .title, pids: $pids }' <<<"$window" |
    ${pkgs.socat}/bin/socat -t 5 - "UNIX-CONNECT:$socket" 2>/dev/null || true)"

  # Only a stream that is starting will open the picker.
  [ "$reply" = starting ] || rm -f "$preselect"

  if [ -z "$reply" ]; then
    notify "Vesktop isn't listening. Is it running with StreamGame enabled?"
    exit 1
  fi
''
