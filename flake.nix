{
  description = "NixOS Config";

  inputs = {
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    stylix.url = "github:danth/stylix/release-25.11";
    nix-flatpak.url = "github:gmodena/nix-flatpak?ref=latest";
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      nix-flatpak,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      host = "desktop";
      profile = "nvidia";
      username = "oscar";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      # Deduplicate nixosConfigurations while preserving the top-level 'profile'
      mkNixosConfig = gpuProfile: nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit inputs;
          inherit username;
          inherit host;
          inherit profile; # keep using the let-bound profile for modules/scripts
        };
        modules = [
          ./profiles/${gpuProfile}
          nix-flatpak.nixosModules.nix-flatpak
        ];
      };

      mkHomeConfig = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {
          inherit inputs username host profile;
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
      nixosConfigurations = {
        amd = mkNixosConfig "amd";
        nvidia = mkNixosConfig "nvidia";
        nvidia-laptop = mkNixosConfig "nvidia-laptop";
        amd-hybrid = mkNixosConfig "amd-hybrid";
        intel = mkNixosConfig "intel";
        vm = mkNixosConfig "vm";
      };

      homeConfigurations = {
        ${username} = mkHomeConfig;
      };
    };
}
