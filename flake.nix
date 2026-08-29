{
  description = "NixOS configuration for oscar's machines";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    claude-desktop.url = "github:patrickjaja/claude-desktop-extra";

    stylix.url = "github:danth/stylix/release-26.05";

    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      username = "oscar";

      hosts = [
        "laptop"
        "desktop"
      ];

      inherit (nixpkgs) lib;

      # nixd only resolves packages reached through the name `pkgs`, so unstable
      # is an overlay attribute rather than a per-file `import nixpkgs-unstable`.
      unstableOverlay = final: prev: {
        unstable = import inputs.nixpkgs-unstable {
          inherit (prev.stdenv.hostPlatform) system;
          config.allowUnfree = true;
        };
      };

      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [ unstableOverlay ];
      };

      # Handed to every module as `vars`, so nothing reaches into hosts/ by path.
      vars = import ./hosts/common.nix;

      mkNixos =
        host:
        lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs username host vars;
          };
          modules = [
            inputs.stylix.nixosModules.stylix
            { nixpkgs.overlays = [ unstableOverlay ]; }
            ./hosts/${host}
          ];
        };

      # Standalone home-manager, for rebuilding the user config without a full
      # system switch (the `hr` alias).
      mkHome =
        host:
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = {
            inherit inputs username host vars;
          };
          modules = [
            inputs.stylix.homeModules.stylix
            ./modules/home
            {
              home.username = username;
              home.homeDirectory = "/home/${username}";
              home.stateVersion = "23.11";
            }
          ];
        };
    in
    {
      nixosConfigurations = lib.genAttrs hosts mkNixos;

      homeConfigurations = lib.listToAttrs (
        map (host: lib.nameValuePair "${username}@${host}" (mkHome host)) hosts
      );

      legacyPackages.${system} = pkgs;

      formatter.${system} = pkgs.nixfmt;

      checks.${system} = lib.listToAttrs (
        lib.concatMap (host: [
          (lib.nameValuePair "nixos-${host}" self.nixosConfigurations.${host}.config.system.build.toplevel)
          (lib.nameValuePair "home-${host}" self.homeConfigurations."${username}@${host}".activationPackage)
        ]) hosts
      );
    };
}
