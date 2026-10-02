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

	# Libretro zeebx build
	if [[ "$var" == "zeebx-lr" || "$var" == "all" ]] && [[ "$bitness" == "64" ]]; then
	 cd $cur_wd
	  if [ ! -d "zeebx-emu/" ]; then
		git clone --depth=1 --recursive https://github.com/NextOs-Ports/zeebx-nextos.git -b mali450-gles2 zeebx-emu
		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the libretro git.  Is Internet active or did the git location change?  Stopping here."
		  exit 1
		 fi
		cp patches/zeebxemu-patch* zeebx-emu/.
	  fi

	 cd zeebx-emu/
	 
	 zeebx_patches=$(find *.patch)
	 
	 if [[ ! -z "$zeebx_patches" ]]; then
	  for patching in zeebxsdk-patch*
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

	  export CMAKE_GENERATOR=Ninja
	  export CARGO_PROFILE_RELEASE_DEBUG=0
	  export RUSTFLAGS="-C target-cpu=cortex-a35 -C force-frame-pointers=yes"
	  cargo build --release --locked -p zeebx-libretro

	  if [[ $? != "0" ]]; then
		echo " "
		echo "There was an error while building the newest lr-zeebx core.  Stopping here."
		exit 1
	  fi

	  strip target/release/libzeebx_libretro.so

	  if [ ! -d "../cores64/" ]; then
		mkdir -v ../cores64
	  fi

	  cp target/release/libzeebx_libretro.so ../cores64/zeebx_libretro.so

	  gitcommit=$(git log | grep -m 1 commit | cut -c -14 | cut -c 8-)
	  echo $gitcommit > ../cores$(getconf LONG_BIT)/zeebx_libretro.so.commit

	  echo " "
	  echo "libzeebx_libretro.so has been created and has been placed in the rk3326_core_builds/cores64 subfolder"
	fi
