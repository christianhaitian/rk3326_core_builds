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

	# Libretro yabasanshiro build
	if [[ "$var" == "yabasanshiro" || "$var" == "all" ]]; then
	 cd $cur_wd
	  if [ ! -d "yabasanshiro/" ]; then
		git clone --recursive https://github.com/zhangmq/yabasanshiro-pirry.git yabasanshiro
		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the yabasanshiro libretro git.  Is Internet active or did the git location change?  Stopping here."
		  exit 1
		fi
		cp patches/yabasanshiro-patch* yabasanshio/.
	  fi

	 cd yabasanshiro/
	 
	 yabasanshiro_patches=$(find *.patch)
	 
	 if [[ ! -z "$yabasanshiro_patches" ]]; then
	  for patching in yabasanshiro-patch*
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

	  sed -i 's|/lib/libEGL\.so\.1|libEGL.so.1|g' yabause/src/libretro/CMakeLists.txt
	  sed -i 's|/lib/libmali\.so\.0|libmali.so.1|g' yabause/src/libretro/CMakeLists.txt
	  ROOT=$PWD; DEPS=$ROOT/deps; BUILD=$ROOT/build-libretro
	  mkdir -p "$DEPS"

	  git clone https://github.com/devmiyax/libchdr "$DEPS/libchdr"
	  git -C "$DEPS/libchdr" checkout 074ff16
	  git clone https://github.com/madler/zlib "$DEPS/zlib"
	  git -C "$DEPS/zlib" checkout 5089329
	  mkdir -p "$DEPS/musashi" "$BUILD/.tools"
	  cc -O2 -o "$BUILD/.tools/m68kmake" yabause/src/musashi/m68kmake.c
	  "$BUILD/.tools/m68kmake" "$DEPS/musashi/" yabause/src/musashi/m68k_in.c
	  CMAKE_POLICY_VERSION_MINIMUM=3.5 cmake -S yabause/src/libretro -B "$BUILD" \
	      -DCMAKE_BUILD_TYPE=Release \
	      -DYAB_DEPS_CACHE="$DEPS" \
	      -DH700_DEPS="/lib/aarch64-linux-gnu/" \
	      -DCMAKE_C_FLAGS="-mcpu=cortex-a35" \
	      -DCMAKE_CXX_FLAGS="-mcpu=cortex-a35"

	  cmake --build "$BUILD" -j"$(nproc)"

	  if [[ $? != "0" ]]; then
		echo " "
		echo "There was an error while building the newest lr-yabasanshiro core.  Stopping here."
		exit 1
	  fi

	  strip $BUILD/yabasanshiro_libretro.so

	  if [ ! -d "../cores$bitness/" ]; then
		mkdir -v ../cores$bitness
	  fi

	  cp $BUILD/yabasanshiro_libretro.so ../cores$bitness/.

	  gitcommit=$(git log | grep -m 1 commit | cut -c -14 | cut -c 8-)
	  echo $gitcommit > ../cores$bitness/yabasanshiro_libretro.so.commit

	  echo " "
	  echo "yabasanshiro_libretro.so has been created and has been placed in the rk3326_core_builds/cores$bitness subfolder"
	fi
