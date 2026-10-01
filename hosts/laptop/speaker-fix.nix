{ pkgs, ... }:
let
  # The es8336 codec (sof-essx8336, HUAWEI BOD-WXX9) boots with the DAC not
  # routed into the headphone/speaker output mixer, so the speakers stay
  # silent even though PipeWire reports them as unmuted and at full volume.
  fixSpeakerMixer = pkgs.writeShellScript "fix-speaker-mixer" ''
    ${pkgs.alsa-utils}/bin/amixer -c0 sset 'Left Headphone Mixer Left DAC' on
    ${pkgs.alsa-utils}/bin/amixer -c0 sset 'Right Headphone Mixer Right DAC' on
    ${pkgs.alsa-utils}/bin/amixer -c0 sset 'Headphone' on
  '';
in
{
  systemd.services.fix-speaker-mixer = {
    description = "Enable DAC routing to the speaker output on the es8336 codec";
    bindsTo = [ "dev-snd-controlC0.device" ];
    after = [ "dev-snd-controlC0.device" ];
    wantedBy = [ "dev-snd-controlC0.device" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${fixSpeakerMixer}";
    };
  };

  powerManagement.resumeCommands = ''
    ${fixSpeakerMixer}
  '';
}
