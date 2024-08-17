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

	# Libretro emuscv build
	if [[ "$var" == "emuscv" || "$var" == "all" ]] && [[ "$bitness" == "64" ]]; then
	 cd $cur_wd
	  if [ ! -d "emuscv/" ]; then
		git clone --recursive https://gitlab.com/MaaaX-EmuSCV/libretro-emuscv.git
		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the libretro git.  Is Internet active or did the git location change?  Stopping here."
		  exit 1
		 fi
		cp patches/emuscv_patch* libretro-emuscv/.
	  fi

	 cd libretro-emuscv/
	 
	 emuscv_patches=$(find *.patch)
	 
	 if [[ ! -z "$emuscv_patches" ]]; then
	  for patching in emuscv_patch*
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

	  make build-tools -j$(nproc)
	  make platform=rpi3 -j$(nproc)

	  if [[ $? != "0" ]]; then
		echo " "
		echo "There was an error while building the newest lr-emuscv core.  Stopping here."
		exit 1
	  fi

	  strip emuscv_libretro.so

	  if [ ! -d "../cores64/" ]; then
		mkdir -v ../cores64
	  fi

	  cp emuscv_libretro.so ../cores64/.

	  gitcommit=$(git log | grep -m 1 commit | cut -c -14 | cut -c 8-)
	  echo $gitcommit > ../cores$(getconf LONG_BIT)/emuscv_libretro.so.commit

	  echo " "
	  echo "emuscv_libretro.so has been created and has been placed in the rk3326_core_builds/cores64 subfolder"
	fi
