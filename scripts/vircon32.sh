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

	# Libretro vircon32
	if [[ "$var" == "vircon32" || "$var" == "all" ]] && [[ "$bitness" == "64" ]]; then
	 cd $cur_wd
	  if [ ! -d "vircon32/" ]; then
		git clone --recursive https://github.com/vircon32/vircon32-libretro.git vircon32
		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the libretro git.  Is Internet active or did the git location change?  Stopping here."
		  exit 1
		fi
		cp patches/vircon32-patch* vircon32/.
	  fi

	 cd vircon32/
	 
	 vircon32_patches=$(find *.patch)
	 
	 if [[ ! -z "$vircon32_patches" ]]; then
	  for patching in vircon32-patch*
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
	 
	  mkdir build
	  cd build
	  cmake -DENABLE_OPENGLES3=1 -DCMAKE_BUILD_TYPE=Release -DCMAKE_RULE_MESSAGES=OFF -DPLATFORM=EMUELEC ..
	  make -j$(nproc)

	  if [[ $? != "0" ]]; then
		echo " "
		echo "There was an error while building the newest lr-vircon32 core.  Stopping here."
		exit 1
	  fi

	  strip vircon32_libretro.so

	  if [ ! -d "../../cores64/" ]; then
		mkdir -v ../../cores64
	  fi

	  cp vircon32_libretro.so ../../cores64/.

	  cd ..
	  gitcommit=$(git log | grep -m 1 commit | cut -c -14 | cut -c 8-)
	  echo $gitcommit > ../cores$bitness/vircon32_libretro.so.commit

	  echo " "
	  echo "vircon32_libretro.so has been created and has been placed in the rk3326_core_builds/cores64 subfolder"
	fi
