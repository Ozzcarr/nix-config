# Config owned by the dotfiles repo (see dotfiles.nix). Kept enabled here
# only so the package gets installed and STARSHIP_CONFIG points at the
# default ~/.config/starship.toml location.
{
  programs.starship = {
    enable = true;
    settings = { };
  };
}
