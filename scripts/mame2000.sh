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

	# Libretro mame2000 build
	if [[ "$var" == "mame2000" || "$var" == "all" ]] && [[ "$bitness" == "64" ]]; then
	 cd $cur_wd
	  if [ ! -d "mame2000-libretro/" ]; then
		git clone https://github.com/libretro/mame2000-libretro.git
		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the libretro git.  Is Internet active or did the git location change?  Stopping here."
		  exit 1
		 fi
		cp patches/mame2000-patch* mame2000-libretro/.
	  fi

	 cd mame2000-libretro/
	 
	 mame2000_patches=$(find *.patch)
	 
	 if [[ ! -z "$mame2000_patches" ]]; then
	  for patching in mame2000-patch*
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
      make -j3

	  if [[ $? != "0" ]]; then
		echo " "
		echo "There was an error while building the newest lr-mame2000 core.  Stopping here."
		exit 1
	  fi

	  strip mame2000_libretro.so

	  if [ ! -d "../cores$(getconf LONG_BIT)/" ]; then
		mkdir -v ../cores$(getconf LONG_BIT)
	  fi

	  cp mame2000_libretro.so ../cores$(getconf LONG_BIT)/mame2000_libretro.so

	  gitcommit=$(git log | grep -m 1 commit | cut -c -14 | cut -c 8-)
	  echo $gitcommit > ../cores$(getconf LONG_BIT)/mame2000_libretro.so.commit

	  echo " "
	  echo "mame2000_libretro.so has been created and has been placed in the rk3326_core_builds/cores$(getconf LONG_BIT) subfolder"
	fi
