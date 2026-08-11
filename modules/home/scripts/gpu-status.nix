{ pkgs }:

pkgs.writeShellScriptBin "gpu-status" ''
    #!${pkgs.bash}/bin/bash
    set -euo pipefail

    q() {
      nvidia-smi "$@" 2>/dev/null | head -n1 | tr -d '\r' | ${pkgs.gnused}/bin/sed 's/,//g' | xargs
    }

    util="$(q --query-gpu=utilization.gpu --format=csv,noheader,nounits)"
    temp="$(q --query-gpu=temperature.gpu --format=csv,noheader,nounits)"
    pwr="$(q --query-gpu=power.draw --format=csv,noheader,nounits)"
    memu="$(q --query-gpu=memory.used --format=csv,noheader,nounits)"
    memt="$(q --query-gpu=memory.total --format=csv,noheader,nounits)"

    [ -n "$util" ] || util="N/A"
    [ -n "$temp" ] || temp="N/A"
    [ -n "$pwr" ] || pwr="N/A"
    [ -n "$memu" ] || memu="N/A"
    [ -n "$memt" ] || memt="N/A"

    esc() {
      printf "%s" "$1" | ${pkgs.gnused}/bin/sed \
        -e 's/\\/\\\\/g' \
        -e 's/"/\\"/g' \
        -e ':a;N;$!ba;s/\n/\\n/g'
    }

    tip="GPU: $util%
  Temp: ''${temp}°C
  Power: ''${pwr} W
  VRAM: ''${memu} / ''${memt} MiB"

    printf '{"text":"%s","tooltip":"%s"}\n' "$(esc "$util")" "$(esc "$tip")"
''
