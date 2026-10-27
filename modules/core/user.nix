{
  pkgs,
  inputs,
  username,
  host,
  vars,
  ...
}:
{
  imports = [ inputs.home-manager.nixosModules.home-manager ];
  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = false;
    backupFileExtension = "backup";
    extraSpecialArgs = {
      inherit
        inputs
        username
        host
        vars
        ;
    };
    users.${username} = {
      imports = [ ./../home ];
      home = {
        username = "${username}";
        homeDirectory = "/home/${username}";
        stateVersion = "23.11";
      };
    };
  };
  users.mutableUsers = true;
  users.users.${username} = {
    isNormalUser = true;
    description = vars.gitUsername;
    extraGroups = [
      "adbusers" # adb/fastboot without root
      "pipewire" # realtime limits, so audio threads don't rely on the portal's failing Realtime call
      "docker" # access to docker as non-root
      "networkmanager"
      "wheel" # sudo access
    ];
    shell = pkgs.zsh;
    ignoreShellProgramCheck = true;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMfOP3sbe68uEiEa1U9hqNqEEida1wso4P//3LqiY6pq oscar@laptop"
    ];
  };
  nix.settings.allowed-users = [ "${username}" ];
}
