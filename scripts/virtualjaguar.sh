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

	# Libretro virtualjaguar build
	if [[ "$var" == "virtualjaguar" || "$var" == "all" ]] && [[ "$bitness" == "64" ]]; then
	 cd $cur_wd
	  if [ ! -d "virtualjaguar-libretro/" ]; then
		git clone https://github.com/libretro/virtualjaguar-libretro.git
		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the libretro git.  Is Internet active or did the git location change?  Stopping here."
		  exit 1
		 fi
		cp patches/virtualjaguar-patch* virtualjaguar-libretro/.
	  fi

	 cd virtualjaguar-libretro/
	 
	 virtualjaguar_patches=$(find *.patch)
	 
	 if [[ ! -z "$virtualjaguar_patches" ]]; then
	  for patching in virtualjaguar-patch*
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

	  make clean
	  make -j$(nproc)

	  if [[ $? != "0" ]]; then
		echo " "
		echo "There was an error while building the newest lr-virtualjaguar core.  Stopping here."
		exit 1
	  fi

	  strip virtualjaguar_libretro.so

	  if [ ! -d "../cores64/" ]; then
		mkdir -v ../cores64
	  fi

	  cp virtualjaguar_libretro.so ../cores64/.

	  gitcommit=$(git log | grep -m 1 commit | cut -c -14 | cut -c 8-)
	  echo $gitcommit > ../cores$(getconf LONG_BIT)/virtualjaguar_libretro.so.commit

	  echo " "
	  echo "virtualjaguar_libretro.so has been created and has been placed in the rk3326_core_builds/cores64 subfolder"
	fi
