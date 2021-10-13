#!/bin/bash
cur_wd="$PWD"
bitness="$(getconf LONG_BIT)"

	# Libretro yabasanshiro build
	if [[ "$var" == "yabasanshiro" || "$var" == "all" ]] && [[ "$bitness" == "32" ]]; then
	 cd $cur_wd
	  if [ ! -d "yabasanshiro/" ]; then
		git clone https://github.com/libretro/yabause.git -b yabasanshiro
		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the yabasanshiro (yabause) libretro git.  Is Internet active or did the git location change?  Stopping here."
		  exit 1
		fi
		cp patches/yabasanshiro-patch* yabause/.
	  fi

	 cd yabause/
	 
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

	  make clean
	  make -C yabause/src/libretro platform=goadvance -j$(nproc)

	  if [[ $? != "0" ]]; then
		echo " "
		echo "There was an error while building the newest lr-yabasanshiro core.  Stopping here."
		exit 1
	  fi

	  strip yabause/src/libretro/yabasanshiro_libretro.so

	  if [ ! -d "../cores32/" ]; then
		mkdir -v ../cores32
	  fi

	  cp yabause/src/libretro/yabasanshiro_libretro.so ../cores32/.

	  gitcommit=$(git show | grep commit | cut -c -14 | cut -c 8-)
	  echo $gitcommit > ../cores$bitness/yabasanshiro_libretro.so.commit

	  echo " "
	  echo "yabasanshiro_libretro.so has been created and has been placed in the rk3326_core_builds/cores32 subfolder"
	fi
