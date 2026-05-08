{ pkgs }:
pkgs.writeShellScriptBin "vesktop-deafen" ''
  #!${pkgs.bash}/bin/bash
  set -euo pipefail

  find_stream_ids() {
    local expected_name="$1"
    local expected_class="$2"

    ${pkgs.wireplumber}/bin/wpctl status |
      ${pkgs.gawk}/bin/awk '/Streams:/ { in_streams = 1; next } /Video:/ { in_streams = 0 } in_streams && /^[[:space:]]*[0-9]+\./ { print $1 }' |
      tr -d '.' |
      while IFS= read -r stream_id; do
        [ -n "$stream_id" ] || continue

        details="$(${pkgs.wireplumber}/bin/wpctl inspect "$stream_id" 2>/dev/null || true)"

        printf '%s\n' "$details" | ${pkgs.gnugrep}/bin/grep -q 'application.process.binary = "electron"' || continue
        printf '%s\n' "$details" | ${pkgs.gnugrep}/bin/grep -q "node.name = \"$expected_name\"" || continue
        printf '%s\n' "$details" | ${pkgs.gnugrep}/bin/grep -q "media.class = \"$expected_class\"" || continue

        printf '%s\n' "$stream_id"
      done
  }

  while IFS= read -r stream_id; do
    [ -n "$stream_id" ] || continue
    ${pkgs.wireplumber}/bin/wpctl set-mute "$stream_id" toggle
  done < <(find_stream_ids "Chromium" "Stream/Output/Audio")
''
