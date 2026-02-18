{
  description = "__PROJECT_NAME__ dev shell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forEachSystem = nixpkgs.lib.genAttrs systems;
    in {
      devShells = forEachSystem (system:
        let
          pkgs = import nixpkgs { inherit system; };
        in {
          default = pkgs.mkShell {
            name = "__PROJECT_NAME__";

            NIX_LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
              pkgs.stdenv.cc.cc # libstdc++
              # pkgs.zlib # libz (for numpy)
            ];

            NIX_LD = pkgs.lib.fileContents "${pkgs.stdenv.cc}/nix-support/dynamic-linker";

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
          };
        });
    };
}