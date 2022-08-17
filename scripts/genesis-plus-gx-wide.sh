#!/bin/bash

##################################################################
# Created by Christian Haitian for use to easily update          #
# various standalone emulators, libretro cores, and other        #
# various programs for the RK3566 platform for various Linux     #
# based distributions.                                           #
# See the LICENSE.md file at the top-level directory of this     #
# repository.                                                    #
##################################################################

cur_wd="$PWD"
bitness="$(getconf LONG_BIT)"

	# Libretro genesis-plus-gx-wide build
	if [[ "$var" == "genesis-plus-gx-wide" || "$var" == "all" ]] && [[ "$bitness" == "64" ]]; then
	 cd $cur_wd
	  if [ ! -d "genesis-plus-gx-wide-libretro/" ]; then
		git clone https://github.com/libretro/genesis-plus-gx-wide.git
		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the libretro git.  Is Internet active or did the git location change?  Stopping here."
		  exit 1
		 fi
		cp patches/genesis-plus-gx-wide-patch* genesis-plus-gx-wide/.
	  fi

	 cd genesis-plus-gx-wide/
	 
	 genesis_plus_gx_patches=$(find *.patch)
	 
	 if [[ ! -z "$genesis_plus_gx_patches" ]]; then
	  for patching in genesis-plus-gx-wide-patch*
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
	  make -f Makefile.libretro -j$(nproc)

	  if [[ $? != "0" ]]; then
		echo " "
		echo "There was an error while building the newest lr-genesis-plus-gx-wide core.  Stopping here."
		exit 1
	  fi

	  strip genesis_plus_gx_wide_libretro.so

	  if [ ! -d "../cores64/" ]; then
		mkdir -v ../cores64
	  fi

	  cp genesis_plus_gx_wide_libretro.so ../cores64/.

	  gitcommit=$(git log | grep -m 1 commit | cut -c -14 | cut -c 8-)
	  echo $gitcommit > ../cores$(getconf LONG_BIT)/genesis_plus_gx_wide_libretro.so.commit

	  echo " "
	  echo "genesis_plus_gx_wide_libretro.so has been created and has been placed in the rk3566_core_builds/cores64 subfolder"
	fi
