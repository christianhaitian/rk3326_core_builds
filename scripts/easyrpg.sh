#!/bin/bash
cur_wd="$PWD"
bitness="$(getconf LONG_BIT)"

	# Libretro easyrpg build
	if [[ "$var" == "easyrpg" || "$var" == "all" ]] && [[ "$bitness" == "64" ]]; then
	 cd $cur_wd
	  if [ ! -d "easyrpg/" ]; then
		git clone https://github.com/EasyRPG/Player/ -b 0-7-0-stable
		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the libretro git.  Is Internet active or did the git location change?  Stopping here."
		  exit 1
		 fi
		cp patches/easyrpg-patch* Player/.
	  fi

    #When building a new easyrpg libretro core, a new liblcf library is sometimes needed as well.  This will build it and include it in cores64 folder just in case it's needed.
	 cd $cur_wd
	  if [ ! -d "liblcf/" ]; then
		git clone --recursive https://github.com/EasyRPG/liblcf
		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the liblcf git.  Is Internet active or did the git location change?  Stopping here."
		  exit 1
		 fi
         cd liblcf
         autoreconf -i
         ./configure
         make -j$(nproc)
	     if [[ $? != "0" ]]; then
		     echo " "
		     echo "There was an error while building the newest liblcf library.  Stopping here."
		     exit 1
	     fi
        strip .libs/liblcf.so.0
         make install
	     if [[ $? != "0" ]]; then
		     echo " "
		     echo "There was an error while installing the newest liblcf library.  Stopping here."
		     exit 1
	     fi
	  fi

	 cd $cur_wd
	 cd Player/
	 
	 easyrpg_patches=$(find *.patch)
	 
	 if [[ ! -z "$easyrpg_patches" ]]; then
	  for patching in easyrpg-patch*
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

	 git submodule init
	 git submodule update
     autoreconf -i
     ./configure
     cmake -DPLAYER_TARGET_PLATFORM=libretro -DBUILD_SHARED_LIBS=ON -DCMAKE_BUILD_TYPE=RelWithDebInfo .
     #make -j$(nproc)
     cmake --build . -j $(nproc)

	  if [[ $? != "0" ]]; then
		echo " "
		echo "There was an error while building the newest lr-easyrpg core.  Stopping here."
		exit 1
	  fi

	  strip easyrpg_libretro.so

	  if [ ! -d "../cores64/" ]; then
		mkdir -v ../cores64
	  fi

	  cp easyrpg_libretro.so ../cores64/.
      cp ../liblcf/.libs/liblcf.so.0 ../cores64/.
         
	  gitcommit=$(git show | grep commit | cut -c -14 | cut -c 8-)
	  echo $gitcommit > ../cores$(getconf LONG_BIT)/easyrpg_libretro.so.commit

	  echo " "
	  echo "easyrpg_libretro.so and an updated liblcf.so.0 library has been created and has been placed in the rk3326_core_builds/cores64 subfolder"
	fi
