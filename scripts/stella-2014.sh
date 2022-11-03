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

	# Libretro stella-2014 build
	if [[ "$var" == "stella-2014" || "$var" == "all" ]] && [[ "$bitness" == "64" ]]; then
	 cd $cur_wd
	  if [ ! -d "stella-2014/" ]; then
		git clone --recursive https://github.com/libretro/stella2014-libretro.git
		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the libretro git.  Is Internet active or did the git location change?  Stopping here."
		  exit 1
		 fi
		cp patches/stella2014-patch* stella2014-libretro/.
	  fi

	 cd stella2014-libretro/
	 
	 stella2014_patches=$(find *.patch)
	 
	 if [[ ! -z "$stella2014_patches" ]]; then
	  for patching in stella2014-patch*
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
	  make -C . platform=emuelec-arm64 -j$(nproc)

	  if [[ $? != "0" ]]; then
		echo " "
		echo "There was an error while building the newest lr-stella2014 core.  Stopping here."
		exit 1
	  fi

	  strip stella2014_libretro.so

	  if [ ! -d "../cores64/" ]; then
		mkdir -v ../cores64
	  fi

	  cp stella2014_libretro.so ../cores64/.

	  gitcommit=$(git log | grep -m 1 commit | cut -c -14 | cut -c 8-)
	  echo $gitcommit > ../cores$(getconf LONG_BIT)/stella2014_libretro.so.commit

	  echo " "
	  echo "stella2014_libretro.so has been created and has been placed in the rk3326_core_builds/cores64 subfolder"
	fi
