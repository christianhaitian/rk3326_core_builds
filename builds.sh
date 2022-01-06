#!/bin/bash

##################################################################
# Created by Christian Haitian for use to easily update          #
# various standalone emulators, libretro cores, and other        #
# various programs for the RK3326 platform for various Linux     #
# based distributions.                                           #
# See the LICENSE.md file at the top-level directory of this     #
# repository.                                                    #
##################################################################


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
      source scripts/cap32.sh
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
      source scripts/genesis-plus-gx.sh
      cd $cur_wd
      source scripts/gpsp.sh
      cd $cur_wd
      source scripts/handy.sh
      cd $cur_wd
      source scripts/mgba.sh
      cd $cur_wd
      source scripts/mupen64plus-next.sh
      cd $cur_wd
      source scripts/parallel-n64.sh
      cd $cur_wd
      source scripts/pcsx_rearmed.sh
      cd $cur_wd
      source scripts/pcfx.sh
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
      source scripts/sameduck.sh
      cd $cur_wd
      source scripts/scummvm-libretro.sh
      cd $cur_wd
      source scripts/snes9x.sh
      cd $cur_wd
      source scripts/snes9x2005.sh
      cd $cur_wd
      source scripts/supafaust.sh
      cd $cur_wd
      source scripts/uae4arm.sh
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
