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

	# Libretro hatarib build
	if [[ "$var" == "hatarib" || "$var" == "all" ]] && [[ "$bitness" == "64" ]]; then
	 cd $cur_wd
	  if [ ! -d "hatarib/" ]; then
		git clone --recursive https://github.com/bbbradsmith/hatarib.git
		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the libretro git.  Is Internet active or did the git location change?  Stopping here."
		  exit 1
		 fi
		cp patches/hatarib_patch* hatarib/.
	  fi

	 cd hatarib/
	 
	 hatarib_patches=$(find *.patch)
	 
	 if [[ ! -z "$hatarib_patches" ]]; then
	  for patching in hatarib_patch*
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
	  make full -j$(nproc)

	  if [[ $? != "0" ]]; then
		echo " "
		echo "There was an error while building the newest lr-hatarib core.  Stopping here."
		exit 1
	  fi

	  strip build/hatarib.so

	  if [ ! -d "../cores64/" ]; then
		mkdir -v ../cores64
	  fi

	  cp build/hatarib.so ../cores64/hatarib_libretro.so

	  gitcommit=$(git log | grep -m 1 commit | cut -c -14 | cut -c 8-)
	  echo $gitcommit > ../cores$(getconf LONG_BIT)/hatarib_libretro.so.commit

	  echo " "
	  echo "hatarib_libretro.so has been created and has been placed in the rk3326_core_builds/cores64 subfolder"
	fi
