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

	# Libretro supafaust build
	if [[ "$var" == "supafaust" || "$var" == "all" ]] && [[ "$bitness" == "64" ]]; then
	 cd $cur_wd
	  if [ ! -d "supafaust/" ]; then
		git clone https://github.com/libretro/supafaust.git
		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the libretro git.  Is Internet active or did the git location change?  Stopping here."
		  exit 1
		 fi
		cp patches/supafaust-patch* supafaust/.
	  fi

	 cd supafaust/
	 
	 supafaust_patches=$(find *.patch)
	 
	 if [[ ! -z "$supafaust_patches" ]]; then
	  for patching in supafaust-patch*
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
	  make platform=goadvance -j$(nproc)

	  if [[ $? != "0" ]]; then
		echo " "
		echo "There was an error while building the newest lr-supafaust core.  Stopping here."
		exit 1
	  fi

	  strip mednafen_supafaust_libretro.so

	  if [ ! -d "../cores64/" ]; then
		mkdir -v ../cores64
	  fi

	  cp mednafen_supafaust_libretro.so ../cores64/.

	  gitcommit=$(git log | grep -m 1 commit | cut -c -14 | cut -c 8-)
	  echo $gitcommit > ../cores$(getconf LONG_BIT)/mednafen_$(basename $PWD)_libretro.so.commit

	  echo " "
	  echo "supafaust_libretro.so has been created and has been placed in the rk3326_core_builds/cores64 subfolder"
	fi
