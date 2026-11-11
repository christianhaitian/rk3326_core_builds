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

	# armn64 libretro core build
	if [[ "$var" == "armn64"  || "$var" == "all" ]] && [[ "$bitness" == "64" ]]; then
	 cd $cur_wd

	  # Now we'll start the clone and build of armn64
	  if [ ! -d "armn64/" ]; then
		git clone --recursive https://github.com/MagnominusGit/armN64.git
		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the armn64 libretro git.  Is Internet active or did the git location change?  Stopping here."
		  exit 1
		fi
		cp patches/armn64-patch* armn64/.
	  else
		echo " "
		echo "A armn64 subfolder already exists.  Stopping here to not impact anything in the folder that may be needed.  If not needed, please remove the armn64 folder and rerun this script."
		echo " "
		exit 1
	  fi

	 cd armN64
	 
	 armn64_core_patches=$(find *.patch)
	 
	 if [[ ! -z "$armn64_core_patches" ]]; then
	  for patching in armn64-patch*
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

	 cmake -S . -B build-rk3326 -G Ninja \
	     -DCMAKE_BUILD_TYPE=Release \
	     -DARMN64_TUNE=OFF \
	     -DCMAKE_C_FLAGS_RELEASE="-O3 -DNDEBUG -mcpu=cortex-a35 -ffp-contract=off"

	 cmake --build build-rk3326 \
	     --target armn64_libretro -j$(nproc)

	  if [[ $? != "0" ]]; then
		echo " "
		echo "There was an error while building the newest armn64 libretro core.  Stopping here."
		exit 1
	  fi

	  strip build-rk3326/armn64_libretro.so

	  if [ ! -d "../cores$bitness/" ]; then
		mkdir -v ../cores$bitness
	  fi

	  cp build-rk3326/armn64_libretro.so ../cores$bitness/.

	  gitcommit=$(git log | grep -m 1 commit | cut -c -14 | cut -c 8-)
	  echo $gitcommit > ../cores$bitness/armn64_libretro.so.commit
	  
	  echo " "
	  echo "armn64_libretro.so executable has been created and has been placed in the rk3326_core_builds/cores$bitness subfolder"

	fi
