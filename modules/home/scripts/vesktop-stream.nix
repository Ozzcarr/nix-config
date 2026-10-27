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

  # The focused game wins over other games in gamemode. Without any, stream whatever is focused.
  games="$(${pkgs.systemd}/bin/busctl --user --json=short call com.feralinteractive.GameMode \
    /com/feralinteractive/GameMode com.feralinteractive.GameMode ListGames 2>/dev/null |
    "$jq" -c '[.data[0][][0]]' || echo '[]')"
  active="$("$hyprctl" activewindow -j)"
  window="$("$jq" -c --argjson games "$games" 'select(.pid as $pid | $games | index($pid))' <<<"$active")"
  if [ -z "$window" ]; then
    window="$("$hyprctl" clients -j | "$jq" -c --argjson games "$games" \
      'map(select(.pid as $pid | $games | index($pid))) | first // empty')"
  fi
  if [ -z "$window" ]; then
    window="$active"
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

  # Their PipeWire clients too, since streams from the ALSA plugin (osu!) carry no process id.
  clients="$(${pkgs.pipewire}/bin/pw-dump | "$jq" -c --argjson pids "$pids" \
    '[.[] | select(.type == "PipeWire:Interface:Client" and (.info.props["application.process.id"] as $pid | $pids | index($pid))) | .id | tostring]')"

  # xdph lists windows by their Hyprland address in decimal.
  printf '%d\n' "$("$jq" -r .address <<<"$window")" > "$preselect"

  reply="$("$jq" -c --argjson pids "$pids" --argjson clients "$clients" '{ title: .title, pids: $pids, clients: $clients }' <<<"$window" |
    ${pkgs.socat}/bin/socat -t 5 - "UNIX-CONNECT:$socket" 2>/dev/null || true)"

  # Only a stream that is starting will open the picker.
  [ "$reply" = starting ] || rm -f "$preselect"

  if [ -z "$reply" ]; then
    notify "Vesktop isn't listening. Is it running with StreamGame enabled?"
    exit 1
  fi
''
