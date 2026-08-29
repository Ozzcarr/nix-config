{ pkgs }:

# Reads only the cache written by nix-update-check, so hovering the bar never
# touches the network or the Nix store.
pkgs.writeShellScriptBin "nix-update-waybar" ''
  #!${pkgs.bash}/bin/bash
  set -euo pipefail

  status="''${XDG_CACHE_HOME:-$HOME/.cache}/nix-update/status.json"

  if [ ! -r "$status" ]; then
    ${pkgs.jq}/bin/jq -nc '{text: "󰚰", class: "current", tooltip: "No update check has run yet"}'
    exit 0
  fi

  ${pkgs.jq}/bin/jq -c '
    def cap($n):
      if length > $n then .[0:$n] + ["… and \(length - $n) more"] else . end;

    (.packages | length) as $changed
    | (.added | length) as $new
    | ($changed + $new) as $count
    | ((.inputs | map(split(" ")[0]) | join(", "))) as $via
    | [ (if (.download // "") != "" then .download else empty end),
        "checked \(.checked)",
        "click to re-check" ] as $footer

    | if (.error // "") != "" then
        { text: "󰚰", class: "error",
          tooltip: "Update check failed\n\n\(.error)\n\nChecked \(.checked)" }

      elif $count > 0 then
        { text: "󰚰 \($count)",
          class: "outdated",
          tooltip: (
            [ "\(.stale) of \(.total) inputs moved", "" ]
            + .inputs
            + [ "", "\($changed) package\(if $changed == 1 then "" else "s" end) would change", "" ]
            + (.packages | cap(60))
            + (if $new > 0 then [ "", "New (\($new))", "" ] + (.added | cap(20)) else [] end)
            + [ "", ($footer | join(" · ")) ]
            | join("\n")
          ) }

      elif .stale > 0 then
        # Inputs moved but no package version changes, which is nothing to act on.
        { text: "󰚰", class: "current",
          tooltip: ("No package versions change\n\n"
                    + "\(.stale) input\(if .stale == 1 then "" else "s" end) moved (\($via)) but nothing "
                    + "in this system changes version.\n\nChecked \(.checked) · click to re-check") }

      else
        { text: "󰚰", class: "current",
          tooltip: "Everything up to date\nChecked \(.checked) · click to re-check" }
      end
  ' "$status"
''
