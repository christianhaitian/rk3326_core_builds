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
bitness="$(getconf LONG_BIT)"

	# gametank git
	if [[ "$var" == "gametank" ]] && [[ "$bitness" == "64" ]]; then
	 cd $cur_wd
	 if [ ! -d "GameTankEmulator/" ]; then
       git clone --depth=1 --recurse-submodules https://github.com/clydeshaffer/GameTankEmulator.git
       if [[ $? != "0" ]]; then
         echo " "
	     echo "There was an error while cloning the gametank git source.  Is Internet active or did the download location change?  Stopping here."
	     exit 1
	   fi
	   cp patches/gametank-patch* GameTankEmulator/.
     else
       echo " "
	   echo "GameTankEmulator directory already exists.  Stopping here."
	   exit 1
     fi
     
	 cd GameTankEmulator
	 gametank_patches=$(find *.patch)

	 if [[ ! -z "$gametank_patches" ]]; then
	  for patching in gametank-patch*
	  do
		   patch -Np1 < "$patching"
		   if [[ $? != "0" ]]; then
			echo " "
			echo "There was an error while applying $patching.  Stopping here."
			exit 1
		   fi
		   rm "$patching" 
	  done
	 fi

     make -j$(nproc)
     if [[ $? != "0" ]]; then
       echo " "
	   echo "There was an error while building the gametank executable.  Stopping here."
	   exit 1
	 fi

	 if [ ! -d "../gametank64/" ]; then
	   mkdir -v ../gametank64
	 fi

     strip build/GameTankEmulator
     cp build/GameTankEmulator ../gametank64/.

	 echo " "
	 echo "GameTankEmulator has been created and has been placed in the rk3326_core_builds/gametank64 subfolder"
	fi
