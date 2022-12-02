#!/bin/bash

##################################################################
# Created by Christian Haitian for use to easily update          #
# various standalone emulators, libretro cores, and other        #
# various programs for the RK3326 platform for various Linux     #
# based distributions.                                           #
# See the LICENSE.md file at the top-level directory of this     #
# repository.                                                    #
##################################################################

	  # Now we'll start the clone and build of mupen64plus-video-gliden64
	  if [ ! -d "mupen64plus-video-gliden64/" ]; then
		git clone --recursive https://github.com/gonetz/GLideN64.git mupen64plus-video-GlideN64
		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the mupen64plus-video-gliden64 standalone git.  Is Internet active or did the git location change?  Stopping here."
		  exit 1
		fi
		cp patches/mupen64plus-video-gliden64-patch* mupen64plus-video-GlideN64/.
	  else
		echo " "
		echo "A mupen64plus-video-gliden64 subfolder already exists.  Stopping here to not impact anything in the folder that may be needed.  If not needed, please remove the mupen64plus-video-gliden64 folder and rerun this script."
		echo " "
		exit 1
	  fi

	 cd mupen64plus-video-GlideN64

	 mupen64plus_core_patches=$(find *.patch)
	 
	 if [[ ! -z "$mupen64plus_core_patches" ]]; then
	  for patching in mupen64plus-video-gliden64-patch*
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

      if [[ "$bitness" == "32" ]]; then
        _opts='USE_GLES=1 NEON=1 VFP_HARD=1 OPTFLAGS="-O3" V=1 VC=0 PIE=1'
      else
        _opts='USE_GLES=1 V=1 VC=0 -Wno-unused-variable'
      fi
      
      export CFLAGS="-mtune=cortex-a35 -fuse-linker-plugin"
      export CXXFLAGS="$CFLAGS"
      export LDFLAGS="$CFLAGS"
      
      ./src/getRevision.sh
      cmake -DNOHQ=On -DCRC_ARMV8=On -DEGL=0n -DNEON_OPT=On -DMUPENPLUSAPI=On -DCMAKE_CXX_FLAGS:STRING=" -march=armv8-a+crc -mtune=cortex-a35 -fuse-linker-plugin" -S src -B projects/cmake
      make -C "projects/cmake" clean
	  make -j$(nproc) -C "projects/cmake" $_opts all

	  if [[ $? != "0" ]]; then
		echo " "
		echo "There was an error while building the newest mupen64plus-video-gliden64 standalone.  Stopping here."
		exit 1
	  fi

	  strip projects/cmake/plugin/Release/mupen64plus-video-GLideN64.so

	  if [ ! -d "../mupen64plussa-$bitness/" ]; then
		mkdir -v ../mupen64plussa-$bitness
	  fi

	  cp projects/cmake/plugin/Release/mupen64plus-video-GLideN64.so ../mupen64plussa-$bitness/.
	  
	  echo " "
	  echo "mupen64plus-video-gliden64 executable has been placed in the rk3326_core_builds/mupen64plussa-$bitness subfolder"

