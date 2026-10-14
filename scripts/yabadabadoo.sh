#!/bin/bash

##################################################################
# Created by Christian Haitian for use to easily update          #
# various standalone emulators, libretro cores, and other        #
# various programs for the rk3326 platform for various Linux     #
# based distributions.                                           #
# See the LICENSE.md file at the top-level directory of this     #
# repository.                                                    #
##################################################################

cur_wd="$PWD"
bitness="$(getconf LONG_BIT)"

	# Libretro yabadabadoo build
	if [[ "$var" == "yabadabadoo" || "$var" == "all" ]] && [[ "$bitness" == "32" ]]; then
	 cd $cur_wd
	  if [ ! -d "yabadabadoo/" ]; then
		git clone --recursive https://github.com/ProRapSuperstarOriginalMaster/yabadabadoo.git
		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the yabadabadoo libretro git.  Is Internet active or did the git location change?  Stopping here."
		  exit 1
		fi
		cp patches/yabadabadoo-patch* yabadabadoo/.
	  fi

	 cd yabadabadoo/
	 
	 yabadabadoo_patches=$(find *.patch)
	 
	 if [[ ! -z "$yabadabadoo_patches" ]]; then
	  for patching in yabadabadoo-patch*
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
		echo "There was an error while building the newest lr-yabadabadoo core.  Stopping here."
		exit 1
	  fi

	  strip yabause/src/libretro/yabadabadoo_libretro.so

	  if [ ! -d "../cores$bitness/" ]; then
		mkdir -v ../cores$bitness
	  fi

	  cp yabause/src/libretro/yabadabadoo_libretro.so ../cores$bitness/.

	  gitcommit=$(git log | grep -m 1 commit | cut -c -14 | cut -c 8-)
	  echo $gitcommit > ../cores$bitness/yabadabadoo_libretro.so.commit

	  echo " "
	  echo "yabadabadoo_libretro.so has been created and has been placed in the rk3326_core_builds/cores$bitness subfolder"
	fi
