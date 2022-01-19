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

	# Libretro freej2me build
	if [[ "$var" == "freej2me" || "$var" == "all" ]] && [[ "$bitness" == "64" ]]; then
	 cd $cur_wd
	  if [ ! -d "freej2me/" ]; then
		git clone https://github.com/hex007/freej2me.git
		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the hex007/freej2me git.  Is Internet active or did the git location change?  Stopping here."
		  exit 1
		fi
		cp patches/freej2me-patch* freej2me/.
	  fi

	 cd freej2me/
	 
	 freej2me_patches=$(find *.patch)
	 
	  if [[ ! -z "$freej2me_patches" ]]; then
	  for patching in freej2me-patch*
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

      ant #This creates the needed freej2me-lr.jar for this emulator.  It will need to be copied to the bios folder.
	  make -j$(nproc) -C ./src/libretro

	  if [[ $? != "0" ]]; then
		echo " "
		echo "There was an error while building the newest lr-freej2me core.  Stopping here."
		exit 1
	  fi

	  strip src/libretro/freej2me_libretro.so

	  if [ ! -d "../cores64/" ]; then
		mkdir -v ../cores64
	  fi

	  cp src/libretro/freej2me_libretro.so ../cores64/.
	  cp build/freej2me-lr.jar ../cores64/.

	  gitcommit=$(git log | grep -m 1 commit | cut -c -14 | cut -c 8-)
	  echo $gitcommit > ../cores$(getconf LONG_BIT)/$(basename $PWD)_libretro.so.commit

	  echo " "
	  echo "freej2me_libretro.so has been created and has been placed in the rk3326_core_builds/cores64 subfolder"
	fi
