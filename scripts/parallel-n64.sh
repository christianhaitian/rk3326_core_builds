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

	# Libretro Parallel-n64 build
	if [[ "$var" == "parallel-n64" || "$var" == "all" ]]; then
	 cd $cur_wd
	  if [ ! -d "parallel-n64/" ]; then
		git clone https://github.com/libretro/parallel-n64.git
		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the parallel-n64 libretro git.  Is Internet active or did the git location change?  Stopping here."
		  exit 1
		fi
		cp patches/parallel-n64-patch* parallel-n64/.
	  fi

	 cd parallel-n64/
	 
	 paralleln64_patches=$(find *.patch)
	 
	 if [[ ! -z "$paralleln64_patches" ]]; then
	  for patching in parallel-n64-patch*
	  do
		 if [[ $patching == *"target64"* ]] && [[ "$bitness" == "32" ]]; then
		   echo "Skipping the $patching as it breaks 32 bit building for this core"
		   sleep 3
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
	  make clean
	  if [[ "$bitness" == "32" ]]; then
		make platform=Odroidgoa -lto -j$(($(nproc) - 1))
	  else
		make platform=emuelec64-armv8 -lto -j$(($(nproc) - 1))
	  fi

	  if [[ $? != "0" ]]; then
		echo " "
		echo "There was an error while building the newest lr-parallel-n64 core.  Stopping here."
		exit 1
	  fi

	  strip parallel_n64_libretro.so

	  if [ ! -d "../cores$bitness/" ]; then
		mkdir -v ../cores$bitness
	  fi

	  cp parallel_n64_libretro.so ../cores$bitness/.

	  gitcommit=$(git log | grep -m 1 commit | cut -c -14 | cut -c 8-)
	  echo $gitcommit > ../cores$bitness/parallel_n64_libretro.so.commit

	  echo " "
	  echo "parallel_n64_libretro.so has been created and has been placed in the rk3326_core_builds/cores$bitness subfolder"
	fi
