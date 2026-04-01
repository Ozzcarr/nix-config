{
  pkgs,
  lib,
  host,
  config,
  profile,
  ...
}:
let
  inherit (import ../../../hosts/${host}/variables.nix) clock24h;
  hasNvidia = profile == "nvidia" || profile == "nvidia-laptop";
  gpuModule = if hasNvidia then [ "custom/gpu" ] else [];
in
with lib; {
  xdg.configFile."waybar/mocha.css".source = ./mocha.css;

  # Configure & Theme Waybar
  programs.waybar = {
    enable = true;
    package = pkgs.waybar;
    settings = [
      {
        layer = "top";
        position = "top";

        modules-left = [ "hyprland/workspaces" "cpu" ] ++ gpuModule ++ [ "memory" ];
        modules-center = [ "custom/music" ];
        modules-right = [ "custom/pomodoro" "pulseaudio" "backlight" "battery" "clock" "tray" "custom/notification" "custom/lock" "custom/power" ];

        "hyprland/workspaces" = {
          disable-scroll = true;
          sort-by-name = true;
          format = " {icon} ";
          format-icons = {
            default = "●";
          };
        };

        "memory" = {
          interval = 5;
          format = " {}%";
          tooltip = true;
        };

        "cpu" = {
          interval = 5;
          format = " {usage:2}%";
          tooltip = true;
        };

        "custom/gpu" = {
          interval = 5;
          return-type = "json";
          tooltip = true;
          format = " {}%";

          exec = ''
            sh -c '
              q() { nvidia-smi "$@" 2>/dev/null | head -n1 | tr -d "\r" | sed "s/,//g" | xargs; }

              util="$(q --query-gpu=utilization.gpu --format=csv,noheader,nounits)"
              temp="$(q --query-gpu=temperature.gpu --format=csv,noheader,nounits)"
              pwr="$(q --query-gpu=power.draw --format=csv,noheader,nounits)"
              memu="$(q --query-gpu=memory.used --format=csv,noheader,nounits)"
              memt="$(q --query-gpu=memory.total --format=csv,noheader,nounits)"

              [ -n "$util" ] || util="N/A"
              [ -n "$temp" ] || temp="N/A"
              [ -n "$pwr" ] || pwr="N/A"
              [ -n "$memu" ] || memu="N/A"
              [ -n "$memt" ] || memt="N/A"

              esc() {
                printf "%s" "$1" | sed \
                  -e "s/\\\\/\\\\\\\\/g" \
                  -e "s/\"/\\\\\"/g" \
                  -e ":a;N;\$!ba;s/\n/\\\\n/g"
              }

              tip="GPU: $util%
Temp: ''${temp}°C
Power: ''${pwr} W
VRAM: ''${memu} / ''${memt} MiB"

              printf "{\"text\":\"%s\",\"tooltip\":\"%s\"}\n" "$(esc "$util")" "$(esc "$tip")"
            '
          '';
        };

        tray = {
          icon-size = 21;
          spacing = 10;
        };

        "custom/music" = {
          format = "  {}";
          escape = true;
          interval = 5;
          tooltip = false;
          exec = "playerctl --player=spotify,firefox metadata --format='{{ title }}'";
          on-click = "playerctl --player=spotify,firefox play-pause";
          max-length = 50;
        };

        "custom/pomodoro" = {
          interval = 1;
          return-type = "json";
          format = "{}";
          exec = "pomodoro-waybar status";
          on-click = "pomodoro-waybar toggle";
          on-click-right = "pomodoro-waybar reset";
          on-click-middle = "pomodoro-waybar skip";
          tooltip = true;
        };

        clock = {
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
          format-alt = " {:%d/%m/%Y}";
          format = if clock24h then " {:%H:%M}" else " {:%I:%M %p}";
        };

        backlight = {
          device = "intel_backlight";
          format = "{icon}";
          format-icons = [ "" "" "" "" "" "" "" "" "" ];
        };

        battery = {
          interval = 5;
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{icon} {capacity}%";
          format-charging = "󰂄 {capacity}%";
          format-plugged = "󱘖 {capacity}%";
          format-icons = [
            "󰁺"
            "󰁻"
            "󰁼"
            "󰁽"
            "󰁾"
            "󰁿"
            "󰂀"
            "󰂁"
            "󰂂"
            "󰁹"
          ];
        };

        pulseaudio = {
          format = "{icon} {volume}%";
          format-muted = "";
          format-icons = {
            default = [ "" "" " " ];
          };
          on-click = "pavucontrol";
        };

        "custom/notification" = {
          tooltip = false;
          format = "<span size='12pt'>{icon}</span>";
          format-icons = {
            notification = "󱅫";
            none = "󰂜";
            dnd-notification = "󰂠";
            dnd-none = "󰪓";
            inhibited-notification = "󰂛";
            inhibited-none = "󰪑";
            dnd-inhibited-notification = "󰂛";
            dnd-inhibited-none = "󰪑";
          };
          return-type = "json";
          exec-if = "which swaync-client";
          exec = "swaync-client -swb";
          on-click = "swaync-client -t -sw";
          on-click-right = "swaync-client -d -sw";
          escape = true;
        };

        "custom/lock" = {
          tooltip = false;
          on-click = "sleep 0.2 && hyprlock";
          format = "";
        };

        "custom/power" = {
          tooltip = false;
          on-click = "wlogout &";
          format = "";
        };
      }
    ];

    style = ''
      @import "mocha.css";

      * {
        font-family: "FantasqueSansMono Nerd Font", "Maple Mono NF";
        font-size: 14px;
        min-height: 0;
      }

      window#waybar {
        background: rgba(30, 30, 46, 0.92);
        color: @text;
        border: none;
        border-bottom: 2px solid @mauve;
        border-radius: 0;
        margin: 0;
      }

      #workspaces {
        border-radius: 1rem;
        margin: 4px;
        background-color: @surface0;
        margin-left: 0.75rem;
      }

      #workspaces button {
        color: @lavender;
        border-radius: 1rem;
        padding: 0rem;
      }

      #workspaces button label {
        font-size: 20px;
      }

      #workspaces button.active {
        color: @sky;
        border-radius: 1rem;
      }

      #workspaces button:hover {
        color: @sapphire;
        border-radius: 1rem;
      }

      #cpu, #custom-gpu, #memory {
        background-color: @surface0;
        padding: 0.3rem 0.6rem;
        margin: 4px 0;
        color: @text;
      }

      #cpu {
        margin-left: 0.4rem;
        border-radius: 1rem 0 0 1rem;
        color: @peach;
      }

      #custom-gpu {
        border-radius: 0;
        color: @sky;
      }

      #memory {
        margin-right: 0.6rem;
        border-radius: 0 1rem 1rem 0;
        color: @teal;
      }

      #custom-music,
      #tray,
      #backlight,
      #clock,
      #battery,
      #custom-pomodoro,
      #pulseaudio,
      #custom-notification,
      #custom-lock,
      #custom-power {
        background-color: @surface0;
        padding: 0.3rem 0.8rem;
        margin: 4px 0;
      }

      #clock {
        color: @blue;
        border-radius: 0px 1rem 1rem 0px;
        margin-right: 1rem;
      }

      #battery {
        color: @green;
      }

      #battery.charging {
        color: @green;
      }

      #battery.warning:not(.charging) {
        color: @red;
      }

      #backlight {
        color: @yellow;
      }

      #backlight, #battery {
          border-radius: 0;
      }

      #pulseaudio {
        color: @maroon;
        border-radius: 1rem 0px 0px 1rem;
        margin-left: 1rem;
      }

      #custom-music {
        color: @mauve;
        border-radius: 1rem;
      }

      #custom-pomodoro {
        border-radius: 1rem;
      }

      #custom-pomodoro.focus {
        color: @peach;
      }

      #custom-pomodoro.break {
        color: @green;
      }

      #custom-pomodoro.paused {
        color: @yellow;
      }

      #custom-pomodoro.idle {
        color: @overlay1;
      }

      #custom-notification {
        color: @lavender;
        border-radius: 1rem;
        margin-right: 0.5rem;
      }

      #custom-lock {
          border-radius: 1rem 0px 0px 1rem;
          color: @lavender;
      }

      #custom-power {
          margin-right: 1rem;
          border-radius: 0px 1rem 1rem 0px;
          color: @red;
      }

      #tray {
        margin-right: 1rem;
        border-radius: 1rem;
      }

      tooltip {
        background: @base;
        color: @text;
        border: 1px solid @surface1;
        border-radius: 12px;
        padding: 8px 10px;
      }

      tooltip label {
        color: @text;
      }

      tooltip calendar {
        color: @text;
      }

      tooltip calendar.header {
        color: @mauve;
      }

      tooltip calendar.button {
        color: @blue;
      }

      tooltip calendar.highlight {
        color: @green;
      }

      tooltip calendar:indeterminate {
        color: @overlay0;
      }
    '';
  };
}
