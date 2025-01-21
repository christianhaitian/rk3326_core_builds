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

	# Libretro doukutsu-rs-lr
	if [[ "$var" == "doukutsu-rs-lr" || "$var" == "all" ]] && [[ "$bitness" == "64" ]]; then
	 cd $cur_wd
	  if [ ! -d "doukutsu-rs-lr/" ]; then
		git clone --recursive https://github.com/DrGlaucous/doukutsu-rs-nm.git -b retroarch-dev
		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the libretro git.  Is Internet active or did the git location change?  Stopping here."
		  exit 1
		fi
		cp patches/doukutsu-rs-lr-patch* doukutsu-rs-nm/.
	  fi

	 cd doukutsu-rs-nm/
	 
	 doukutsu_patches=$(find *.patch)
	 
	 if [[ ! -z "$doukutsu_patches" ]]; then
	  for patching in doukutsu-rs-lr-patch*
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
	 
	 cd drsretroarch
	 make -j5

	  if [[ $? != "0" ]]; then
		echo " "
		echo "There was an error while building the newest lr-doukutsu-rs-lr core.  Stopping here."
		exit 1
	  fi

	  strip target/release/doukutsu_rs_libretro.so

	  if [ ! -d "../../cores64/" ]; then
		mkdir -v ../../cores64
	  fi

	  cp target/release/doukutsu_rs_libretro.so ../../cores64/.

	  gitcommit=$(git log | grep -m 1 commit | cut -c -14 | cut -c 8-)
	  echo $gitcommit > ../../cores$bitness/doukutsu-rs-lr_libretro.so.commit

	  echo " "
	  echo "doukutsu-rs-lr_libretro.so has been created and has been placed in the rk3326_core_builds/cores64 subfolder"
	fi
