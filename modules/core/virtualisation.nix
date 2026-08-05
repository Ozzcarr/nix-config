{ pkgs, ... }:
{
  virtualisation.docker = {
    enable = true;
    package = pkgs.docker_29;
  };

  environment.systemPackages = with pkgs; [
    lazydocker
  ];
}
