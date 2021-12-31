#!/bin/bash
cur_wd="$PWD"
bitness="$(getconf LONG_BIT)"

	# Libretro supergrafx build
	if [[ "$var" == "supergrafx" || "$var" == "all" ]] && [[ "$bitness" == "64" ]]; then
	 cd $cur_wd
	  if [ ! -d "beetle-supergrafx-libretro/" ]; then
		git clone https://github.com/libretro/beetle-supergrafx-libretro.git
		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the libretro git.  Is Internet active or did the git location change?  Stopping here."
		  exit 1
		 fi
		cp patches/supergrafx-patch* beetle-supergrafx-libretro/.
	  fi

	 cd beetle-supergrafx-libretro/
	 
	 supergrafx_patches=$(find *.patch)
	 
	 if [[ ! -z "$supergrafx_patches" ]]; then
	  for patching in supergrafx-patch*
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
		echo "There was an error while building the newest lr-supergrafx core.  Stopping here."
		exit 1
	  fi

	  strip mednafen_supergrafx_libretro.so

	  if [ ! -d "../cores64/" ]; then
		mkdir -v ../cores64
	  fi

	  cp mednafen_supergrafx_libretro.so ../cores64/.

	  gitcommit=$(git log | grep -m 1 commit | cut -c -14 | cut -c 8-)
	  echo $gitcommit > ../cores$(getconf LONG_BIT)/mednafen_supergrafx_libretro.so.commit

	  echo " "
	  echo "mednafen_supergrafx_libretro.so has been created and has been placed in the rk3326_core_builds/cores64 subfolder"
	fi
