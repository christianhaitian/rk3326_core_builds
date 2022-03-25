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

	# Libretro a5200 build
	if [[ "$var" == "a5200" || "$var" == "all" ]] && [[ "$bitness" == "64" ]]; then
	 cd $cur_wd
	  if [ ! -d "a5200/" ]; then
		git clone https://github.com/libretro/a5200.git
		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the libretro git.  Is Internet active or did the git location change?  Stopping here."
		  exit 1
		 fi
		cp patches/a5200-patch* a5200/.
	  fi

	 cd a5200/
	 
	 a5200_patches=$(find *.patch)
	 
	 if [[ ! -z "$a5200_patches" ]]; then
	  for patching in a5200-patch*
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
	  sed -i '/a53/s//a35/g' Makefile
	  sed -i '/rpi3/s//rk3326/' Makefile
	  sed -i '/rpi3_64/s//rk3326_64/' Makefile
	  make clean
	  make platform=rk3326_64 -j$(nproc)

	  if [[ $? != "0" ]]; then
		echo " "
		echo "There was an error while building the newest lr-a5200 core.  Stopping here."
		exit 1
	  fi

	  strip a5200_libretro.so

	  if [ ! -d "../cores64/" ]; then
		mkdir -v ../cores64
	  fi

	  cp a5200_libretro.so ../cores64/.

	  gitcommit=$(git log | grep -m 1 commit | cut -c -14 | cut -c 8-)
	  echo $gitcommit > ../cores$(getconf LONG_BIT)/$(basename $PWD)_libretro.so.commit

	  echo " "
	  echo "a5200_libretro.so has been created and has been placed in the rk3326_core_builds/cores64 subfolder"
	fi
