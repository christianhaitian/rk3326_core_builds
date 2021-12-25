#!/bin/bash
cur_wd="$PWD"
bitness="$bitness"

	# Libretro uae4arm build
	if [[ "$var" == "uae4arm" || "$var" == "all" ]]; then
	 cd $cur_wd
	  if [ ! -d "uae4arm/" ]; then
        #if [[ $bitness == "32" ]]; then
		#  git clone --recursive https://github.com/libretro/uae4arm-libretro.git uae4arm
		#else
		  git clone --recursive https://github.com/Chips-fr/uae4arm-rpi uae4arm
		#fi
		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the libretro git.  Is Internet active or did the git location change?  Stopping here."
		  exit 1
		 fi
		cp patches/uae4arm-patch* uae4arm/.
	  fi

	 cd uae4arm/
	 
	 uae4arm_patches=$(find *.patch)
	 
	 if [[ ! -z "$uae4arm_patches" ]]; then
	  for patching in uae4arm-patch*
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

	  if [[ "$bitness" == "64" ]]; then
		make -f Makefile.libretro platform=unix_aarch64 "CPU_FLAGS=-mcpu=cortex-a35+crypto+crc" -j$(nproc)
	  else
		make -f Makefile.libretro platform=unix-neon "CPU_FLAGS=-O2 -march=armv8-a+crc -mtune=cortex-a35 -mfpu=neon-fp-armv8 -mfloat-abi=hard -ftree-vectorize -funsafe-math-optimizations" -j$(nproc)
	  fi

	  if [[ $? != "0" ]]; then
		echo " "
		echo "There was an error while building the newest lr-uae4arm core.  Stopping here."
		exit 1
	  fi

	  strip uae4arm_libretro.so

	  if [ ! -d "../cores$bitness/" ]; then
		mkdir -v ../cores$bitness
	  fi

	  cp uae4arm_libretro.so ../cores$bitness/.

	  gitcommit=$(git log | grep -m 1 commit | cut -c -14 | cut -c 8-)
	  echo $gitcommit > ../cores$bitness/$(basename $PWD)_libretro.so.commit

	  echo " "
	  echo "uae4arm_libretro.so has been created and has been placed in the rk3326_core_builds/cores$bitness subfolder"
	fi
