#!/bin/bash
cur_wd="$PWD"
bitness="$(getconf LONG_BIT)"

	# Libretro fmsx build
	if [[ "$var" == "fmsx" || "$var" == "all" ]] && [[ "$bitness" == "64" ]]; then
	 cd $cur_wd
	  if [ ! -d "fmsx/" ]; then
		git clone --recursive https://github.com/libretro/fmsx-libretro.git
		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the libretro git.  Is Internet active or did the git location change?  Stopping here."
		  exit 1
		 fi
		cp patches/fmsx-patch* fmsx/.
	  fi

	 cd fmsx-libretro/
	 
	 fmsx_patches=$(find *.patch)
	 
	 if [[ ! -z "$fmsx_patches" ]]; then
	  for patching in fmsx-patch*
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
	  make -j$(($(nproc) - 1))

	  if [[ $? != "0" ]]; then
		echo " "
		echo "There was an error while building the newest lr-fmsx core.  Stopping here."
		exit 1
	  fi

	  strip fmsx_libretro.so

	  if [ ! -d "../cores$(getconf LONG_BIT)/" ]; then
		mkdir -v ../cores$(getconf LONG_BIT)
	  fi

	  cp fmsx_libretro.so ../cores$(getconf LONG_BIT)/.

	  gitcommit=$(git log | grep -m 1 commit | cut -c -14 | cut -c 8-)
	  echo $gitcommit > ../cores$(getconf LONG_BIT)/fmsx_libretro.so.commit

	  echo " "
	  echo "fmsx_libretro.so has been created and has been placed in the rk3326_core_builds/cores$(getconf LONG_BIT) subfolder"
	fi
