{ host, ... }:
let
  inherit (import ../../hosts/${host}/variables.nix)
    tmuxEnable;
in
{
  imports = [
    ./bat.nix
    ./btop.nix
    ./bottom.nix
    ./cava.nix
    ./emoji.nix
    ./eza.nix
    ./fastfetch
    ./fzf.nix
    ./gh.nix
    ./git.nix
    ./gtk.nix
    ./htop.nix
    ./hyprland
    ./kitty.nix
    ./lazygit.nix
    ./obs-studio.nix
    ./noisetorch.nix
    ./nvf.nix
    ./obs-studio.nix
    ./rofi
    ./qt.nix
    ./scripts
    #./starship.nix
    #./starship-ddubs-1.nix
    ./stylix-catppuccin.nix
    ./stylix.nix
    ./swappy.nix
    ./swaync.nix
    ./tealdeer.nix
    ./virtmanager.nix
    ./waybar
    ./wlogout
    ./xdg.nix
    ./yazi
    ./zoxide.nix
    ./zsh
  ]
  ++ (if tmuxEnable then [ ./tmux.nix ] else [ ]);
}
