{ vars, ... }: {
  services.swaync = {
    enable = true;
    settings = {
      positionX = "right";
      positionY = "top";
      layer = "overlay";
      control-center-margin-top = 10;
      control-center-margin-bottom = 10;
      control-center-margin-right = 10;
      control-center-margin-left = 10;
      notification-icon-size = 64;
      notification-body-image-height = 100;
      notification-body-image-width = 200;
      timeout = 10;
      timeout-low = 5;
      timeout-critical = 0;
      fit-to-screen = true;
      control-center-width = 500;
      control-center-height = 800;
      notification-window-width = 500;
      keyboard-shortcuts = true;
      image-visibility = "when-available";
      transition-time = 200;
      hide-on-clear = false;
      hide-on-action = true;
      script-fail-notify = true;
      widget-config = {
        title = {
          text = "Notification Center";
          clear-all-button = true;
          button-text = "󰆴 Clear All";
        };
        dnd = {
          text = "Do Not Disturb";
        };
        label = {
          max-lines = 1;
          text = "Notification Center";
        };
        mpris = {
          image-size = 96;
          image-radius = 7;
        };
        volume = {
          label = "󰕾";
        };
        backlight = {
          label = "󰃟";
        };
      };
      widgets = [
        "title"
        "mpris"
        "volume"
        "backlight"
        "dnd"
        "notifications"
      ];
    };
    style = ''
      * {
        font-family: JetBrainsMono Nerd Font Mono;
        font-weight: bold;
      }
      .control-center .notification-row:focus,
      .control-center .notification-row:hover {
        opacity: 0.9;
        background: #${vars.colors.base00}
      }
      .notification-row {
        outline: none;
        margin: 10px;
        padding: 0;
      }
      .notification {
        background: transparent;
        padding: 0;
        margin: 0px;
      }
      .notification-content {
        background: #${vars.colors.base00};
        padding: 10px;
        border-radius: 5px;
        border: 2px solid #${vars.colors.base0E};
        margin: 0;
      }
      .notification-default-action {
        margin: 0;
        padding: 0;
        border-radius: 5px;
      }
      .close-button {
        background: #${vars.colors.base08};
        color: #${vars.colors.base00};
        text-shadow: none;
        padding: 0;
        border-radius: 5px;
        margin-top: 5px;
        margin-right: 5px;
      }
      .close-button:hover {
        box-shadow: none;
        background: #${vars.colors.base0E};
        transition: all .15s ease-in-out;
        border: none
      }
      .notification-action {
        border: 2px solid #${vars.colors.base0E};
        border-top: none;
        border-radius: 5px;
      }
      .notification-default-action:hover,
      .notification-action:hover {
        color: #${vars.colors.base00};
        background: #${vars.colors.base0E}
      }
      .notification-default-action {
        border-radius: 5px;
        margin: 0px;
      }
      .notification-default-action:not(:only-child) {
        border-bottom-left-radius: 7px;
        border-bottom-right-radius: 7px
      }
      .notification-action:first-child {
        border-bottom-left-radius: 10px;
        background: #${vars.colors.base00}
      }
      .notification-action:last-child {
        border-bottom-right-radius: 10px;
        background: #${vars.colors.base00}
      }
      .inline-reply {
        margin-top: 8px
      }
      .inline-reply-entry {
        background: #${vars.colors.base00};
        color: #${vars.colors.base05};
        caret-color: #${vars.colors.base05};
        border: 1px solid #${vars.colors.base09};
        border-radius: 5px
      }
      .inline-reply-button {
        margin-left: 4px;
        background: #${vars.colors.base00};
        border: 1px solid #${vars.colors.base09};
        border-radius: 5px;
        color: #${vars.colors.base05}
      }
      .inline-reply-button:disabled {
        background: initial;
        color: #${vars.colors.base03};
        border: 1px solid transparent
      }
      .inline-reply-button:hover {
        background: #${vars.colors.base00}
      }
      .body-image {
        margin-top: 6px;
        background-color: #${vars.colors.base05};
        border-radius: 5px
      }
      .summary {
        font-size: 16px;
        font-weight: 700;
        background: transparent;
        color: #${vars.colors.base0E};
        text-shadow: none
      }
      .time {
        font-size: 16px;
        font-weight: 700;
        background: transparent;
        color: #${vars.colors.base05};
        text-shadow: none;
        margin-right: 18px
      }
      .body {
        font-size: 15px;
        font-weight: 400;
        background: transparent;
        color: #${vars.colors.base05};
        text-shadow: none
      }
      .control-center {
        background: #${vars.colors.base00};
        border: 2px solid #${vars.colors.base0E};
        border-radius: 5px;
      }
      .control-center-list {
        background: transparent
      }
      .control-center-list-placeholder {
        opacity: .5
      }
      .floating-notifications {
        background: transparent
      }
      .blank-window {
        background: alpha(black, 0)
      }
      .widget-title {
        color: #${vars.colors.base0E};
        background: #${vars.colors.base00};
        padding: 5px 10px;
        margin: 10px 10px 5px 10px;
        font-size: 1.5rem;
        border-radius: 5px;
      }
      .widget-title>button {
        font-size: 1rem;
        color: #${vars.colors.base05};
        text-shadow: none;
        background: #${vars.colors.base00};
        box-shadow: none;
        border-radius: 5px;
      }
      .widget-title>button:hover {
        background: #${vars.colors.base08};
        color: #${vars.colors.base00};
      }
      .widget-dnd {
        background: #${vars.colors.base00};
        padding: 5px 10px;
        margin: 10px 10px 5px 10px;
        border-radius: 5px;
        font-size: large;
        color: #${vars.colors.base0E};
      }
      .widget-dnd>switch {
        border-radius: 5px;
        /* border: 1px solid #${vars.colors.base0B}; */
        background: #${vars.colors.base0E};
      }
      .widget-dnd>switch:checked {
        background: #${vars.colors.base08};
        border: 1px solid #${vars.colors.base08};
      }
      .widget-dnd>switch slider {
        background: #${vars.colors.base00};
        border-radius: 5px
      }
      .widget-dnd>switch:checked slider {
        background: #${vars.colors.base00};
        border-radius: 5px
      }
      .widget-label {
          margin: 10px 10px 5px 10px;
      }
      .widget-label>label {
        font-size: 1rem;
        color: #${vars.colors.base05};
      }
      .widget-mpris {
        color: #${vars.colors.base05};
        padding: 5px 10px;
        margin: 10px 10px 5px 10px;
        border-radius: 5px;
      }
      .widget-mpris > box > button {
        border-radius: 5px;
      }
      .widget-mpris-player {
        padding: 5px 10px;
        margin: 10px
      }
      .widget-mpris-title {
        font-weight: 700;
        font-size: 1.25rem
      }
      .widget-mpris-subtitle {
        font-size: 1.1rem
      }
      .widget-menubar>box>.menu-button-bar>button {
        border: none;
        background: transparent
      }
      .topbar-buttons>button {
        border: none;
        background: transparent
      }
      .widget-volume {
        background: #${vars.colors.base01};
        padding: 5px;
        margin: 10px 10px 5px 10px;
        border-radius: 5px;
        font-size: x-large;
        color: #${vars.colors.base05};
      }
      .widget-volume>box>button {
        background: #${vars.colors.base0E};
        border: none
      }
      .per-app-volume {
        background-color: #${vars.colors.base00};
        padding: 4px 8px 8px;
        margin: 0 8px 8px;
        border-radius: 5px;
      }
      .widget-backlight {
        background: #${vars.colors.base01};
        padding: 5px;
        margin: 10px 10px 5px 10px;
        border-radius: 5px;
        font-size: x-large;
        color: #${vars.colors.base05}
      }
    '';
  };
}
