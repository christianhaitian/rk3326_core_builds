#!/bin/bash
cur_wd="$PWD"
bitness="$(getconf LONG_BIT)"
commit="25f9ed87ff6947d9576fc9d79dee0784e638ac58" # SDL 2.0.16

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

	 mkdir build
	 cd build
	 mkdir bin$bitness

     cmake -DSDL_STATIC=OFF \
           -DLIBC=ON \
           -DGCC_ATOMICS=ON \
           -DALTIVEC=OFF \
           -DOSS=OFF \
           -DALSA=ON \
           -DALSA_SHARED=ON \
           -DJACK=OFF \
           -DJACK_SHARED=OFF \
           -DESD=OFF \
           -DESD_SHARED=OFF \
           -DARTS=OFF \
           -DARTS_SHARED=OFF \
           -DNAS=OFF \
           -DNAS_SHARED=OFF \
           -DLIBSAMPLERATE=ON \
           -DLIBSAMPLERATE_SHARED=ON \
           -DSNDIO=OFF \
           -DDISKAUDIO=OFF \
           -DDUMMYAUDIO=OFF \
           -DVIDEO_WAYLAND=OFF \
           -DVIDEO_WAYLAND_QT_TOUCH=ON \
           -DWAYLAND_SHARED=OFF \
           -DVIDEO_MIR=OFF \
           -DMIR_SHARED=OFF \
           -DVIDEO_COCOA=OFF \
           -DVIDEO_DIRECTFB=OFF \
           -DVIDEO_VIVANTE=OFF \
           -DDIRECTFB_SHARED=OFF \
           -DFUSIONSOUND=OFF \
           -DFUSIONSOUND_SHARED=OFF \
           -DVIDEO_DUMMY=OFF \
           -DINPUT_TSLIB=OFF \
           -DPTHREADS=ON \
           -DPTHREADS_SEM=ON \
           -DDIRECTX=OFF \
           -DSDL_DLOPEN=ON \
           -DCLOCK_GETTIME=OFF \
           -DRPATH=OFF \
           -DRENDER_D3D=OFF \
           -DVIDEO_X11=OFF \
           -DVIDEO_OPENGL=OFF \
           -DVIDEO_OPENGLES=ON \
           -DVIDEO_VULKAN=OFF \
           -DVIDEO_KMSDRM=ON \
           -DPULSEAUDIO=ON ..
      export LDFLAGS="${LDFLAGS} -lrga"

      #../configure --prefix=$PWD/bin$bitness
	  make clean
	  make -j$(nproc)
	  #make install

	  if [[ $? != "0" ]]; then
		echo " "
		echo "There was an error while building sdl2 at commit $commit.  Stopping here."
		exit 1
	  fi

	  strip libSDL2-2.0.so.0.16.0

	  if [ ! -d "../../sdl2-$bitness/" ]; then
		mkdir -v ../../sdl2-$bitness
	  fi

	  cp libSDL2-2.0.so.0.16.0 ../../sdl2-$bitness/.

	  echo " "
	  echo "sdl $(git describe --tags | cut -c 9-) has been created and has been placed in the rk3326_core_builds/sdl2-$bitness subfolder"
	fi

    cd ..
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

      cd build	
	  make -j$(nproc)
	  make install

	  if [[ $? != "0" ]]; then
		echo " "
		echo "There was an error while building sdl2 at commit $commit with the rotation patch applied.  Stopping here."
		exit 1
	  fi

	  strip libSDL2-2.0.so.0.16.0

	  cp libSDL2-2.0.so.0.16.0 ../../sdl2-$bitness/libSDL2-2.0.so.0.16.0.rotated

	  echo " "
	  echo "sdl $(git describe --tags | cut -c 9-) with rotation has been created and has been placed in the rk3326_core_builds/sdl2-$bitness subfolder"
	fi

