#!/bin/bash
cur_wd="$PWD"
bitness="$(getconf LONG_BIT)"

	# Libretro fceumm build
	if [[ "$var" == "fceumm" || "$var" == "all" ]] && [[ "$bitness" == "64" ]]; then
	 cd $cur_wd
	  if [ ! -d "libretro-fceumm/" ]; then
		git clone https://github.com/libretro/libretro-fceumm.git
		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the libretro git.  Is Internet active or did the git location change?  Stopping here."
		  exit 1
		 fi
		cp patches/fceumm-patch* libretro-fceumm/.
	  fi

	 cd libretro-fceumm/
	 
	 fceumm_patches=$(find *.patch)
	 
	 if [[ ! -z "$fceumm_patches" ]]; then
	  for patching in fceumm-patch*
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
	  make -f Makefile.libretro -j$(nproc)

	  if [[ $? != "0" ]]; then
		echo " "
		echo "There was an error while building the newest lr-fceumm core.  Stopping here."
		exit 1
	  fi

	  strip fceumm_libretro.so

	  if [ ! -d "../cores64/" ]; then
		mkdir -v ../cores64
	  fi

	  cp fceumm_libretro.so ../cores64/.

	  gitcommit=$(git log | grep -m 1 commit | cut -c -14 | cut -c 8-)
	  echo $gitcommit > ../cores$(getconf LONG_BIT)/fceumm_libretro.so.commit

	  echo " "
	  echo "fceumm_libretro.so has been created and has been placed in the rk3326_core_builds/cores64 subfolder"
	fi
