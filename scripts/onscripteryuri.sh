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

	# Libretro onscripteryuri build
	if [[ "$var" == "onscripteryuri" || "$var" == "all" ]] && [[ "$bitness" == "64" ]]; then
	 cd $cur_wd
	  if [ ! -d "onscripteryuri/" ]; then
		git clone --recursive https://github.com/YuriSizuku/OnscripterYuri onscripteryuri
		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the iyzsong/onscripteryuri git.  Is Internet active or did the git location change?  Stopping here."
		  exit 1
		fi
		cp patches/onscripteryuri-patch* onscripteryuri/.
	  fi

	 cd onscripteryuri/
	 
	 onscripteryuri_patches=$(find *.patch)
	 
	  if [[ ! -z "$onscripteryuri_patches" ]]; then
	  for patching in onscripteryuri-patch*
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

	  mkdir build
	  cd build
	  cmake ../src/onsyuri_libretro/ -DCMAKE_BUILD_TYPE=Release
	  make -j$(nproc)

	  if [[ $? != "0" ]]; then
		echo " "
		echo "There was an error while building the newest lr-onscripteryuri core.  Stopping here."
		exit 1
	  fi

	  strip onsyuri_libretro.so

	  if [ ! -d "../../cores64/" ]; then
		mkdir -v ../../cores64
	  fi

	  cp onsyuri_libretro.so ../../cores64/.

	  gitcommit=$(git log | grep -m 1 commit | cut -c -14 | cut -c 8-)
	  echo $gitcommit > ../../cores$(getconf LONG_BIT)/$(basename $PWD)_libretro.so.commit

	  echo " "
	  echo "onsyuri_libretro.so has been created and has been placed in the rk3326_core_builds/cores64 subfolder"
	fi
