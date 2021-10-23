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
      source scripts/dosbox_pure.sh
      cd $cur_wd
      source scripts/duckstation.sh
      cd $cur_wd
      source scripts/fbneo.sh
      cd $cur_wd
      source scripts/flycast.sh
      cd $cur_wd
      source scripts/fmsx.sh
      cd $cur_wd
      source scripts/gambatte.sh
      cd $cur_wd
      source scripts/gpsp.sh
      cd $cur_wd
      source scripts/mgba.sh
      cd $cur_wd
      source scripts/parallel-n64.sh
      cd $cur_wd
      source scripts/pcsx_rearmed.sh
      cd $cur_wd
      source scripts/picodrive.sh
      cd $cur_wd
      source scripts/pokemini.sh
      cd $cur_wd
      source scripts/ppsspp-libretro.sh
      cd $cur_wd
      source scripts/quicknes.sh
      cd $cur_wd
      source scripts/sameboy.sh
      cd $cur_wd
      source scripts/scummvm-libretro.sh
      cd $cur_wd
      source scripts/snes9x.sh
      cd $cur_wd
      source scripts/supafaust.sh
      cd $cur_wd
      source scripts/yabasanshiro.sh
      #Warning...mess is a very long build.  Could be over 24 hours to complete.  That is why it is towards the end of this script.
      cd $cur_wd
      source scripts/mess.sh
      #Warning...mame is a very long build.  Could be over 24 hours to complete.  That is why it is last in this script.
      cd $cur_wd
      source scripts/mame.sh
  fi
done
