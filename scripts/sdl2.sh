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
#commit="25f9ed87ff6947d9576fc9d79dee0784e638ac58" # SDL 2.0.16
#commit="f9b918ff403782986f2a6712e6e2a462767a0457" # SDL 2.0.20 although it builds as 2.0.20.0 ¯\_(ツ)_/¯
#commit="f070c83a6059c604cbd098680ddaee391b0a7341" # SDL 2.0.26.2
#commit="8c9beb0c873f6ca5efbd88f1ad2648bfc793b2ac" # SDL 2.0.24.0
#commit="ac13ca9ab691e13e8eebe9684740ddcb0d716203" # SDL 2.0.26.5
#commit="031912c4b6c5db80b443f04aa56fec3e4e645153" # SDL 2.0.28.2
#commit="f461d91cd265d7b9a44b4d472b1df0c0ad2855a0" # SDL 2.0.30.2
#commit="fb1497566c5a05e2babdcf45ef0ab5c7cca2c4ae" # SDL 2.0.30.3
#commit="2eef7ca475decd2b864214cdbfe72b143b16d459" # SDL 2.0.30.5 (BAD)
#commit="7ca3d26e7aa0ff1f7ba48eee2f35ac5fb4de0057" # SDL 2.0.30.6 (Bad)
#commit="release-2.30.x"
#commit="9519b9916cd29a14587af0507292f2bd31dd5752" # SDL 2.0.30.7
commit="9c821dc21ccbd69b2bda421fdb35cb4ae2da8f5e" # SDL 2.0.30.10
#commit="7a44b1ab002cee6efa56d3b4c0e146b7fbaed80b" # SDL 2.0.32.0
#commit="e11183ea6caa3ae4895f4bc54cad2bbb0e365417" # SDL 2.0.32.2
extension="3000.10"

	# sdl2 Standalone Build
	if [[ "$var" == "sdl2" ]]; then
	 cd $cur_wd

	  # Now we'll start the clone and build process of sdl2
	  if [ ! -d "SDL/" ]; then
		git clone https://github.com/libsdl-org/SDL
		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the sdl2 standalone git.  Is Internet active or did the git location change?  Stopping here."
		  exit 1
		fi
		cp patches/sdl2-patch* SDL/.
	  else
		echo " "
		echo "A sdl2 subfolder already exists.  Stopping here to not impact anything in the folder that may be needed.  If not needed, please remove the sdl2 folder and rerun this script."
		echo " "
		exit 1
	  fi

	 cd SDL
     git checkout $commit

	 sdl2_patches=$(find *.patch)
	 
	 if [[ ! -z "$sdl2_patches" ]]; then
	  for patching in sdl2-patch*
	  do
		 if [[ $patching == *"odroidgoa"* ]]; then
		   echo " "
		   echo "Skipping the $patching for now and making a note to apply that later"
		   sleep 3
		   sdl2_rotationpatch="yes"
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

     #sed -i "s| -lrga||g" CMakeLists.txt

        if [[ $bitness == "32" ]]; then
         ./autogen.sh
         ./configure --host=arm-linux-gnueabihf \
         --enable-video-kmsdrm \
         --disable-video-x11 \
         --disable-video-rpi \
         --disable-video-wayland \
         --disable-video-vulkan
       else
         mkdir build
         cd build
         cmake -DCMAKE_INSTALL_PREFIX=/usr/lib/aarch64-linux-gnu \
	 		   -DCMAKE_INSTALL_LIBDIR="/usr/lib/aarch64-linux-gnu" \
	 		   -DSDL_STATIC=OFF \
			   -DSDL_LIBC=ON \
			   -DSDL_GCC_ATOMICS=ON \
			   -DSDL_ALTIVEC=OFF \
			   -DSDL_OSS=OFF \
			   -DSDL_ALSA=ON \
			   -DSDL_ALSA_SHARED=ON \
			   -DSDL_JACK=OFF \
			   -DSDL_JACK_SHARED=OFF \
			   -DSDL_ESD=OFF \
			   -DSDL_ESD_SHARED=OFF \
			   -DSDL_ARTS=OFF \
			   -DSDL_ARTS_SHARED=OFF \
			   -DSDL_NAS=OFF \
			   -DSDL_NAS_SHARED=OFF \
			   -DSDL_LIBSAMPLERATE=ON \
			   -DSDL_LIBSAMPLERATE_SHARED=OFF \
			   -DSDL_SNDIO=OFF \
			   -DSDL_DISKAUDIO=OFF \
			   -DSDL_DUMMYAUDIO=OFF \
			   -DSDL_WAYLAND=OFF \
			   -DSDL_WAYLAND_QT_TOUCH=OFF \
			   -DSDL_WAYLAND_SHARED=OFF \
			   -DSDL_COCOA=OFF \
			   -DSDL_DIRECTFB=OFF \
			   -DSDL_VIVANTE=OFF \
			   -DSDL_DIRECTFB_SHARED=OFF \
			   -DSDL_FUSIONSOUND=OFF \
			   -DSDL_FUSIONSOUND_SHARED=OFF \
			   -DSDL_DUMMYVIDEO=OFF \
			   -DSDL_PTHREADS=ON \
			   -DSDL_PTHREADS_SEM=ON \
			   -DSDL_DIRECTX=OFF \
			   -DSDL_CLOCK_GETTIME=OFF \
			   -DSDL_RPATH=OFF \
			   -DSDL_RENDER_D3D=OFF \
			   -DSDL_X11=OFF \
			   -DSDL_OPENGLES=ON \
			   -DSDL_VULKAN=OFF \
			   -DSDL_KMSDRM=ON \
			   -DSDL_PULSEAUDIO=ON ..
          export LDFLAGS="${LDFLAGS} -lrga"
       fi

      #../configure --prefix=$PWD/bin$bitness
	  #make clean
   	  if [[ $bitness == "32" ]]; then
	    git checkout 528b71284f491bcb6ecfd4ab7e00d37b296bd621 -- src/joystick/SDL_gamecontroller.c # Revert CRC joystick changes
      	  else
	    git checkout 528b71284f491bcb6ecfd4ab7e00d37b296bd621 -- ../src/joystick/SDL_gamecontroller.c # Revert CRC joystick changes
	  fi
	  git revert -n e5024fae3decb724e397d3c9dbcb744d8c79aac1
	  make -j$(nproc)
	  #make install

	  if [[ $? != "0" ]]; then
		echo " "
		echo "There was an error while building sdl2 at commit $commit.  Stopping here."
		exit 1
	  fi

      if [[ $bitness == "32" ]]; then
	     strip build/.libs/libSDL2-2.0.so.0.$extension
	  else
	     strip libSDL2-2.0.so.0.$extension
	  fi

	  if [ ! -d "$cur_wd/sdl2-$bitness/" ]; then
		mkdir -v $cur_wd/sdl2-$bitness
	  fi

      if [[ $bitness == "32" ]]; then
	     cp build/.libs/libSDL2-2.0.so.0.$extension $cur_wd/sdl2-$bitness/.
	  else
	     cp libSDL2-2.0.so.0.$extension $cur_wd/sdl2-$bitness/.
	  fi

	  echo " "
	  echo "sdl $(git describe --tags | cut -c 9-) has been created and has been placed in the rk3326_core_builds/sdl2-$bitness subfolder"
	fi

    if [[ $bitness == "64" ]]; then
       cd ..
    fi

    if [[ $sdl2_rotationpatch == "yes" ]]; then
	  for patching in sdl2-patch*
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

    if [[ $bitness == "64" ]]; then
       cd build
    fi

      #make clean
	  make -j$(nproc)

	  if [[ $? != "0" ]]; then
		echo " "
		echo "There was an error while building sdl2 at commit $commit with the rotation patch applied.  Stopping here."
		exit 1
	  fi

      if [[ $bitness == "32" ]]; then
	     strip build/.libs/libSDL2-2.0.so.0.$extension
	     cp build/.libs/libSDL2-2.0.so.0.$extension $cur_wd/sdl2-$bitness/libSDL2-2.0.so.0.$extension.rotated
	  else
	     strip libSDL2-2.0.so.0.$extension
	     cp libSDL2-2.0.so.0.$extension $cur_wd/sdl2-$bitness/libSDL2-2.0.so.0.$extension.rotated
      fi

	  echo " "
	  echo "sdl $(git describe --tags | cut -c 9-) with rotation has been created and has been placed in the rk3326_core_builds/sdl2-$bitness subfolder"

