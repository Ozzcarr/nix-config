{ pkgs }:

pkgs.writeShellScriptBin "pomodoro-waybar" ''
  #!${pkgs.bash}/bin/bash
  set -euo pipefail

  STATE_DIR="''${XDG_STATE_HOME:-$HOME/.local/state}/pomodoro"
  STATE_FILE="$STATE_DIR/state"

  FOCUS_SECONDS=$((25 * 60))
  BREAK_SECONDS=$((5 * 60))

  mkdir -p "$STATE_DIR"

  notify() {
    ${pkgs.libnotify}/bin/notify-send "Pomodoro" "$1"
  }

  read_state() {
    mode="idle"
    phase="focus"
    remaining="$FOCUS_SECONDS"
    end_ts=0

    if [ -f "$STATE_FILE" ]; then
      while IFS='=' read -r key value; do
        case "$key" in
          mode) mode="$value" ;;
          phase) phase="$value" ;;
          remaining) remaining="$value" ;;
          end_ts) end_ts="$value" ;;
        esac
      done < "$STATE_FILE"
    fi
  }

  write_state() {
    local new_mode="$1"
    local new_phase="$2"
    local new_remaining="$3"
    local new_end_ts="$4"

    cat > "$STATE_FILE" <<EOF
mode=$new_mode
phase=$new_phase
remaining=$new_remaining
end_ts=$new_end_ts
EOF
  }

  format_time() {
    local seconds="$1"
    local mins=$((seconds / 60))
    local secs=$((seconds % 60))
    printf "%02d:%02d" "$mins" "$secs"
  }

  escape_json() {
    printf "%s" "$1" | ${pkgs.gnused}/bin/sed \
      -e 's/\\/\\\\/g' \
      -e 's/"/\\"/g' \
      -e ':a;N;$!ba;s/\n/\\n/g'
  }

  status() {
    read_state
    local now
    now=$(date +%s)

    if [ "$mode" = "running" ] && [ "$now" -ge "$end_ts" ]; then
      if [ "$phase" = "focus" ]; then
        phase="break"
        remaining="$BREAK_SECONDS"
        end_ts=$((now + BREAK_SECONDS))
        notify "Focus done. Break started (5 min)."
      else
        phase="focus"
        remaining="$FOCUS_SECONDS"
        end_ts=$((now + FOCUS_SECONDS))
        notify "Break done. Focus started (25 min)."
      fi
      write_state "$mode" "$phase" "$remaining" "$end_ts"
    fi

    if [ "$mode" = "running" ]; then
      remaining=$((end_ts - now))
      if [ "$remaining" -lt 0 ]; then
        remaining=0
      fi
    fi

    local label
    label=$(format_time "$remaining")

    local icon
    local css_class
    case "$mode:$phase" in
      running:focus)
        icon="󱎫"
        css_class="focus"
        ;;
      running:break)
        icon="󰒲"
        css_class="break"
        ;;
      paused:focus|paused:break)
        icon="󰏤"
        css_class="paused"
        ;;
      *)
        icon="󰔟"
        css_class="idle"
        ;;
    esac

    local tip=$'Left click: Start/Pause/Resume\nMiddle click: Skip phase\nRight click: Reset'

    printf '{"text":"%s %s","class":"%s","tooltip":"%s"}\n' \
      "$(escape_json "$icon")" \
      "$(escape_json "$label")" \
      "$(escape_json "$css_class")" \
      "$(escape_json "$tip")"
  }

  toggle() {
    read_state
    local now
    now=$(date +%s)

    case "$mode" in
      idle)
        mode="running"
        phase="focus"
        remaining="$FOCUS_SECONDS"
        end_ts=$((now + FOCUS_SECONDS))
        write_state "$mode" "$phase" "$remaining" "$end_ts"
        notify "Focus started (25 min)."
        ;;
      running)
        remaining=$((end_ts - now))
        if [ "$remaining" -lt 0 ]; then
          remaining=0
        fi
        mode="paused"
        end_ts=0
        write_state "$mode" "$phase" "$remaining" "$end_ts"
        notify "Timer paused."
        ;;
      paused)
        mode="running"
        end_ts=$((now + remaining))
        write_state "$mode" "$phase" "$remaining" "$end_ts"
        notify "Timer resumed."
        ;;
    esac
  }

  reset_timer() {
    write_state "idle" "focus" "$FOCUS_SECONDS" 0
    notify "Timer reset."
  }

  skip_phase() {
    read_state
    local now
    now=$(date +%s)

    if [ "$phase" = "focus" ]; then
      phase="break"
      remaining="$BREAK_SECONDS"
      notify "Skipped to break."
      end_ts=$((now + BREAK_SECONDS))
    else
      phase="focus"
      remaining="$FOCUS_SECONDS"
      notify "Skipped to focus."
      end_ts=$((now + FOCUS_SECONDS))
    fi

    write_state "running" "$phase" "$remaining" "$end_ts"
  }

  case "''${1:-status}" in
    status)
      status
      ;;
    toggle)
      toggle
      ;;
    reset)
      reset_timer
      ;;
    skip)
      skip_phase
      ;;
    *)
      echo "Usage: pomodoro-waybar {status|toggle|reset|skip}" >&2
      exit 1
      ;;
  esac
''