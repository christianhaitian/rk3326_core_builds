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

	# Libretro fbneo build
	if [[ "$var" == "fbneo" || "$var" == "all" ]] && [[ "$bitness" == "64" ]]; then
	 cd $cur_wd
	  if [ ! -d "fbneo/" ]; then
		git clone https://github.com/libretro/fbneo.git
		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the libretro git.  Is Internet active or did the git location change?  Stopping here."
		  exit 1
		fi
		cp patches/fbneo-patch* fbneo/.
	  fi

	 cd fbneo/
	 
	 fbneo_patches=$(find *.patch)
	 
	  if [[ ! -z "$fbneo_patches" ]]; then
	  for patching in fbneo-patch*
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
	 
	  make -C ./src/burner/libretro clean
	  make -j$(nproc) -C ./src/burner/libretro USE_CYCLONE=0 profile=performance

	  if [[ $? != "0" ]]; then
		echo " "
		echo "There was an error while building the newest lr-fbneo core.  Stopping here."
		exit 1
	  fi

	  strip src/burner/libretro/fbneo_libretro.so

	  if [ ! -d "../cores64/" ]; then
		mkdir -v ../cores64
	  fi

	  cp src/burner/libretro/fbneo_libretro.so ../cores64/.

	  gitcommit=$(git log | grep -m 1 commit | cut -c -14 | cut -c 8-)
	  echo $gitcommit > ../cores$(getconf LONG_BIT)/$(basename $PWD)_libretro.so.commit

	  echo " "
	  echo "fbneo_libretro.so has been created and has been placed in the rk3326_core_builds/cores64 subfolder"
	fi
