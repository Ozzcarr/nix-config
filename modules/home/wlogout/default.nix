{ vars, ... }:

{
  programs.wlogout = {
    enable = true;
    layout = [
      {
        label = "shutdown";
        action = "sleep 1; systemctl poweroff";
        text = "Shutdown";
        keybind = "s";
      }
      {
        "label" = "reboot";
        "action" = "sleep 1; systemctl reboot";
        "text" = "Reboot";
        "keybind" = "r";
      }
      {
        "label" = "logout";
        "action" = "sleep 1; hyprctl dispatch exit";
        "text" = "Exit";
        "keybind" = "e";
      }
      {
        "label" = "suspend";
        "action" = "sleep 1; systemctl suspend";
        "text" = "Suspend";
        "keybind" = "u";
      }
      {
        "label" = "lock";
        "action" = "sleep 1; hyprlock";
        "text" = "Lock";
        "keybind" = "o";
      }
      {
        "label" = "hibernate";
        "action" = "sleep 1; systemctl hibernate";
        "text" = "Hibernate";
        "keybind" = "b";
      }
    ];
    style = ''
      /* h/j/k/l reuse GTK's own arrow-key focus-navigation signal, so they
         move between buttons exactly like the arrow keys already do. */
      @binding-set vim-nav {
        bind "h" { "move-focus" (left) };
        bind "j" { "move-focus" (down) };
        bind "k" { "move-focus" (up) };
        bind "l" { "move-focus" (right) };
      }
      * {
        font-family: "JetBrainsMono NF", FontAwesome, sans-serif;
      	background-image: none;
      	transition: 20ms;
      }
      window {
      	background-color: rgba(12, 12, 12, 0.1);
        -gtk-key-bindings: vim-nav;
      }
      button {
      	color: #${vars.colors.base05};
        font-size:20px;
        background-repeat: no-repeat;
      	background-position: center;
      	background-size: 25%;
      	border-style: solid;
      	background-color: rgba(12, 12, 12, 0.3);
      	border: 3px solid #${vars.colors.base05};
        box-shadow: 0 4px 8px 0 rgba(0, 0, 0, 0.2), 0 6px 20px 0 rgba(0, 0, 0, 0.19);
      }
      /* Keyboard focus is the one authoritative "this is what Enter
         triggers" indicator. Hover is a lighter preview so it doesn't read
         as a second, equally-active selection when it lands on a different
         button than the current focus. */
      button:focus,
      button:active {
        color: #${vars.colors.base0B};
        background-color: rgba(12, 12, 12, 0.5);
        border: 3px solid #${vars.colors.base0B};
      }
      button:hover {
        border: 3px solid #${vars.colors.base0B};
      }
      #logout {
      	margin: 10px;
      	border-radius: 20px;
      	background-image: image(url("icons/logout.png"));
      }
      #suspend {
      	margin: 10px;
      	border-radius: 20px;
      	background-image: image(url("icons/suspend.png"));
      }
      #shutdown {
      	margin: 10px;
      	border-radius: 20px;
      	background-image: image(url("icons/shutdown.png"));
      }
      #reboot {
      	margin: 10px;
      	border-radius: 20px;
      	background-image: image(url("icons/reboot.png"));
      }
      #lock {
      	margin: 10px;
      	border-radius: 20px;
      	background-image: image(url("icons/lock.png"));
      }
      #hibernate {
      	margin: 10px;
      	border-radius: 20px;
      	background-image: image(url("icons/hibernate.png"));
      }
    '';
  };
  home.file.".config/wlogout/icons" = {
    source = ./icons;
    recursive = true;
  };
}
