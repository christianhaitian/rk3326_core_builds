#!/bin/bash
cur_wd="$PWD"
bitness="$(getconf LONG_BIT)"

	# Libretro snes9x build
	if [[ "$var" == "snes9x" || "$var" == "all" ]] && [[ "$bitness" == "64" ]]; then
	 cd $cur_wd
	  if [ ! -d "snes9x/" ]; then
		git clone https://github.com/libretro/snes9x.git
		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the libretro git.  Is Internet active or did the git location change?  Stopping here."
		  exit 1
		 fi
		cp patches/snes9x-patch* snes9x/.
	  fi

	 cd snes9x/
	 
	 snes9x_patches=$(find *.patch)
	 
	 if [[ ! -z "$snes9x_patches" ]]; then
	  for patching in snes9x-patch*
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

      cd libretro
	  make clean
	  make -j$(nproc)

	  if [[ $? != "0" ]]; then
		echo " "
		echo "There was an error while building the newest lr-snes9x core.  Stopping here."
		exit 1
	  fi

	  strip snes9x_libretro.so

	  if [ ! -d "../../cores$(getconf LONG_BIT)/" ]; then
		mkdir -v ../../cores$(getconf LONG_BIT)
	  fi

	  cp snes9x_libretro.so ../../cores$(getconf LONG_BIT)/.

	  gitcommit=$(git log | grep -m 1 commit | cut -c -14 | cut -c 8-)
	  echo $gitcommit > ../../cores$(getconf LONG_BIT)/snes9x_libretro.so.commit

	  echo " "
	  echo "snes9x_libretro.so has been created and has been placed in the rk3326_core_builds/cores$(getconf LONG_BIT) subfolder"
	fi
