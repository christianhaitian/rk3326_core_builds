#!/bin/bash
cur_wd="$PWD"
bitness="$(getconf LONG_BIT)"

	# Libretro pcfx build
	if [[ "$var" == "pcfx" || "$var" == "all" ]] && [[ "$bitness" == "64" ]]; then
	 cd $cur_wd
	  if [ ! -d "pcfx/" ]; then
		git clone https://github.com/libretro/beetle-pcfx-libretro.git
		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the libretro git.  Is Internet active or did the git location change?  Stopping here."
		  exit 1
		 fi
		cp patches/pcfx-patch* beetle-pcfx-libretro/.
	  fi

	 cd beetle-pcfx-libretro/
	 
	 pcfx_patches=$(find *.patch)
	 
	 if [[ ! -z "$pcfx_patches" ]]; then
	  for patching in pcfx-patch*
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
		echo "There was an error while building the newest lr-pcfx core.  Stopping here."
		exit 1
	  fi

	  strip mednafen_pcfx_libretro.so

	  if [ ! -d "../cores64/" ]; then
		mkdir -v ../cores64
	  fi

	  cp mednafen_pcfx_libretro.so ../cores64/.

	  gitcommit=$(git show | grep commit | cut -c -14 | cut -c 8-)
	  echo $gitcommit > ../cores$(getconf LONG_BIT)/mednafen_pcfx_libretro.so.commit

	  echo " "
	  echo "mednafen_pcfx_libretro.so has been created and has been placed in the rk3326_core_builds/cores64 subfolder"
	fi
