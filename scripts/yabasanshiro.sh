#!/bin/bash

##################################################################
# Created by Christian Haitian for use to easily update          #
# various standalone emulators, libretro cores, and other        #
# various programs for the RK3566 platform for various Linux     #
# based distributions.                                           #
# See the LICENSE.md file at the top-level directory of this     #
# repository.                                                    #
##################################################################

cur_wd="$PWD"
bitness="$(getconf LONG_BIT)"

	# Libretro yabasanshiro build
	if [[ "$var" == "yabasanshiro" || "$var" == "all" ]]; then
	 cd $cur_wd
	  if [ ! -d "yabasanshiro/" ]; then
		git clone https://github.com/libretro/yabause.git -b yabasanshiro
		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the yabasanshiro (yabause) libretro git.  Is Internet active or did the git location change?  Stopping here."
		  exit 1
		fi
		cp patches/yabasanshiro-patch* yabause/.
	  fi

	 cd yabause/
	 #git reset --hard 7ae0de7abc378f6077aff0fd365ab25cff58b055
	 
	 yabasanshiro_patches=$(find *.patch)
	 
	 if [[ ! -z "$yabasanshiro_patches" ]]; then
	  for patching in yabasanshiro-patch*
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
	    make -C yabause/src/libretro platform=goadvance -j$(nproc)
	  else
	    make -C yabause/src/libretro platform=rockpro64 HAVE_NEON=0 -j$(nproc)
	  fi

	  if [[ $? != "0" ]]; then
		echo " "
		echo "There was an error while building the newest lr-yabasanshiro core.  Stopping here."
		exit 1
	  fi

	  strip yabause/src/libretro/yabasanshiro_libretro.so

	  if [ ! -d "../cores$bitness/" ]; then
		mkdir -v ../cores$bitness
	  fi

	  cp yabause/src/libretro/yabasanshiro_libretro.so ../cores$bitness/.

	  gitcommit=$(git log | grep -m 1 commit | cut -c -14 | cut -c 8-)
	  echo $gitcommit > ../cores$bitness/yabasanshiro_libretro.so.commit

	  echo " "
	  echo "yabasanshiro_libretro.so has been created and has been placed in the rk3566_core_builds/cores$bitness subfolder"
	fi
