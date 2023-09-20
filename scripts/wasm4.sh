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

	# Libretro wasm4 build
	if [[ "$var" == "wasm4" || "$var" == "all" ]] && [[ "$bitness" == "64" ]]; then
	 cd $cur_wd
	  if [ ! -d "wasm4/" ]; then
		git clone --recursive https://github.com/aduros/wasm4.git
		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the libretro git.  Is Internet active or did the git location change?  Stopping here."
		  exit 1
		 fi
		cp patches/wasm4-patch* wasm4/.
	  fi

	 cd wasm4/runtimes/native
	 
	 wasm4_patches=$(find *.patch)
	 
	 if [[ ! -z "$wasm4_patches" ]]; then
	  for patching in wasm4-patch*
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

      cmake -DLIBRETRO=on -DCMAKE_BUILD_TYPE=Release
	  make -j$(nproc)

	  if [[ $? != "0" ]]; then
		echo " "
		echo "There was an error while building the newest lr-wasm4 core.  Stopping here."
		exit 1
	  fi

	  strip wasm4_libretro.so

	  if [ ! -d "../../../cores64/" ]; then
		mkdir -v ../../../cores64
	  fi

	  cp wasm4_libretro.so ../../../cores64/.

	  gitcommit=$(git log | grep -m 1 commit | cut -c -14 | cut -c 8-)
	  echo $gitcommit > ../../../cores$(getconf LONG_BIT)/wasm4_libretro.so.commit

	  echo " "
	  echo "wasm4_libretro.so has been created and has been placed in the rk3326_core_builds/cores64 subfolder"
	fi
