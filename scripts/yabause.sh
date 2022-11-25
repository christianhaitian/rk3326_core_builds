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

	# Libretro yabause build
	if [[ "$var" == "yabause" || "$var" == "all" ]]; then
	 cd $cur_wd
	  if [ ! -d "yabause/" ]; then
		git clone --recursive https://github.com/libretro/yabause.git
		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the yabause libretro git.  Is Internet active or did the git location change?  Stopping here."
		  exit 1
		fi
		cp patches/yabause-patch* yabause/.
	  fi

	 cd yabause/
	 #git reset --hard 7ae0de7abc378f6077aff0fd365ab25cff58b055
	 
	 yabause_patches=$(find *.patch)
	 
	 if [[ ! -z "$yabause_patches" ]]; then
	  for patching in yabause-patch*
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

	  make -C yabause/src/libretro clean
	  if [[ "$bitness" == "32" ]]; then
	    make -C yabause/src/libretro HAVE_SSE=0 platform=armvneonhardfloat -j$(nproc)
	  else
	    make -C yabause/src/libretro HAVE_SSE=0 -j$(nproc)
	  fi

	  if [[ $? != "0" ]]; then
		echo " "
		echo "There was an error while building the newest lr-yabause core.  Stopping here."
		exit 1
	  fi

	  strip yabause/src/libretro/yabause_libretro.so

	  if [ ! -d "../cores$bitness/" ]; then
		mkdir -v ../cores$bitness
	  fi

	  cp yabause/src/libretro/yabause_libretro.so ../cores$bitness/.

	  gitcommit=$(git log | grep -m 1 commit | cut -c -14 | cut -c 8-)
	  echo $gitcommit > ../cores$bitness/yabause_libretro.so.commit

	  echo " "
	  echo "yabause_libretro.so has been created and has been placed in the rk3326_core_builds/cores$bitness subfolder"
	fi
