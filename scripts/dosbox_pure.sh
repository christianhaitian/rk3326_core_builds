#!/bin/bash
cur_wd="$PWD"
bitness="$(getconf LONG_BIT)"

	# Libretro dosbox_pure
	if [[ "$var" == "dosbox_pure" || "$var" == "all" ]] && [[ "$bitness" == "64" ]]; then
	 cd $cur_wd
	  if [ ! -d "dosbox_pure/" ]; then
		git clone https://github.com/libretro/dosbox-pure.git
		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the libretro git.  Is Internet active or did the git location change?  Stopping here."
		  exit 1
		fi
		cp patches/dosbox_pure-patch* dosbox-pure/.
	  fi

	 cd dosbox-pure/
	 
	 dosboxpure_patches=$(find *.patch)
	 
	 if [[ ! -z "$dosboxpure_patches" ]]; then
	  for patching in dosbox_pure-patch*
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
	 
	  make platform=goadvance -j$(($(nproc) - 1))

	  if [[ $? != "0" ]]; then
		echo " "
		echo "There was an error while building the newest lr-dosbox_pure core.  Stopping here."
		exit 1
	  fi

	  strip dosbox_pure_libretro.so

	  if [ ! -d "../cores64/" ]; then
		mkdir -v ../cores64
	  fi

	  cp dosbox_pure_libretro.so ../cores64/.

	  gitcommit=$(git log | grep -m 1 commit | cut -c -14 | cut -c 8-)
	  echo $gitcommit > ../cores$bitness/dosbox_pure_libretro.so.commit

	  echo " "
	  echo "dosbox_pure_libretro.so has been created and has been placed in the rk3326_core_builds/cores64 subfolder"
	fi
