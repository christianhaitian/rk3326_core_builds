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

	# Libretro picodrive build
	if [[ "$var" == "picodrive" || "$var" == "all" ]]; then
	 cd $cur_wd
	  if [ ! -d "picodrive/" ]; then
		git clone --recursive https://github.com/libretro/picodrive.git
		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the libretro git.  Is Internet active or did the git location change?  Stopping here."
		  exit 1
		 fi
		cp patches/picodrive-patch* picodrive/.
	  fi

	 cd picodrive/
	 
	 picodrive_patches=$(find *.patch)
	 
	 if [[ ! -z "$picodrive_patches" ]]; then
	  for patching in picodrive-patch*
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
      ./configure
	  if [[ "$(getconf LONG_BIT)" == "64" ]]; then
		make -f Makefile.libretro platform=arm64 -j$(nproc)
	  else
		make -f Makefile.libretro platform=armv6 -j$(nproc)
	  fi

	  if [[ $? != "0" ]]; then
		echo " "
		echo "There was an error while building the newest lr-picodrive core.  Stopping here."
		exit 1
	  fi

	  strip picodrive_libretro.so

	  if [ ! -d "../cores$(getconf LONG_BIT)/" ]; then
		mkdir -v ../cores$(getconf LONG_BIT)
	  fi

	  cp picodrive_libretro.so ../cores$(getconf LONG_BIT)/.

	  gitcommit=$(git log | grep -m 1 commit | cut -c -14 | cut -c 8-)
	  echo $gitcommit > ../cores$(getconf LONG_BIT)/$(basename $PWD)_libretro.so.commit

	  echo " "
	  echo "picodrive_libretro.so has been created and has been placed in the rk3326_core_builds/cores$(getconf LONG_BIT) subfolder"
	fi
