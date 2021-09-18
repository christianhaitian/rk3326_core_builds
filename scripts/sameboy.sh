#!/bin/bash
cur_wd="$PWD"
bitness="$(getconf LONG_BIT)"

	# Libretro sameboy build
	if [[ "$var" == "sameboy" || "$var" == "all" ]] && [[ "$bitness" == "64" ]]; then
	 cd $cur_wd
	  if [ ! -d "sameboy/" ]; then
		git clone https://github.com/libretro/sameboy.git
		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the libretro git.  Is Internet active or did the git location change?  Stopping here."
		  exit 1
		 fi
		cp patches/sameboy-patch* sameboy/.
	  fi

	 cd sameboy/
	 
	 sameboy_patches=$(find *.patch)
	 
	 if [[ ! -z "$sameboy_patches" ]]; then
	  for patching in sameboy-patch*
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
	  make -C libretro platform=rk3326 -j$(nproc)

	  if [[ $? != "0" ]]; then
		echo " "
		echo "There was an error while building the newest lr-sameboy core.  Stopping here."
		exit 1
	  fi

	  strip libretro/sameboy_libretro.so

	  if [ ! -d "../cores64/" ]; then
		mkdir -v ../cores64
	  fi

	  cp libretro/sameboy_libretro.so ../cores64/.

	  gitcommit=$(git show | grep commit | cut -c -14 | cut -c 8-)
	  echo $gitcommit > ../cores$(getconf LONG_BIT)/$(basename $PWD)_libretro.so.commit

	  echo " "
	  echo "sameboy_libretro.so has been created and has been placed in the rk3326_core_builds/cores64 subfolder"
	fi
