#!/bin/bash
cur_wd="$PWD"
bitness="$(getconf LONG_BIT)"

	# Libretro mame2003-plus build
	if [[ "$var" == "mame2003-plus" || "$var" == "all" ]] && [[ "$bitness" == "64" ]]; then
	 cd $cur_wd
	  if [ ! -d "mame2003-plus-libretro/" ]; then
		git clone https://github.com/libretro/mame2003-plus-libretro.git
		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the libretro git.  Is Internet active or did the git location change?  Stopping here."
		  exit 1
		 fi
		cp patches/mame2003-plus-patch* mame2003-plus-libretro/.
	  fi

	 cd mame2003-plus-libretro/
	 
	 mame2003_plus_patches=$(find *.patch)
	 
	 if [[ ! -z "$mame2003_plus_patches" ]]; then
	  for patching in mame2003-plus-patch*
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
      make -j3

	  if [[ $? != "0" ]]; then
		echo " "
		echo "There was an error while building the newest lr-mame2003-plus core.  Stopping here."
		exit 1
	  fi

	  strip mame2003_plus_libretro.so

	  if [ ! -d "../cores$(getconf LONG_BIT)/" ]; then
		mkdir -v ../cores$(getconf LONG_BIT)
	  fi

	  cp mame2003_plus_libretro.so ../cores$(getconf LONG_BIT)/mame2003_plus_libretro.so

	  gitcommit=$(git log | grep -m 1 commit | cut -c -14 | cut -c 8-)
	  echo $gitcommit > ../cores$(getconf LONG_BIT)/mame2003_plus_libretro.so.commit

	  echo " "
	  echo "mame2003-plus_libretro.so has been created and has been placed in the rk3326_core_builds/cores$(getconf LONG_BIT) subfolder"
	fi
