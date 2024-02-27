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

	# Libretro geolith build
	if [[ "$var" == "geolith" || "$var" == "all" ]] && [[ "$bitness" == "64" ]]; then
	 cd $cur_wd
	  if [ ! -d "geolith-libretro/" ]; then
		git clone https://github.com/libretro/geolith-libretro.git
		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the libretro git.  Is Internet active or did the git location change?  Stopping here."
		  exit 1
		 fi
		cp patches/geolith-patch* geolith-libretro/.
	  fi

	 cd geolith-libretro/
	 
	 geolith_patches=$(find *.patch)
	 
	 if [[ ! -z "$geolith_patches" ]]; then
	  for patching in geolith-patch*
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

	  sed -i '/a53/s//a35/g' libretro/Makefile
	  sed -i '/rpi3_64/s//rk3326/' libretro/Makefile
	  make -C libretro/ clean
	  make -C libretro/ platform=rk3326 -j$(nproc)

	  if [[ $? != "0" ]]; then
		echo " "
		echo "There was an error while building the newest lr-geolith core.  Stopping here."
		exit 1
	  fi

	  strip libretro/geolith_libretro.so

	  if [ ! -d "../cores64/" ]; then
		mkdir -v ../cores64
	  fi

	  cp libretro/geolith_libretro.so ../cores64/.

	  gitcommit=$(git log | grep -m 1 commit | cut -c -14 | cut -c 8-)
	  echo $gitcommit > ../cores$(getconf LONG_BIT)/geolith_libretro.so.commit

	  echo " "
	  echo "geolith_libretro.so has been created and has been placed in the rk3326_core_builds/cores64 subfolder"
	fi
