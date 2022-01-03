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

	# Libretro handy build
	if [[ "$var" == "handy" || "$var" == "all" ]]; then
	 cd $cur_wd
	  if [ ! -d "handy/" ]; then
		git clone --recursive https://github.com/libretro/libretro-handy.git
		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the libretro git.  Is Internet active or did the git location change?  Stopping here."
		  exit 1
		 fi
		cp patches/handy-patch* libretro-handy/.
	  fi

	 cd libretro-handy/
	 
	 handy_patches=$(find *.patch)
	 
	 if [[ ! -z "$handy_patches" ]]; then
	  for patching in handy-patch*
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
	  if [[ "$bitness" == "64" ]]; then
	    make -j$(($(nproc) - 1))
	  else
        make platform=classic_armv8_a35 -j$(($(nproc) - 1))
      fi

	  if [[ $? != "0" ]]; then
		echo " "
		echo "There was an error while building the newest lr-handy core.  Stopping here."
		exit 1
	  fi

	  strip handy_libretro.so

	  if [ ! -d "../cores$bitness/" ]; then
		mkdir -v ../cores$bitness
	  fi

	  cp handy_libretro.so ../cores$bitness/.

	  gitcommit=$(git log | grep -m 1 commit | cut -c -14 | cut -c 8-)
	  echo $gitcommit > ../cores$bitness/handy_libretro.so.commit

	  echo " "
	  echo "handy_libretro.so has been created and has been placed in the rk3326_core_builds/cores$bitness subfolder"
	fi
