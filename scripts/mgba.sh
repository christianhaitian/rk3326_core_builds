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

	# Libretro mgba build
	if [[ "$var" == "mgba" || "$var" == "all" ]] && [[ "$bitness" == "64" ]]; then
	 gba_rumblepatch="no"
	 cd $cur_wd
	  if [ ! -d "mgba/" ]; then
		git clone https://github.com/libretro/mgba.git
		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the libretro git.  Is Internet active or did the git location change?  Stopping here."
		  exit 1
		 fi
		cp patches/mgba-patch* mgba/.
	  fi

	 cd mgba/
	 
	 mgba_patches=$(find *.patch)
	 
	 if [[ ! -z "$mgba_patches" ]]; then
	  for patching in mgba-patch*
	  do
		 if [[ $patching == *"rumble"* ]]; then
		   echo "Skipping the $patching for now and making a note to apply that later"
		   sleep 3
		   gba_rumblepatch="yes"
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
	  #sed -i '/-mcpu=cortex-a35/s//-mtune=cortex-a35/g' Makefile.libretro
          cmake -DCMAKE_BUILD_TYPE=Release \
                       -DBUILD_LIBRETRO=ON \
                       -DSKIP_LIBRARY=ON \
                       -DBUILD_QT=OFF \
                       -DBUILD_SDL=OFF \
                       -DUSE_DISCORD_RPC=OFF \
                       -DUSE_EDITLINE=OFF \
                       -DUSE_EPOXY=OFF \
                       -DBUILD_GLES3=OFF \
                       -DBUILD_GLES2=ON \
                       -DUSE_MINIZIP=OFF \
                       -DUSE_LIBZIP=OFF \
                       -DUSE_ELF=OFF \
                       -DUSE_LUA=OFF \
                       -DENABLE_DEBUGGERS=OFF \
                       -DENABLE_GDB_STUB=OFF \
                       -DCMAKE_C_FLAGS="-Ofast -fno-tree-slp-vectorize -D_NDEBUG -march=armv8-a+crc -mtune=cortex-a55 -ftree-vectorize -funsafe-math-optimizations" \
                       -DCMAKE_CXX_FLAGS="-Ofast -fno-tree-slp-vectorize -D_NDEBUG -march=armv8-a+crc -mtune=cortex-a55 -ftree-vectorize -funsafe-math-optimizations -fpermissive"
          cmake --build . -- -j$(nproc)

	  if [[ $? != "0" ]]; then
		echo " "
		echo "There was an error while building the newest lr-mgba core.  Stopping here."
		exit 1
	  fi

	  strip mgba_libretro.so

	  if [ ! -d "../cores64/" ]; then
		mkdir -v ../cores64
	  fi

	  cp mgba_libretro.so ../cores64/.
	  cp mgba_libretro.so ../cores64/mgba_rumble_libretro.so

	  gitcommit=$(git log | grep -m 1 commit | cut -c -14 | cut -c 8-)
	  echo $gitcommit > ../cores$(getconf LONG_BIT)/$(basename $PWD)_libretro.so.commit

	  gitcommit=$(git log | grep -m 1 commit | cut -c -14 | cut -c 8-)
	  echo $gitcommit > ../cores$bitness/mgba_rumble_libretro.so.commit

	  echo " "
	  echo "mgba_libretro.so and mgba_rumble_libretro.so has been created and has been placed in the rk3326_core_builds/cores64 subfolder"
	fi
