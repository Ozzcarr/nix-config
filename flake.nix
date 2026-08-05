{
  description = "NixOS configuration for oscar's machines";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix.url = "github:danth/stylix/release-26.05";
    claude-desktop.url = "github:patrickjaja/claude-desktop-extra";
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

      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      # Handed to every module as `vars`, so nothing reaches into hosts/ by path.
      varsFor = host: import ./hosts/common.nix // import ./hosts/${host}/variables.nix;

      mkNixos =
        host:
        lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs username host;
            vars = varsFor host;
          };
          modules = [ ./hosts/${host} ];
        };

      # Standalone home-manager, for rebuilding the user config without a full
      # system switch (the `hr` alias).
      mkHome =
        host:
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = {
            inherit inputs username host;
            vars = varsFor host;
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

      formatter.${system} = pkgs.nixfmt;

      checks.${system} = lib.listToAttrs (
        lib.concatMap (host: [
          (lib.nameValuePair "nixos-${host}" self.nixosConfigurations.${host}.config.system.build.toplevel)
          (lib.nameValuePair "home-${host}" self.homeConfigurations."${username}@${host}".activationPackage)
        ]) hosts
      );
    };
}
