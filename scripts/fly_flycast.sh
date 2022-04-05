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
	if [[ "$var" == "fly_flycast" || "$var" == "all" ]]; then
	 flycast_rumblepatch="no"
	 cd $cur_wd
	  if [ ! -d "flycast/" ]; then
		git clone --recursive https://github.com/flyinghead/flycast.git
		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the flyinghead flycast libretro git.  Is Internet active or did the git location change?  Stopping here."
		  exit 1
		fi
		cp patches/fly_flycast-patch* flycast/.
	  fi

	 cd flycast/
	 
	 flycast_patches=$(find *.patch)
	 
	 if [[ ! -z "$flycast_patches" ]]; then
	  for patching in fly_flycast-patch*
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

      mkdir build
      cd build
      cmake -Wno-dev \
            -DLIBRETRO=ON \
            -DWITH_SYSTEM_ZLIB=ON \
            -DUSE_OPENMP=ON \
            -DUSE_VULKAN=OFF \
            -DUSE_GLES=ON ..
	  make -j$(nproc)


	  if [[ $? != "0" ]]; then
		echo " "
		echo "There was an error while building the newest fly_flycast libretro core.  Stopping here."
		exit 1
	  fi

	  strip flycast_libretro.so

	  if [ ! -d "../../cores$bitness/" ]; then
		mkdir -v ../../cores$bitness
	  fi

	  cp flycast_libretro.so ../../cores$bitness/fly_flycast_libretro.so

      cd ..
	  if [[ $flycast_rumblepatch == "yes" ]]; then
		for patching in fly_flycast-patch*
		do
		  patch -Np1 < "$patching"
		  if [[ $? != "0" ]]; then
			echo " "
			echo "There was an error while patching in the rumble feature from $patching.  Stopping here."
			exit 1
		  fi
		  rm "$patching"

          cd build
		  make -j$(nproc)

		  if [[ $? != "0" ]]; then
			echo " "
			echo "There was an error while building the newest fly_flycast lr core with the patched in rumble feature.  Stopping here."
			exit 1
		  fi

		  strip flycast_libretro.so
		  mv flycast_libretro.so fly_flycast_rumble_libretro.so

		  if [[ "$bitness" == "64" ]]; then
			cp fly_flycast_rumble_libretro.so ../../cores$bitness/.
		  else
			cp fly_flycast_rumble_libretro.so ../../cores$bitness/fly_flycast32_rumble_libretro.so
		  fi
		  
		  echo " "
		  if [[ "$bitness" == "64" ]]; then
			echo "fly_flycast_libretro.so and fly_flycast_rumble_libretro.so have been created and have been placed in the rk3326_core_builds/cores$bitness subfolder"
	        gitcommit=$(git log | grep -m 1 commit | cut -c -14 | cut -c 8-)
       	    echo $gitcommit > ../../cores$bitness/fly_flycast_rumble_libretro.so.commit
		  else
			echo "fly_flycast_libretro.so and fly_flycast32_rumble_libretro.so have been created and have been placed in the rk3326_core_builds/cores$bitness subfolder"
	        gitcommit=$(git log | grep -m 1 commit | cut -c -14 | cut -c 8-)
	        echo $gitcommit > ../../cores$bitness/fly_flycast32_rumble_libretro.so.commit
		  fi
		done
	  fi
      cd $cur_wd/flycast
	  gitcommit=$(git log | grep -m 1 commit | cut -c -14 | cut -c 8-)
	  echo $gitcommit > ../cores$bitness/fly_flycast_libretro.so.commit

	  echo " "
	  echo "fly_flycast_libretro.so has been created and has been placed in the rk3326_core_builds/cores$bitness subfolder"
	fi
