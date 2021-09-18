#!/bin/bash

cur_wd="$PWD"
valid_id='^[0-9]+$'
es_git="https://github.com/christianhaitian/EmulationStation-fcamod.git"
nxengevo_git="https://github.com/nxengine/nxengine-evo.git"
ra_cores_git="https://github.com/christianhaitian/retroarch-cores.git"
bitness="$(getconf LONG_BIT)"

for var in $@
do
  if [[ "$var" != "all" ]]; then
      cd $cur_wd
      source scripts/"$var".sh
  else
      cd $cur_wd
      source scripts/picodrive.sh
      cd $cur_wd
      source scripts/gpsp.sh
      cd $cur_wd
      source scripts/mgba.sh
      cd $cur_wd
      source scripts/parallel-n64.sh
      cd $cur_wd
      source scripts/flycast.sh
      cd $cur_wd
      source scripts/dosbox_pure.sh
      cd $cur_wd
      source scripts/fbneo.sh
      cd $cur_wd
      source scripts/pcsx_rearmed.sh
      cd $cur_wd
      source scripts/sameboy.sh
  fi
done
