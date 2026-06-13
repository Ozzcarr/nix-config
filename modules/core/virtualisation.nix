{ pkgs, ... }: {
  # Only enable either docker or podman -- Not both
  virtualisation = {
    docker = {
      enable = true;
      package = pkgs.docker_29;
    };

    podman.enable = false;

    libvirtd = {
      enable = true;
    };

    virtualbox.host = {
      enable = false;
      enableExtensionPack = true;
    };
  };

  programs = {
    virt-manager.enable = false;
  };

  environment.systemPackages = with pkgs; [
    virt-viewer # View Virtual Machines
    lazydocker
    docker_29
  ];
}
