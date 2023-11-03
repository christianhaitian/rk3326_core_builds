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

	# Libretro pce_fast build
	if [[ "$var" == "pce_fast" || "$var" == "all" ]]; then
	 cd $cur_wd
	  if [ ! -d "beetle-pce-fast-libretro/" ]; then
		git clone https://github.com/libretro/beetle-pce-fast-libretro.git
		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the libretro git.  Is Internet active or did the git location change?  Stopping here."
		  exit 1
		 fi
		cp patches/pce_fast-patch* beetle-pce-fast-libretro/.
	  fi

	 cd beetle-pce-fast-libretro/
	 
	 pce_fast_patches=$(find *.patch)
	 
	 if [[ ! -z "$pce_fast_patches" ]]; then
	  for patching in pce_fast-patch*
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
        make -j$(nproc)
      else
	    make platform=classic_armv8_a35 -j$(nproc)
	  fi

	  if [[ $? != "0" ]]; then
		echo " "
		echo "There was an error while building the newest lr-pce_fast core.  Stopping here."
		exit 1
	  fi

	  strip mednafen_pce_fast_libretro.so

	  if [ ! -d "../cores${bitness}/" ]; then
		mkdir -v ../cores${bitness}
	  fi

	  cp mednafen_pce_fast_libretro.so ../cores${bitness}/.

	  gitcommit=$(git log | grep -m 1 commit | cut -c -14 | cut -c 8-)
	  echo $gitcommit > ../cores$(getconf LONG_BIT)/mednafen_pce_fast_libretro.so.commit

	  echo " "
	  echo "mednafen_pce_fast_libretro.so has been created and has been placed in the rk3326_core_builds/cores${bitness} subfolder"
	fi
