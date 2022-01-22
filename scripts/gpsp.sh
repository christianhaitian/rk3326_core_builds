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

	# Libretro gpsp build
	if [[ "$var" == "gpsp" || "$var" == "all" ]]; then
	 cd $cur_wd
	  if [ ! -d "gpsp/" ]; then
		git clone --recursive https://github.com/libretro/gpsp.git
		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the libretro git.  Is Internet active or did the git location change?  Stopping here."
		  exit 1
		 fi
		cp patches/gpsp-patch* gpsp/.
	  fi

	 cd gpsp/
	 
	 gpsp_patches=$(find *.patch)
	 
	 if [[ ! -z "$gpsp_patches" ]]; then
	  for patching in gpsp-patch*
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
		make platform=arm64 -j$(nproc)
	  else
		make platform=goadvance -j$(nproc)
	  fi

	  if [[ $? != "0" ]]; then
		echo " "
		echo "There was an error while building the newest lr-gpsp core.  Stopping here."
		exit 1
	  fi

	  strip gpsp_libretro.so

	  if [ ! -d "../cores$bitness/" ]; then
		mkdir -v ../cores$bitness
	  fi

	  cp gpsp_libretro.so ../cores$bitness/.

	  gitcommit=$(git log | grep -m 1 commit | cut -c -14 | cut -c 8-)
	  echo $gitcommit > ../cores$bitness/$(basename $PWD)_libretro.so.commit

	  echo " "
	  echo "gpsp_libretro.so has been created and has been placed in the rk3326_core_builds/cores$bitness subfolder"
	fi
