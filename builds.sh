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
  if [[ "$var" != "all" ]] && [[ "$var" != "ALL" ]]; then
      cd $cur_wd
      source scripts/"$var".sh
  else
       for build_this in scripts/*.sh
       do
           if [[ $build_this == *"mame"* ]] || [[ $build_this == *"mess"* ]]; then
             echo "Skipping $build_this for now.  We'll build this last if ALL was requested."
           elif [[ $build_this == *"mupen64plus-"* ]] || [[ $build_this == *"mupen64plussa"* ]]; then
             echo "Skipping $build_this as it's not a libretro core"
           else
                cd $cur_wd
                source $build_this all
                if [[ $? != "0" ]]; then
                     echo " "
                     echo "There was an error while processing $build_this.  Stopping here."
                     exit 1
                fi
           fi
       done
       if [[ "$var" == "ALL" ]]; then
         cd $cur_wd
         source scripts/mess.sh
         cd $cur_wd
         source scripts/mame.sh
         cd $cur_wd
         source scripts/mame2003-plus.sh
       fi
  fi
done
