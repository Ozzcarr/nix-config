# Stylix colors for Quickshell (as a *.qml.json singleton) and the Hyprland lua
# config. Named Scheme because QtQuick already has a Palette type.
{ config, lib, ... }:
let
  scheme = lib.genAttrs [
    "base00"
    "base01"
    "base02"
    "base03"
    "base04"
    "base05"
    "base06"
    "base07"
    "base08"
    "base09"
    "base0A"
    "base0B"
    "base0C"
    "base0D"
    "base0E"
    "base0F"
  ] (name: "#${config.lib.stylix.colors.${name}}");
in
{
  xdg.configFile = {
    "quickshell/oz/generated/Scheme.qml.json".text = builtins.toJSON scheme;
    "hypr/generated/scheme.lua".text = "return ${lib.generators.toLua { } scheme}\n";
  };
}
