# XDG autostart fires as soon as hyprland-session.target is reached, while
# waybar - which owns org.kde.StatusNotifierWatcher - is still a plain
# `exec-once` in hyprland.conf, behind a `sleep .5`. Qt looks for a tray host
# once, when the icon is constructed, and never retries, so EasyEffects loses
# that race and spends the whole session without an icon. libayatana applets
# (nm-applet, blueman) re-register when the watcher appears, hence unaffected.
{ pkgs, ... }:
let
  waitForHost = pkgs.writeShellScript "wait-for-tray-host" ''
    for _ in $(${pkgs.coreutils}/bin/seq 1 75); do
      owner="$(${pkgs.systemd}/bin/busctl --user call org.freedesktop.DBus /org/freedesktop/DBus \
        org.freedesktop.DBus NameHasOwner s org.kde.StatusNotifierWatcher 2>/dev/null || true)"
      [ "$owner" = "b true" ] && exit 0
      ${pkgs.coreutils}/bin/sleep 0.2
    done
    # A bar that never came up must not hold the rest of the session back.
    exit 0
  '';
in
{
  systemd.user.services.tray-host-ready = {
    Unit = {
      Description = "Wait for a StatusNotifier host before starting Qt tray applets";
      # Only the applets that cannot recover on their own belong here; ordering
      # the whole autostart target would also delay gnome-keyring.
      Before = [ "app-easyeffects\\x2dservice@autostart.service" ];
    };
    Service = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = waitForHost;
    };
    Install.WantedBy = [ "hyprland-session.target" ];
  };
}
