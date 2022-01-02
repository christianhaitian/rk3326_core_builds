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

	# Libretro cap32 build
	if [[ "$var" == "cap32" || "$var" == "all" ]] && [[ "$bitness" == "64" ]]; then
	 cd $cur_wd
	  if [ ! -d "libretro-cap32/" ]; then
		git clone https://github.com/libretro/libretro-cap32.git
		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the libretro git.  Is Internet active or did the git location change?  Stopping here."
		  exit 1
		 fi
		cp patches/cap32-patch* libretro-cap32/.
	  fi

	 cd libretro-cap32/
	 
	 cap32_patches=$(find *.patch)
	 
	 if [[ ! -z "$cap32_patches" ]]; then
	  for patching in cap32-patch*
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
	  make -j$(($(nproc) - 1))

	  if [[ $? != "0" ]]; then
		echo " "
		echo "There was an error while building the newest lr-cap32 core.  Stopping here."
		exit 1
	  fi

	  strip cap32_libretro.so

	  if [ ! -d "../cores64/" ]; then
		mkdir -v ../cores64
	  fi

	  cp cap32_libretro.so ../cores64/.

	  gitcommit=$(git log | grep -m 1 commit | cut -c -14 | cut -c 8-)
	  echo $gitcommit > ../cores$(getconf LONG_BIT)/cap32_libretro.so.commit

	  echo " "
	  echo "cap32_libretro.so has been created and has been placed in the rk3326_core_builds/cores64 subfolder"
	fi
