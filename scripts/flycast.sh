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

	# Libretro Flycast build
	if [[ "$var" == "flycast" || "$var" == "all" ]]; then
	 flycast_rumblepatch="no"
	 cd $cur_wd
	  if [ ! -d "flycast/" ]; then
		git clone https://github.com/libretro/flycast.git
		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the flycast libretro git.  Is Internet active or did the git location change?  Stopping here."
		  exit 1
		fi
		cp patches/flycast-patch* flycast/.
	  fi

	 cd flycast/
	 
	 flycast_patches=$(find *.patch)
	 
	 if [[ ! -z "$flycast_patches" ]]; then
	  for patching in flycast-patch*
	  do
		 if [[ $patching == *"rumble"* ]]; then
		   echo " "
		   echo "Skipping the $patching for now and making a note to apply that later"
		   sleep 3
		   flycast_rumblepatch="yes"
		 else  
		   patch -Np1 < "$patching"
		   if [[ $? != "0" ]]; then
			echo " "
			echo "There was an error while applying $patching.  Stopping here."
			exit 1
		   fi
		   rm "$patching" 
		 fi
	  done
	 fi
	  make clean

	  if [[ "$bitness" == "64" ]]; then
		make WITH_DYNAREC=arm64 FORCE_GLES=1 platform=goadvance -j$(nproc)
	  else 
		make FORCE_GLES=1 platform=classic_armv8_a35 -j$(nproc)
	  fi

	  if [[ $? != "0" ]]; then
		echo " "
		echo "There was an error while building the newest lr-flycast core.  Stopping here."
		exit 1
	  fi

	  strip flycast_libretro.so

	  if [ ! -d "../cores$bitness/" ]; then
		mkdir -v ../cores$bitness
	  fi

	  cp flycast_libretro.so ../cores$bitness/.

	  if [[ $flycast_rumblepatch == "yes" ]]; then
		for patching in flycast-patch*
		do
		  patch -Np1 < "$patching"
		  if [[ $? != "0" ]]; then
			echo " "
			echo "There was an error while patching in the rumble feature from $patching.  Stopping here."
			exit 1
		  fi
		  rm "$patching"

		  if [[ "$bitness" == "64" ]]; then
			make WITH_DYNAREC=arm64 FORCE_GLES=1 platform=goadvance -j$(nproc)
		  else 
			make FORCE_GLES=1 platform=classic_armv8_a35 -j$(nproc)
		  fi

		  if [[ $? != "0" ]]; then
			echo " "
			echo "There was an error while building the newest lr-flycast core with the patched in rumble feature.  Stopping here."
			exit 1
		  fi

		  strip flycast_libretro.so
		  mv flycast_libretro.so flycast_rumble_libretro.so

		  if [[ "$bitness" == "64" ]]; then
			cp flycast_rumble_libretro.so ../cores$bitness/.
		  else
			cp flycast_rumble_libretro.so ../cores$bitness/flycast32_rumble_libretro.so
		  fi
		  
		  echo " "
		  if [[ "$bitness" == "64" ]]; then
			echo "flycast_libretro.so and flycast_rumble_libretro.so have been created and have been placed in the rk3326_core_builds/cores$bitness subfolder"
	        gitcommit=$(git log | grep -m 1 commit | cut -c -14 | cut -c 8-)
       	    echo $gitcommit > ../cores$bitness/flycast_rumble_libretro.so.commit
		  else
			echo "flycast_libretro.so and flycast32_rumble_libretro.so have been created and have been placed in the rk3326_core_builds/cores$bitness subfolder"
	        gitcommit=$(git log | grep -m 1 commit | cut -c -14 | cut -c 8-)
	        echo $gitcommit > ../cores$bitness/flycast32_rumble_libretro.so.commit
		  fi
		done
	  fi

	  gitcommit=$(git log | grep -m 1 commit | cut -c -14 | cut -c 8-)
	  echo $gitcommit > ../cores$bitness/$(basename $PWD)_libretro.so.commit

	  echo " "
	  echo "flycast_libretro.so has been created and has been placed in the rk3326_core_builds/cores$bitness subfolder"
	fi
