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
branch="sdl2-backend"
extension="0.5.0"

if [[ $bitness == "32" ]]; then
  INSTALL_FOLDER="/usr/lib/arm-linux-gnueabihf"
else
  INSTALL_FOLDER="/usr/lib/aarch64-linux-gnu"
fi
	# sdl3 Standalone Build
	if [[ "$var" == "sdl3" ]]; then
	 cd $cur_wd

	  # Now we'll start the clone and build process of sdl3
	  if [ ! -d "SDL3/" ]; then
		git clone --recursive https://github.com/bmdhacks/SDL.git -b "$branch" SDL3
		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the sdl3 standalone git.  Is Internet active or did the git location change?  Stopping here."
		  exit 1
		fi
		cp patches/sdl3-patch* SDL3/.
	  else
		echo " "
		echo "A sdl3 subfolder already exists.  Stopping here to not impact anything in the folder that may be needed.  If not needed, please remove the sdl3 folder and rerun this script."
		echo " "
		exit 1
	  fi

	 cd SDL3
	 git clone https://github.com/KhronosGroup/SPIRV-Cross.git

	 sdl3_patches=$(find *.patch)
	 
	 if [[ ! -z "$sdl3_patches" ]]; then
	  for patching in sdl3-patch*
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

     #sed -i "s| -lrga||g" CMakeLists.txt

        #if [[ $bitness == "32" ]]; then
        # ./autogen.sh
        # ./configure --host=arm-linux-gnueabihf \
        # --enable-video-kmsdrm \
        # --disable-video-x11 \
        # --disable-video-rpi \
        # --disable-video-wayland \
        # --disable-video-vulkan
       #else
         mkdir build
         cd build
         cmake .. \
               -DCMAKE_BUILD_TYPE=Release \
               -DCMAKE_C_FLAGS="-mcpu=cortex-a55" \
               -DSDL_SDL2_BACKEND=ON \
               -DSDL_SPIRV_CROSS_DIR=../SPIRV-Cross \
               -DSDL_X11=OFF \
               -DSDL_WAYLAND=OFF \
               -DSDL_KMSDRM=OFF \
               -DSDL_PIPEWIRE=OFF \
               -DSDL_PULSEAUDIO=OFF \
               -DSDL_ALSA=OFF \
               -DSDL_SNDIO=OFF \
               -DSDL_OSS=OFF \
               -DSDL_JACK=OFF \
               -DSDL_OFFSCREEN=OFF \
               -DSDL_DUMMYVIDEO=OFF \
               -DSDL_DUMMYAUDIO=OFF \
               -DSDL_DISKAUDIO=OFF \
               -DSDL_VULKAN=OFF \
               -DSDL_GPU=ON \
               -DSDL_RENDER_GPU=ON \
               -DSDL_UNIX_CONSOLE_BUILD=ON
          export LDFLAGS="${LDFLAGS} -lrga"
       #fi

	  make -j$(nproc)
	  #make install

	  if [[ $? != "0" ]]; then
		echo " "
		echo "There was an error while building sdl3 at commit $commit.  Stopping here."
		exit 1
	  fi

      #if [[ $bitness == "32" ]]; then
	  #   strip build/.libs/libsdl3-2.0.so.0.*
	  #else
	     strip libSDL3.so.${extension}
	  #fi

	  if [ ! -d "$cur_wd/sdl3-$bitness/" ]; then
		mkdir -v $cur_wd/sdl3-$bitness
	  fi

      #if [[ $bitness == "32" ]]; then
	  #   cp build/.libs/libsdl3-2.0.so.0.* $cur_wd/sdl3-$bitness/.
	  #else
	     cp libSDL3.so.${extension} $cur_wd/sdl3-$bitness/.
	  #fi

	  echo " "
	  echo "sdl $(git describe --tags | cut -c 9-) has been created and has been placed in the rk3566_core_builds/sdl3-$bitness subfolder"
	fi
