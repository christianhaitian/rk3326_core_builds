#!/bin/bash
cur_wd="$PWD"
bitness="$(getconf LONG_BIT)"

	# Libretro atari800 build
	if [[ "$var" == "atari800" || "$var" == "all" ]] && [[ "$bitness" == "64" ]]; then
	 cd $cur_wd
	  if [ ! -d "libretro-atari800/" ]; then
		git clone https://github.com/libretro/libretro-atari800.git
		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the libretro git.  Is Internet active or did the git location change?  Stopping here."
		  exit 1
		 fi
		cp patches/atari800-patch* libretro-atari800/.
	  fi

	 cd libretro-atari800/
	 
	 atari800_patches=$(find *.patch)
	 
	 if [[ ! -z "$atari800_patches" ]]; then
	  for patching in atari800-patch*
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
	  make platform=arkos -j$(($(nproc) - 1))

	  if [[ $? != "0" ]]; then
		echo " "
		echo "There was an error while building the newest lr-atari800 core.  Stopping here."
		exit 1
	  fi

	  strip atari800_libretro.so

	  if [ ! -d "../cores64/" ]; then
		mkdir -v ../cores64
	  fi

	  cp atari800_libretro.so ../cores64/.

	  gitcommit=$(git log | grep -m 1 commit | cut -c -14 | cut -c 8-)
	  echo $gitcommit > ../cores$(getconf LONG_BIT)/atari800_libretro.so.commit

	  echo " "
	  echo "atari800_libretro.so has been created and has been placed in the rk3326_core_builds/cores64 subfolder"
	fi
