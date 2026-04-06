{ pkgs }:
let
  genericTemplate =
    pkgs.writeText "mkgen-template.nix"
      (builtins.readFile ./templates/generic-shell.nix);
in
pkgs.writeShellScriptBin "mkgen" ''
  set -euo pipefail
  export UV_CACHE_DIR=~/data/.config/uv
  mkdir -p "$UV_CACHE_DIR"

  if [ "$#" -ne 1 ]; then
    echo "usage: mkgen <project-name>" >&2
    exit 1
  fi

  project_name="$1"
  target="$PWD/flake.nix"
  envrc="$PWD/.envrc"
  gitignore="$PWD/.gitignore"

  if [ -e "$target" ]; then
    echo "error: $target already exists" >&2
    exit 1
  fi

  tmp="$(mktemp)"
  cp ${genericTemplate} "$tmp"
  sed -i "s/__PROJECT_NAME__/''${project_name}/g" "$tmp"
  mv "$tmp" "$target"
  chmod 0644 "$target"

  echo "Created $target"

  if [ ! -e "$gitignore" ]; then
    printf '.direnv/\n' > "$gitignore"
    chmod 0644 "$gitignore"
    echo "Created $gitignore (with .direnv/)"
  else
    if ! grep -qxF ".direnv/" "$gitignore"; then
      if [ -s "$gitignore" ] && [ "$(tail -c 1 "$gitignore" | wc -l)" -eq 0 ]; then
        printf '\n' >> "$gitignore"
      fi
      printf '.direnv/\n' >> "$gitignore"
      echo "Added .direnv/ to $gitignore"
    fi
  fi

  if [ ! -e "$envrc" ]; then
    printf 'use flake\n' > "$envrc"
    chmod 0644 "$envrc"
    echo "Created $envrc"
  fi

  if command -v direnv >/dev/null 2>&1; then
    (
      cd "$PWD"
      direnv allow
      echo "Generic project scaffold ready."
    )
  else
    echo "direnv not found; run 'nix develop' manually." >&2
  fi
''
