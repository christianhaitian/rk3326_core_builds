#!/bin/bash
cur_wd="$PWD"
bitness="$(getconf LONG_BIT)"

	# Libretro px68k build
	if [[ "$var" == "px68k" || "$var" == "all" ]] && [[ "$bitness" == "64" ]]; then
	 cd $cur_wd
	  if [ ! -d "px68k-libretro/" ]; then
		git clone https://github.com/libretro/px68k-libretro.git
		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the libretro git.  Is Internet active or did the git location change?  Stopping here."
		  exit 1
		 fi
		cp patches/px68k-patch* px68k-libretro/.
	  fi

	 cd px68k-libretro/
	 
	 px68k_patches=$(find *.patch)
	 
	 if [[ ! -z "$px68k_patches" ]]; then
	  for patching in px68k-patch*
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
		echo "There was an error while building the newest lr-px68k core.  Stopping here."
		exit 1
	  fi

	  strip px68k_libretro.so

	  if [ ! -d "../cores64/" ]; then
		mkdir -v ../cores64
	  fi

	  cp px68k_libretro.so ../cores64/.

	  gitcommit=$(git show | grep commit | cut -c -14 | cut -c 8-)
	  echo $gitcommit > ../cores$(getconf LONG_BIT)/px68k_libretro.so.commit

	  echo " "
	  echo "px68k_libretro.so has been created and has been placed in the rk3326_core_builds/cores64 subfolder"
	fi
