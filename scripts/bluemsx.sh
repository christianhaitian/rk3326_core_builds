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

	# Libretro blueMSX build
	if [[ "$var" == "bluemsx" || "$var" == "all" ]] && [[ "$bitness" == "64" ]]; then
	 cd $cur_wd
	  if [ ! -d "blueMSX-libretro/" ]; then
		git clone https://github.com/libretro/blueMSX-libretro.git
		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the libretro git.  Is Internet active or did the git location change?  Stopping here."
		  exit 1
		 fi
		cp patches/bluemsx-patch* blueMSX-libretro/.
	  fi

	 cd blueMSX-libretro/
	 
	 bluemsx_patches=$(find *.patch)
	 
	 if [[ ! -z "$bluemsx_patches" ]]; then
	  for patching in bluemsx-patch*
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
	  make -f Makefile.libretro -j$(($(nproc) - 1))

	  if [[ $? != "0" ]]; then
		echo " "
		echo "There was an error while building the newest lr-blueMSX core.  Stopping here."
		exit 1
	  fi

	  strip bluemsx_libretro.so

	  if [ ! -d "../cores64/" ]; then
		mkdir -v ../cores64
	  fi

	  cp bluemsx_libretro.so ../cores64/.

	  gitcommit=$(git log | grep -m 1 commit | cut -c -14 | cut -c 8-)
	  echo $gitcommit > ../cores$(getconf LONG_BIT)/bluemsx_libretro.so.commit

	  echo " "
	  echo "bluemsx_libretro.so has been created and has been placed in the rk3326_core_builds/cores64 subfolder"
	fi
