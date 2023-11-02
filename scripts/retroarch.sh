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

	# Libretro Retroarch build
	if [[ "$var" == "retroarch" ]]; then
	 cd $cur_wd
	  if [ ! -d "retroarch/" ]; then
		git clone https://github.com/libretro/retroarch.git
		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the retroarch libretro git.  Is Internet active or did the git location change?  Stopping here."
		  exit 1
		fi
		cp patches/retroarch-patch* retroarch/.
	  fi

	 cd retroarch/
	 
	 retroarch_patches=$(find *.patch)
	 
	 if [[ ! -z "$retroarch_patches" ]]; then
	  for patching in retroarch-patch*
	  do
        if [[ $patching == *"norotation"* ]]; then
          echo " "
          echo "Skipping the $patching for now and making a note to apply that later"
          sleep 3
          retroarch_rgapatch="yes"
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
	  if [[ "$bitness" == "64" ]]; then
	    CFLAGS="-Ofast -march=armv8-a -mtune=cortex-a35 -fomit-frame-pointer -DNDEBUG" ./configure --disable-caca \
	    --disable-mali_fbdev \
	    --disable-opengl \
	    --disable-opengl1 \
	    --disable-qt \
	    --disable-sdl \
	    --disable-vg \
	    --disable-vulkan \
	    --disable-vulkan_display \
	    --disable-wayland \
	    --disable-x11 \
        --disable-xrandr \
        --disable-winrawinput \
        --disable-gdi \
        --disable-d3d10 \
        --disable-d3d11 \
        --disable-d3d12 \
        --disable-opengl1 \
        --disable-microphone \
	    --enable-alsa \
	    --enable-egl \
	    --enable-freetype \
	    --enable-kms \
	    --enable-networking \
	    --enable-odroidgo2 \
	    --enable-opengles \
	    --enable-opengles3 \
	    --enable-opengles3_1 \
	    --enable-opengles3_2 \
	    --enable-ozone \
	    --enable-udev \
	    --enable-wifi
      else
	    CFLAGS="-Ofast -march=armv8-a -mtune=cortex-a35 -mfpu=neon-fp-armv8 -mfloat-abi=hard -fomit-frame-pointer -DNDEBUG" ./configure --disable-caca \
	    --disable-mali_fbdev \
	    --disable-opengl \
	    --disable-opengl1 \
	    --disable-qt \
	    --disable-sdl \
	    --disable-vg \
	    --disable-vulkan \
	    --disable-vulkan_display \
	    --disable-wayland \
	    --disable-x11 \
        --disable-xrandr \
        --disable-winrawinput \
        --disable-gdi \
        --disable-d3d10 \
        --disable-d3d11 \
        --disable-d3d12 \
        --disable-opengl1 \
        --disable-microphone \
	    --enable-alsa \
	    --enable-egl \
	    --enable-freetype \
	    --enable-kms \
        --enable-neon \
	    --enable-networking \
	    --enable-odroidgo2 \
	    --enable-opengles \
	    --enable-opengles3 \
	    --enable-opengles3_1 \
	    --enable-opengles3_2 \
	    --enable-ozone \
	    --enable-udev \
	    --enable-wifi
      fi

	  make -j$(nproc)

	  if [[ $? != "0" ]]; then
		echo " "
		echo "There was an error while building the newest retroarch.  Stopping here."
		exit 1
	  fi

	  strip retroarch

	  if [ ! -d "../retroarch$bitness/" ]; then
		mkdir -v ../retroarch$bitness
	  fi

	  cp retroarch ../retroarch$bitness/.

	  if [[ "$bitness" == "32" ]]; then
		mv ../retroarch$bitness/retroarch ../retroarch$bitness/retroarch32
	  fi

	  echo " "
	  if [[ "$bitness" == "32" ]]; then
		echo "retroarch32 has been created and has been placed in the rk3326_core_builds/retroarch$bitness subfolder"
	  else
		echo "retroarch has been created and has been placed in the rk3326_core_builds/retroarch$bitness subfolder"
	  fi

      if [[ $retroarch_rgapatch == "yes" ]]; then
    	  for patching in retroarch-patch*
      	  do
       	    patch -Np1 < "$patching"
       		if [[ $? != "0" ]]; then
       		  echo " "
       		  echo "There was an error while applying $patching.  Stopping here."
       		  exit 1
       		fi
       		rm "$patching"
       	  done

	      make -j$(nproc)

	      if [[ $? != "0" ]]; then
		    echo " "
		    echo "There was an error while building the newest retroarch with the rga non rotation patch.  Stopping here."
		    exit 1
	      fi

	      strip retroarch

	      if [ ! -d "../retroarch$bitness/" ]; then
		    mkdir -v ../retroarch$bitness
	      fi

	      cp retroarch ../retroarch$bitness/retroarch-rgaunrotated

	      if [[ "$bitness" == "32" ]]; then
		    mv ../retroarch$bitness/retroarch ../retroarch$bitness/retroarch32-rgaunrotated
	      fi

	      echo " "
	      if [[ "$bitness" == "32" ]]; then
		    echo "retroarch32-rgaunrotated has been created and has been placed in the rk3326_core_builds/retroarch$bitness subfolder"
	      else
		    echo "retroarch-rgaunrotated has been created and has been placed in the rk3326_core_builds/retroarch$bitness subfolder"
	      fi
      fi

	  cd gfx/video_filters
	  ./configure
	  make -j$(nproc)
	  if [[ $? != "0" ]]; then
		echo " "
		echo "There was an error while building the video filters for retroarch.  Stopping here."
		exit 1
	  fi
	  mkdir -p ../../../retroarch$bitness/filters/video
	  cp *.so ../../../retroarch$bitness/filters/video
	  cp *.filt ../../../retroarch$bitness/filters/video
	  echo " "
	  echo "Video filters have been built and copied to the rk3326_core_builds/retroarch$bitness/filters/video subfolder"

          cd ../../libretro-common/audio/dsp_filters
          ./configure
          make -j$(nproc)
          if [[ $? != "0" ]]; then
                echo " "
                echo "There was an error while building the audio dsp filters for retroarch.  Stopping here."
                exit 1
          fi
          mkdir -p ../../../../retroarch$bitness/filters/audio
          cp *.so ../../../../retroarch$bitness/filters/audio
          cp *.dsp ../../../../retroarch$bitness/filters/audio
          echo " "
          echo "Audio dsp filters have been built and copied to the rk3566_core_builds/retroarch$bitness/filters/audio subfolder"
	fi
