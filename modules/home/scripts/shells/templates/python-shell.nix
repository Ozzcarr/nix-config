with import <nixpkgs> {};
pkgs.mkShell {
  name = "__PROJECT_NAME__";

  # Here is where you will add all the libraries required by your native modules
  # You can use the following one-liner to find out which ones you need.
  # Just make sure you have `gcc` installed.
  # `find .venv/ -type f -name "*.so" | xargs ldd | grep "not found" | sort | uniq`
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