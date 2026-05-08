{ pkgs }:
pkgs.writeShellScriptBin "vesktop-status" ''
  #!${pkgs.bash}/bin/bash
  set -euo pipefail

  find_stream_id() {
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
        return 0
      done

    return 1
  }

  input_id="$(find_stream_id "Chromium input" "Stream/Input/Audio" || true)"
  output_id="$(find_stream_id "Chromium" "Stream/Output/Audio" || true)"

  input_muted=false
  output_muted=false

  if [ -n "$input_id" ] && ${pkgs.wireplumber}/bin/wpctl get-volume "$input_id" | ${pkgs.gnugrep}/bin/grep -q '\[MUTED\]'; then
    input_muted=true
  fi

  if [ -n "$output_id" ] && ${pkgs.wireplumber}/bin/wpctl get-volume "$output_id" | ${pkgs.gnugrep}/bin/grep -q '\[MUTED\]'; then
    output_muted=true
  fi

  mode="$1"
  if [ -z "$mode" ]; then
    mode="both"
  fi

  if [ "$mode" = "mic" ]; then
    if [ "$input_muted" = true ]; then
      printf '{"text":"","class":"muted","tooltip":"Vesktop mic is muted"}\n'
    elif [ -z "$input_id" ]; then
      printf '{"text":"","class":"missing","tooltip":"Vesktop mic stream is not active"}\n'
    else
      printf '{"text":"","class":"active","tooltip":"Vesktop mic is live"}\n'
    fi
    exit 0
  fi

  if [ "$mode" = "out" ]; then
    if [ "$output_muted" = true ]; then
      printf '{"text":"","class":"deafened","tooltip":"Vesktop output is muted (deafened)"}\n'
    elif [ -z "$output_id" ]; then
      printf '{"text":"","class":"missing","tooltip":"Vesktop output stream is not active"}\n'
    else
      printf '{"text":"","class":"active","tooltip":"Vesktop output is live"}\n'
    fi
    exit 0
  fi

  # Default: combined indicator. Build text from flags: M for mic, D for output.
  text=""
  classes=""
  tooltip="Vesktop:"

  if [ "$input_muted" = true ]; then
    text="$text""M"
    classes="$classes"" muted"
    tooltip="$tooltip mic muted"
  fi

  if [ "$output_muted" = true ]; then
    text="$text""D"
    classes="$classes"" deafened"
    # add comma if tooltip already has extra info
    if [ "$tooltip" != "Vesktop:" ]; then
      tooltip="$tooltip,"
    fi
    tooltip="$tooltip output muted"
  fi

  if [ -n "$text" ]; then
    classes="$(printf '%s' "$classes" | ${pkgs.gnused}/bin/sed -E 's/^ +//')"
    printf '{"text":"%s","class":"%s","tooltip":"%s"}\n' "$text" "$classes" "$tooltip"
  else
    printf '{"text":"","class":"active","tooltip":"Vesktop audio is live"}\n'
  fi
''