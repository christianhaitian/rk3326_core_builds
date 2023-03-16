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

	# Libretro swanstation build
	if [[ "$var" == "swanstation" || "$var" == "all" ]] && [[ "$bitness" == "64" ]]; then
	 cd $cur_wd
	  if [ ! -d "swanstation-libretro/" ]; then
		git clone https://github.com/libretro/swanstation.git
		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the libretro git.  Is Internet active or did the git location change?  Stopping here."
		  exit 1
		 fi
		cp patches/swanstation-patch* swanstation/.
	  fi

	 cd swanstation/
	 
	 swanstation_patches=$(find *.patch)
	 
	 if [[ ! -z "$swanstation_patches" ]]; then
	  for patching in swanstation-patch*
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

      cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_LIBRETRO_CORE=ON
	  make clean
	  make -j$(nproc)

	  if [[ $? != "0" ]]; then
		echo " "
		echo "There was an error while building the newest lr-swanstation core.  Stopping here."
		exit 1
	  fi

	  strip swanstation_libretro.so

	  if [ ! -d "../cores64/" ]; then
		mkdir -v ../cores64
	  fi

	  cp swanstation_libretro.so ../cores64/.

	  gitcommit=$(git log | grep -m 1 commit | cut -c -14 | cut -c 8-)
	  echo $gitcommit > ../cores$(getconf LONG_BIT)/swanstation_libretro.so.commit

	  echo " "
	  echo "swanstation_libretro.so has been created and has been placed in the rk3326_core_builds/cores64 subfolder"
	fi
