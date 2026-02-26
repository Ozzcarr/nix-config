{ pkgs }:
pkgs.writeShellScriptBin "edge-x11" ''
  if command -v microsoft-edge >/dev/null 2>&1; then
    exec env NIXOS_OZONE_WL=0 microsoft-edge --ozone-platform=x11 --disable-features=WaylandWindowDecorations "$@"
  fi

  echo "Microsoft Edge not found (expected microsoft-edge)." >&2
  exit 127
''
