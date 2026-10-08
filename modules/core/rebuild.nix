# Rebuilds for the shell's NixOS panel. The shell starts
# `oz-system@<operation>.service`; polkit asks for the password through the
# shell's own agent, and the output goes to a log the shell follows. Nothing
# here is passwordless.
{
  config,
  pkgs,
  username,
  host,
  ...
}:
let
  flake = "/home/${username}/nix-config";

  run = pkgs.writeShellScript "oz-system" ''
    set -euo pipefail
    profile=/nix/var/nix/profiles/system
    before="$(readlink -f "$profile")"

    # The flake is only touched as the user: flake.lock stays theirs, and Nix
    # refuses to open a git repo owned by someone else.
    as_user() {
      runuser -u ${username} -- "$@"
    }

    # Builds as the user like nh does; root only sets the profile and activates.
    rebuild() {
      out="$(as_user nix build --no-link --print-out-paths \
        "${flake}#nixosConfigurations.${host}.config.system.build.toplevel")"
      nix-env -p "$profile" --set "$out"
      "$out/bin/switch-to-configuration" "$1"
    }

    case "$1" in
      switch | boot)
        rebuild "$1"
        ;;
      update-switch | update-boot)
        as_user nix flake update --flake ${flake}
        rebuild "''${1#update-}"
        ;;
      rollback)
        nix-env -p "$profile" --rollback
        "$(readlink -f "$profile")/bin/switch-to-configuration" switch
        ;;
      clean)
        as_user nix-collect-garbage --delete-old
        nix-collect-garbage -d
        /run/current-system/bin/switch-to-configuration boot
        ;;
      *)
        echo "unknown operation: $1" >&2
        exit 2
        ;;
    esac

    after="$(readlink -f "$profile")"
    if [ "$after" != "$before" ]; then
      echo
      nvd diff "$before" "$after"
    fi
  '';
in
{
  systemd.tmpfiles.rules = [ "d /run/oz-system 0755 root root -" ];

  systemd.services."oz-system@" = {
    description = "NixOS %i from the shell";
    path = [
      config.nix.package
      config.systemd.package
      pkgs.git
      pkgs.nvd
      pkgs.util-linux
      pkgs.coreutils
    ];
    # A switch that changes this unit must not stop the switch running in it.
    restartIfChanged = false;
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${run} %i";
      StandardOutput = "truncate:/run/oz-system/log";
      StandardError = "inherit";
    };
  };
}
