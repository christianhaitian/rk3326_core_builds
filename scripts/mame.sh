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

	# Libretro mame build
	if [[ "$var" == "mame" || "$var" == "all" ]] && [[ "$bitness" == "64" ]]; then
	 cd $cur_wd
	  if [ ! -d "mame/" ]; then
		git clone https://github.com/libretro/mame.git
		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the libretro git.  Is Internet active or did the git location change?  Stopping here."
		  exit 1
		 fi
		cp patches/mame-patch* mame/.
	  fi

	 cd mame/
	 
	 mame_patches=$(find *.patch)
	 
	 if [[ ! -z "$mame_patches" ]]; then
	  for patching in mame-patch*
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

      fallocate -l 4G /swapfile1
      chmod 600 /swapfile1
      mkswap /swapfile1
      swapon /swapfile1

	  make -f Makefile.libretro clean
      params=(OSD=retro RETRO=1 NOWERROR=1 OS=linux TARGETOS=linux CONFIG=libretro NO_USE_MIDI=1 TARGET=mame SUBTARGET=arcade PYTHON_EXECUTABLE=python3 PTR64=1)
	  make ${params[@]} -f Makefile.libretro -j5

	  if [[ $? != "0" ]]; then
        swapoff -v /swapfile1
        rm /swapfile1
		echo " "
		echo "There was an error while building the newest lr-mame core.  Stopping here."
		exit 1
	  fi

      swapoff -v /swapfile1
      rm /swapfile1
      
	  strip mamearcade_libretro.so

	  if [ ! -d "../cores$(getconf LONG_BIT)/" ]; then
		mkdir -v ../cores$(getconf LONG_BIT)
	  fi

	  cp mamearcade_libretro.so ../cores$(getconf LONG_BIT)/mame_libretro.so

	  gitcommit=$(git log | grep -m 1 commit | cut -c -14 | cut -c 8-)
	  echo $gitcommit > ../cores$(getconf LONG_BIT)/mame_libretro.so.commit

	  echo " "
	  echo "mame_libretro.so has been created and has been placed in the rk3326_core_builds/cores$(getconf LONG_BIT) subfolder"
	fi
