#!/bin/bash
cur_wd="$PWD"
bitness="$(getconf LONG_BIT)"

	# Libretro puae build
	if [[ "$var" == "puae" || "$var" == "all" ]] && [[ "$bitness" == "64" ]]; then
	 cd $cur_wd
	  if [ ! -d "libretro-uae/" ]; then
		git clone https://github.com/libretro/libretro-uae.git
		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the libretro git.  Is Internet active or did the git location change?  Stopping here."
		  exit 1
		 fi
		cp patches/puae-patch* libretro-uae/.
	  fi

	 cd libretro-uae/
	 
	 puae_patches=$(find *.patch)
	 
	 if [[ ! -z "$puae_patches" ]]; then
	  for patching in puae-patch*
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
		echo "There was an error while building the newest lr-puae core.  Stopping here."
		exit 1
	  fi

	  strip puae_libretro.so

	  if [ ! -d "../cores64/" ]; then
		mkdir -v ../cores64
	  fi

	  cp puae_libretro.so ../cores64/.

	  gitcommit=$(git log | grep -m 1 commit | cut -c -14 | cut -c 8-)
	  echo $gitcommit > ../cores$(getconf LONG_BIT)/puae_libretro.so.commit

	  echo " "
	  echo "puae_libretro.so has been created and has been placed in the rk3326_core_builds/cores64 subfolder"
	fi
