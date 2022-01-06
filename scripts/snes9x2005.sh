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

	# Libretro snes9x2005 build
	if [[ "$var" == "snes9x2005" || "$var" == "all" ]]; then
	 cd $cur_wd
	  if [ ! -d "snes9x2005/" ]; then
		git clone https://github.com/libretro/snes9x2005.git
		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the libretro git.  Is Internet active or did the git location change?  Stopping here."
		  exit 1
		 fi
		cp patches/snes9x2005-patch* snes9x2005/.
	  fi

	 cd snes9x2005/
	 
	 snes9x2005_patches=$(find *.patch)
	 
	 if [[ ! -z "$snes9x2005_patches" ]]; then
	  for patching in snes9x2005-patch*
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
	  make -j$(($(nproc) - 1))

	  if [[ $? != "0" ]]; then
		echo " "
		echo "There was an error while building the newest lr-snes9x2005 core.  Stopping here."
		exit 1
	  fi

	  strip snes9x2005_libretro.so

	  if [ ! -d "../cores$(getconf LONG_BIT)/" ]; then
		mkdir -v ../cores$(getconf LONG_BIT)
	  fi

	  cp snes9x2005_libretro.so ../cores$(getconf LONG_BIT)/.

	  gitcommit=$(git log | grep -m 1 commit | cut -c -14 | cut -c 8-)
	  echo $gitcommit > ../cores$(getconf LONG_BIT)/snes9x2005_libretro.so.commit

	  echo " "
	  echo "snes9x2005_libretro.so has been created and has been placed in the rk3326_core_builds/cores$(getconf LONG_BIT) subfolder"
	fi
