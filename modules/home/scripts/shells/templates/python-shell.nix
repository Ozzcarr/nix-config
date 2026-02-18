with import <nixpkgs> {};
pkgs.mkShell {
  name = "__PROJECT_NAME__";

  NIX_LD_LIBRARY_PATH = lib.makeLibraryPath [
    stdenv.cc.cc # libstdc++
    # zlib # libz (for numpy)
  ];

  NIX_LD = lib.fileContents "${stdenv.cc}/nix-support/dynamic-linker";

  packages = with pkgs; [
    uv
  ];

  shellHook = ''
    export UV_CACHE_DIR="$HOME/data/.config/uv"
    mkdir -p "$UV_CACHE_DIR"

    if [ -f .venv/bin/activate ]; then
      . .venv/bin/activate
    fi
  '';
}