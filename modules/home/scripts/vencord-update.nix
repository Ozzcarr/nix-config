{ pkgs }:

pkgs.writeShellScriptBin "vencord-update" ''
  set -euo pipefail

  export PATH="${
    pkgs.lib.makeBinPath [
      pkgs.coreutils
      pkgs.git
      pkgs.libnotify
      pkgs.nodejs
      pkgs.pnpm
    ]
  }:''${PATH:-}"

  dir="''${VENCORD_DIR:-$HOME/Vencord}"
  cache="''${XDG_CACHE_HOME:-$HOME/.cache}/vencord-update"

  # Only machines set up with vencord/setup.sh in dotfiles have a checkout.
  [ -d "$dir/.git" ] || exit 0

  fail() {
    echo "$1" >&2
    notify-send -a Vencord "Update failed" "$1" || true
    exit 1
  }

  cd "$dir"

  # Left silent: this just means offline, and the next run tries again.
  git fetch --quiet

  git merge --ff-only --quiet '@{upstream}' \
    || fail "Couldn't fast-forward $dir"

  # Tracked apart from the pull, so a failed build is retried on the next run.
  rev="$(git rev-parse HEAD)"
  [ "$(cat "$cache/built-rev" 2>/dev/null)" != "$rev" ] || exit 0

  mkdir -p "$cache"
  rm -rf "$cache/dist"
  cp -a dist "$cache/dist"

  # Without a TTY, pnpm aborts instead of asking to recreate node_modules.
  if ! { pnpm install --frozen-lockfile --config.confirmModulesPurge=false && pnpm build; }; then
    rm -rf dist
    mv "$cache/dist" dist
    fail "Build failed, keeping the previous one. See: journalctl --user -u vencord-update"
  fi

  rm -rf "$cache/dist"
  echo "$rev" > "$cache/built-rev"
''
