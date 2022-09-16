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

	# Libretro mesen build
	if [[ "$var" == "mesen" || "$var" == "all" ]] && [[ "$bitness" == "64" ]]; then
	 cd $cur_wd
	  if [ ! -d "mesen/" ]; then
		git clone https://github.com/libretro/mesen.git
		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the libretro git.  Is Internet active or did the git location change?  Stopping here."
		  exit 1
		 fi
		cp patches/mesen-patch* mesen/.
	  fi

	 cd mesen/
	 
	 mesen_patches=$(find *.patch)
	 
	 if [[ ! -z "$mesen_patches" ]]; then
	  for patching in mesen-patch*
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

      export CFLAGS="-O2 -march=armv8-a+crc -mtune=cortex-a35 -ftree-vectorize -funsafe-math-optimizations"
      export CXXFLAGS="$CXXFLAGS $CFLAGS"
      export LDFLAGS="$CFLAGS"
	  make clean
	  make -C Libretro/ -j$(nproc)

	  if [[ $? != "0" ]]; then
		echo " "
		echo "There was an error while building the newest lr-mesen core.  Stopping here."
		exit 1
	  fi

	  strip Libretro/mesen_libretro.so

	  if [ ! -d "../cores64/" ]; then
		mkdir -v ../cores64
	  fi

	  cp Libretro/mesen_libretro.so ../cores64/.

	  gitcommit=$(git log | grep -m 1 commit | cut -c -14 | cut -c 8-)
	  echo $gitcommit > ../cores$(getconf LONG_BIT)/mesen_libretro.so.commit

	  echo " "
	  echo "mesen_libretro.so has been created and has been placed in the rk3326_core_builds/cores64 subfolder"
	fi
