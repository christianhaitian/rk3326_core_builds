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

	# Libretro mgba build
	if [[ "$var" == "mgba" || "$var" == "all" ]] && [[ "$bitness" == "64" ]]; then
	 gba_rumblepatch="no"
	 cd $cur_wd
	  if [ ! -d "mgba/" ]; then
		git clone https://github.com/libretro/mgba.git
		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the libretro git.  Is Internet active or did the git location change?  Stopping here."
		  exit 1
		 fi
		cp patches/mgba-patch* mgba/.
	  fi

	 cd mgba/
	 
	 mgba_patches=$(find *.patch)
	 
	 if [[ ! -z "$mgba_patches" ]]; then
	  for patching in mgba-patch*
	  do
		 if [[ $patching == *"rumble"* ]]; then
		   echo "Skipping the $patching for now and making a note to apply that later"
		   sleep 3
		   gba_rumblepatch="yes"
		 else  
		   patch -Np1 < "$patching"
		   if [[ $? != "0" ]]; then
			echo " "
			echo "There was an error while applying $patching.  Stopping here."
			exit 1
		   fi
		   rm "$patching" 
		 fi
	  done
	 fi
	  sed -i '/-mcpu=cortex-a35/s//-mtune=cortex-a35/g' Makefile.libretro
	  cmake .
	  make clean
	  make -f Makefile.libretro platform=goadvance -j$(nproc)

	  if [[ $? != "0" ]]; then
		echo " "
		echo "There was an error while building the newest lr-mgba core.  Stopping here."
		exit 1
	  fi

	  strip mgba_libretro.so

	  if [ ! -d "../cores64/" ]; then
		mkdir -v ../cores64
	  fi

	  cp mgba_libretro.so ../cores64/.

	  gitcommit=$(git log | grep -m 1 commit | cut -c -14 | cut -c 8-)
	  echo $gitcommit > ../cores$(getconf LONG_BIT)/$(basename $PWD)_libretro.so.commit

	  if [[ $gba_rumblepatch == "yes" ]]; then
		for patching in mgba-patch*
		do
		  patch -Np1 < "$patching"
		  if [[ $? != "0" ]]; then
			echo " "
			echo "There was an error while patching in the rumble feature from $patching.  Stopping here."
			exit 1
		  fi
		  rm "$patching"
		  make -f Makefile.libretro platform=goadvance -j$(nproc)

		  if [[ $? != "0" ]]; then
			echo " "
			echo "There was an error while building the newest lr-mgba core with the patched in rumble feature.  Stopping here."
			exit 1
		  fi

		  strip mgba_libretro.so
		  mv mgba_libretro.so mgba_rumble_libretro.so
		  cp mgba_rumble_libretro.so ../cores64/.
		  echo " "
		  echo "mgba_libretro.so and mgba_rumble_libretro.so have been created and have been placed in the rk3326_core_builds/cores64 subfolder"
		done
	  fi

	  gitcommit=$(git log | grep -m 1 commit | cut -c -14 | cut -c 8-)
	  echo $gitcommit > ../cores$bitness/mgba_rumble_libretro.so.commit

	  echo " "
	  echo "mgba_libretro.so has been created and has been placed in the rk3326_core_builds/cores64 subfolder"
	fi
