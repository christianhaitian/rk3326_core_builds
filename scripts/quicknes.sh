#!/bin/bash
cur_wd="$PWD"
bitness="$(getconf LONG_BIT)"

	# Libretro quicknes build
	if [[ "$var" == "quicknes" || "$var" == "all" ]] && [[ "$bitness" == "64" ]]; then
	 cd $cur_wd
	  if [ ! -d "quicknes/" ]; then
		git clone https://github.com/libretro/quicknes_core.git
		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the libretro git.  Is Internet active or did the git location change?  Stopping here."
		  exit 1
		 fi
		cp patches/quicknes-patch* quicknes_core/.
	  fi

	 cd quicknes_core/
	 
	 quicknes_patches=$(find *.patch)
	 
	 if [[ ! -z "$quicknes_patches" ]]; then
	  for patching in quicknes-patch*
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
	  make -j$(nproc)

	  if [[ $? != "0" ]]; then
		echo " "
		echo "There was an error while building the newest lr-quicknes core.  Stopping here."
		exit 1
	  fi

	  strip quicknes_libretro.so

	  if [ ! -d "../cores64/" ]; then
		mkdir -v ../cores64
	  fi

	  cp quicknes_libretro.so ../cores64/.

	  gitcommit=$(git log | grep -m 1 commit | cut -c -14 | cut -c 8-)
	  echo $gitcommit > ../cores$(getconf LONG_BIT)/quicknes_libretro.so.commit

	  echo " "
	  echo "quicknes_libretro.so has been created and has been placed in the rk3326_core_builds/cores64 subfolder"
	fi
