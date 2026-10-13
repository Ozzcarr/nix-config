{
  config,
  lib,
  pkgs,
  ...
}:
let
  # OBS's NVENC test can't find the driver's libnvidia-encode on its own, so
  # without this NVENC, and the replay buffer that uses it, goes missing.
  obs = pkgs.symlinkJoin {
    name = "obs-studio";
    paths = [ config.programs.obs-studio.finalPackage ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/obs --prefix LD_LIBRARY_PATH : /run/opengl-driver/lib
    '';
  };
in
{
  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-pipewire-audio-capture
      obs-vkcapture
      obs-source-clone
      obs-move-transition
      obs-composite-blur
      obs-backgroundremoval
    ];
  };

  # Takes priority over the unwrapped obs the module installs.
  home.packages = [ (lib.hiPrio obs) ];
}
