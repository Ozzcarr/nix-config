{ pkgs, ... }:
{
  home.packages = [
    (import ./edge-x11.nix { inherit pkgs; })
    (import ./vesktop-mute.nix { inherit pkgs; })
    (import ./vesktop-deafen.nix { inherit pkgs; })
    (import ./vesktop-status.nix { inherit pkgs; })
    (import ./gpu-status.nix { inherit pkgs; })
    (import ./screenshootin.nix { inherit pkgs; })
    (import ./shells/mkgen.nix { inherit pkgs; })
    (import ./shells/mkpy.nix { inherit pkgs; })
    (import ./shells/mkrust.nix { inherit pkgs; })
    (import ./task-waybar.nix { inherit pkgs; })
    (import ./wallpaper.nix { inherit pkgs; })
  ];
}
