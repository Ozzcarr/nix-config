{ pkgs, config, ... }:
let
  sessions = "${config.services.displayManager.sessionData.desktops}/share/wayland-sessions";
  theme = "text=gray;time=gray;greet=gray;input=gray;action=gray;border=lightmagenta;title=lightmagenta;prompt=lightmagenta;button=lightmagenta";
in
{
  services.greetd = {
    enable = true;
    useTextGreeter = true;
    settings.default_session.command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-session --asterisks --sessions ${sessions} --cmd '${pkgs.uwsm}/bin/uwsm start -e -D Hyprland hyprland.desktop' --theme '${theme}'";
  };
}
