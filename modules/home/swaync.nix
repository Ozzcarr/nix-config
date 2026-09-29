# Service wiring only; config.json and the stylesheet live in the dotfiles repo.
{ ... }:
{
  services.swaync.enable = true;

  # The module always generates a config.json, even with no settings set.
  # Disable it so the out-of-store link from dotfiles.nix owns that path.
  xdg.configFile."swaync/config.json".enable = false;
}
