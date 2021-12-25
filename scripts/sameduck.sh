#!/bin/bash
cur_wd="$PWD"
bitness="$(getconf LONG_BIT)"

	# Libretro sameduck build
	if [[ "$var" == "sameduck" || "$var" == "all" ]] && [[ "$bitness" == "64" ]]; then
	 cd $cur_wd
	  if [ ! -d "libretro-sameduck/" ]; then
		git clone --recursive https://github.com/LIJI32/SameBoy -b SameDuck
		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the libretro git.  Is Internet active or did the git location change?  Stopping here."
		  exit 1
		 fi
		cp patches/sameduck-patch* SameBoy/.
	  fi

	 cd SameBoy/
	 
	 sameduck_patches=$(find *.patch)
	 
	 if [[ ! -z "$sameduck_patches" ]]; then
	  for patching in sameduck-patch*
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
	  make -C libretro -j$(nproc)

	  if [[ $? != "0" ]]; then
		echo " "
		echo "There was an error while building the newest lr-sameduck core.  Stopping here."
		exit 1
	  fi

	  strip build/bin/sameduck_libretro.so

	  if [ ! -d "../cores64/" ]; then
		mkdir -v ../cores64
	  fi

	  cp build/bin/sameduck_libretro.so ../cores64/.

	  gitcommit=$(git log | grep -m 1 commit | cut -c -14 | cut -c 8-)
	  echo $gitcommit > ../cores$(getconf LONG_BIT)/sameduck_libretro.so.commit

	  echo " "
	  echo "sameduck_libretro.so has been created and has been placed in the rk3326_core_builds/cores64 subfolder"
	fi
