#!/bin/bash

##################################################################
# Created by Christian Haitian for use to easily update          #
# various standalone emulators, libretro cores, and other        #
# various programs for the RK3326 platform for various Linux     #
# based distributions.                                           #
# See the LICENSE.md file at the top-level directory of this     #
# repository.                                                    #
##################################################################

cur_wd="$PWD"
bitness="$(getconf LONG_BIT)"

	# Libretro beetle-psx build
	if [[ "$var" == "beetle-psx" || "$var" == "all" ]] && [[ "$bitness" == "64" ]]; then
	 cd $cur_wd
	  if [ ! -d "beetle-psx-libretro/" ]; then
		git clone https://github.com/libretro/beetle-psx-libretro.git
		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the libretro git.  Is Internet active or did the git location change?  Stopping here."
		  exit 1
		 fi
		cp patches/beetle_psx_patch* beetle-psx-libretro/.
	  fi

	 cd beetle-psx-libretro/
	 
	 beetle_psx_patches=$(find *.patch)
	 
	 if [[ ! -z "$beetle_psx_patches" ]]; then
	  for patching in beetle_psx_patch*
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

	  sed -i '/a72/s//a35/g' Makefile
	  sed -i '/rpi4_64/s//rk3326_64/' Makefile
	  make clean
	  make platform=rk3326_64 HAVE_HW=1 -j$(nproc)

	  if [[ $? != "0" ]]; then
		echo " "
		echo "There was an error while building the newest lr-beetle-psx core.  Stopping here."
		exit 1
	  fi

	  strip mednafen_psx_hw_libretro.so

	  if [ ! -d "../cores64/" ]; then
		mkdir -v ../cores64
	  fi

	  cp mednafen_psx_hw_libretro.so ../cores64/.

	  gitcommit=$(git log | grep -m 1 commit | cut -c -14 | cut -c 8-)
	  echo $gitcommit > ../cores$(getconf LONG_BIT)/mednafen_psx_hw_libretro.so.commit

	  echo " "
	  echo "mednafen_psx_hw_libretro.so has been created and has been placed in the rk3326_core_builds/cores64 subfolder"
	fi
