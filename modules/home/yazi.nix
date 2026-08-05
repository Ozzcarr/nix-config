# Installed only; configured from the dotfiles repo.
{ pkgs, ... }:
{
  home.packages = [ pkgs.yazi ];
}
