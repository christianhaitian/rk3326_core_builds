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

	# Libretro bsnes build
	if [[ "$var" == "bsnes" || "$var" == "all" ]] && [[ "$bitness" == "64" ]]; then
	 cd $cur_wd
	  if [ ! -d "bsnes/" ]; then
		git clone --recursive https://github.com/libretro/bsnes-libretro
		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the libretro git.  Is Internet active or did the git location change?  Stopping here."
		  exit 1
		 fi
		cp patches/bsnes-patch* bsnes/.
	  fi

	 cd bsnes-libretro/
	 
	 bsnes_patches=$(find *.patch)
	 
	 if [[ ! -z "$bsnes_patches" ]]; then
	  for patching in bsnes-patch*
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
		echo "There was an error while building the newest lr-bsnes core.  Stopping here."
		exit 1
	  fi

	  strip bsnes_libretro.so

	  if [ ! -d "../cores$(getconf LONG_BIT)/" ]; then
		mkdir -v ../cores$(getconf LONG_BIT)
	  fi

	  cp bsnes_libretro.so ../cores$(getconf LONG_BIT)/.

	  gitcommit=$(git log | grep -m 1 commit | cut -c -14 | cut -c 8-)
	  echo $gitcommit > ../cores$(getconf LONG_BIT)/bsnes_libretro.so.commit

	  echo " "
	  echo "bsnes_libretro.so has been created and has been placed in the RK3326_core_builds/cores$(getconf LONG_BIT) subfolder"
	fi
