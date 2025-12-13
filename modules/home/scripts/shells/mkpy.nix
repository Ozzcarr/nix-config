{ pkgs }:
let
  pythonTemplate =
    pkgs.writeText "mkpy-template.nix"
      (builtins.readFile ./templates/python-shell.nix);
in
pkgs.writeShellScriptBin "mkpy" ''
  set -euo pipefail

  if [ "$#" -ne 1 ]; then
    echo "usage: mkpy <project-name>" >&2
    exit 1
  fi

  project_name="$1"
  target="$PWD/shell.nix"
  envrc="$PWD/.envrc"

  if [ -e "$target" ]; then
    echo "error: $target already exists" >&2
    exit 1
  fi

  tmp="$(mktemp)"
  cp ${pythonTemplate} "$tmp"
  sed -i "s/__PROJECT_NAME__/''${project_name}/g" "$tmp"
  mv "$tmp" "$target"
  chmod 0644 "$target"

  echo "Created $target"

  if [ ! -e "$envrc" ]; then
    printf 'use nix\n' > "$envrc"
    chmod 0644 "$envrc"
  fi

  echo "Created $envrc"

  if command -v direnv >/dev/null 2>&1; then
  (
    cd "$PWD"
    direnv allow
    PROJECT_NAME="''${project_name}" direnv exec . "${pkgs.bash}/bin/bash" -s <<'EOS'
set -euo pipefail

if ! command -v uv >/dev/null 2>&1; then
  echo "uv not found inside the nix shell; list it in shell.nix packages." >&2
  exit 0
fi

if [ ! -f ./pyproject.toml ]; then
  echo "Initializing project with uv..."
  uv init --name "''${PROJECT_NAME}" .
fi

echo "Syncing environment with uv..."
uv sync
EOS
  )
  else
    echo "direnv not found; run 'direnv allow' and uv commands manually." >&2
  fi
''