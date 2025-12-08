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

	# Libretro np2kai build
	if [[ "$var" == "np2kai" || "$var" == "all" ]] && [[ "$bitness" == "64" ]]; then
	 cd $cur_wd
	  if [ ! -d "np2kai/" ]; then
		git clone --recursive https://github.com/AZO234/NP2kai.git np2kai
		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the libretro git.  Is Internet active or did the git location change?  Stopping here."
		  exit 1
		 fi
		cp patches/np2kai-patch* np2kai/.
	  fi

	 cd np2kai
	 
	 np2kai_patches=$(find *.patch)
	 
	 if [[ ! -z "$np2kai_patches" ]]; then
	  for patching in np2kai-patch*
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

	  cd sdl
	  make clean
	  make -j$(nproc)

	  if [[ $? != "0" ]]; then
		echo " "
		echo "There was an error while building the newest lr-np2kai core.  Stopping here."
		exit 1
	  fi

	  strip np2kai_libretro.so

	  if [ ! -d "../../cores64/" ]; then
		mkdir -v ../../cores64
	  fi

	  cp np2kai_libretro.so ../../cores64/.

	  gitcommit=$(git log | grep -m 1 commit | cut -c -14 | cut -c 8-)
	  echo $gitcommit > ../../cores$(getconf LONG_BIT)/np2kai_libretro.so.commit

	  echo " "
	  echo "np2kai_libretro.so has been created and has been placed in the rk3326_core_builds/cores64 subfolder"
	fi
