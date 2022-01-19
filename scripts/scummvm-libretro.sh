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

	# Libretro scummvm build
	if [[ "$var" == "scummvm-libretro" || "$var" == "all" ]] && [[ "$bitness" == "64" ]]; then
	 cd $cur_wd
	  if [ ! -d "scummvm/" ]; then
		git clone https://github.com/libretro/scummvm.git
		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the libretro git.  Is Internet active or did the git location change?  Stopping here."
		  exit 1
		 fi
		cp patches/scummvm-patch* scummvm/.
	  fi

	 cd scummvm/
	 
	 scummvm_patches=$(find *.patch)
	 
	 if [[ ! -z "$scummvm_patches" ]]; then
	  for patching in scummvm-patch*
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
	  sed -i '/a53/s//a35/' backends/platform/libretro/build/Makefile
	  sed -i '/rpi3_64/s//rk3326/' backends/platform/libretro/build/Makefile
	  make -C backends/platform/libretro/build platform=rk3326 CXXFLAGS="$CXXFLAGS -DHAVE_POSIX_MEMALIGN=1" -j$(nproc)

	  if [[ $? != "0" ]]; then
		echo " "
		echo "There was an error while building the newest lr-scummvm core.  Stopping here."
		exit 1
	  fi

	  strip backends/platform/libretro/build/scummvm_libretro.so

	  if [ ! -d "../cores64/" ]; then
		mkdir -v ../cores64
	  fi

	  cp backends/platform/libretro/build/scummvm_libretro.so ../cores64/.

	  gitcommit=$(git log | grep -m 1 commit | cut -c -14 | cut -c 8-)
	  echo $gitcommit > ../cores$(getconf LONG_BIT)/$(basename $PWD)_libretro.so.commit

	  echo " "
	  echo "scummvm_libretro.so has been created and has been placed in the rk3326_core_builds/cores64 subfolder"
	fi
