{ pkgs, ... }:
let
  myPython = pkgs.python311.withPackages (ps: with ps; [
    ipykernel
    jupyter
    pip
    pyzmq
  ]);
in
{
  environment.systemPackages = [
    myPython
  ];
}
