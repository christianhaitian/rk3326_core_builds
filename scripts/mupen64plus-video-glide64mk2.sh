#!/bin/bash

##################################################################
# Created by Christian Haitian for use to easily update          #
# various standalone emulators, libretro cores, and other        #
# various programs for the RK3326 platform for various Linux     #
# based distributions.                                           #
# See the LICENSE.md file at the top-level directory of this     #
# repository.                                                    #
##################################################################

	  # Now we'll start the clone and build of mupen64plus-video-glide64mk2
	  if [ ! -d "mupen64plus-video-glide64mk2/" ]; then
		git clone --depth=1 https://github.com/mupen64plus/mupen64plus-video-glide64mk2.git
		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the mupen64plus-video-glide64mk2 standalone git.  Is Internet active or did the git location change?  Stopping here."
		  exit 1
		fi
		cp patches/mupen64plus-video-glide64mk2-patch* mupen64plus-video-glide64mk2/.
	  else
		echo " "
		echo "A mupen64plus-video-glide64mk2 subfolder already exists.  Stopping here to not impact anything in the folder that may be needed.  If not needed, please remove the mupen64plus-video-glide64mk2 folder and rerun this script."
		echo " "
		exit 1
	  fi

	 cd mupen64plus-video-glide64mk2
	 
	 mupen64plus_core_patches=$(find *.patch)
	 
	 if [[ ! -z "$mupen64plus_core_patches" ]]; then
	  for patching in mupen64plus-video-glide64mk2-patch*
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
        _opts='USE_GLES=1 NEON=1 VFP_HARD=1 OPTFLAGS="-O3" V=1 PIE=1'
      else
        _opts='USE_GLES=1 NEW_DYNAREC=1 OPTFLAGS="-O3" V=1 PIE=1'
      fi
      
      export CFLAGS="-mtune=cortex-a35 -fuse-linker-plugin"
      export CXXFLAGS="$CFLAGS"
      export LDFLAGS="$CFLAGS"
      
      make -C "projects/unix" clean
	  make -j$(nproc) -C "projects/unix" $_opts all

	  if [[ $? != "0" ]]; then
		echo " "
		echo "There was an error while building the newest mupen64plus-video-glide64mk2 standalone.  Stopping here."
		exit 1
	  fi

	  strip projects/unix/mupen64plus-video-glide64mk2.so

	  if [ ! -d "../mupen64plussa-$bitness/" ]; then
		mkdir -v ../mupen64plussa-$bitness
	  fi

	  cp projects/unix/mupen64plus-video-glide64mk2.so ../mupen64plussa-$bitness/.
	  
	  echo " "
	  echo "mupen64plus-video-glide64mk2 executable has been placed in the rk3326_core_builds/mupen64plussa-$bitness subfolder"

