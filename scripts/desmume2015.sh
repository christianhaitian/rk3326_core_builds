#!/bin/bash
cur_wd="$PWD"
bitness="$(getconf LONG_BIT)"

	# Libretro desmume2015 build
	if [[ "$var" == "desmume2015" || "$var" == "all" ]] && [[ "$bitness" == "64" ]]; then
	 cd $cur_wd
	  if [ ! -d "desmume2015/" ]; then
		git clone https://github.com/libretro/desmume2015.git
		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the libretro git.  Is Internet active or did the git location change?  Stopping here."
		  exit 1
		 fi
		cp patches/desmume2015-patch* desmume2015/.
	  fi

	 cd desmume2015/
	 
	 desmume2015_patches=$(find *.patch)
	 
	 if [[ ! -z "$desmume2015_patches" ]]; then
	  for patching in desmume2015-patch*
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

      cd desmume/
	  make -f Makefile.libretro clean
	  make -f Makefile.libretro platform=arm64-unix LDFLAGS="-lpthread" -j$(($(nproc) - 1))

	  if [[ $? != "0" ]]; then
		echo " "
		echo "There was an error while building the newest lr-desmume2015 core.  Stopping here."
		exit 1
	  fi

	  strip desmume2015_libretro.so

	  if [ ! -d "../../cores64/" ]; then
		mkdir -v ../../cores64
	  fi

	  cp desmume2015_libretro.so ../../cores64/.

	  gitcommit=$(git log | grep -m 1 commit | cut -c -14 | cut -c 8-)
	  echo $gitcommit > ../../cores$(getconf LONG_BIT)/desmume2015_libretro.so.commit

	  echo " "
	  echo "desmume2015_libretro.so has been created and has been placed in the rk3326_core_builds/cores64 subfolder"
	fi
