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
	if [[ "$var" == "flycast_xtreme" || "$var" == "all" ]] && [[ "$bitness" == "32" ]]; then
	 flycast_rumblepatch="no"
	 cd $cur_wd
	  if [ ! -d "flycast_xtreme/" ]; then
		git clone https://github.com/libretro/flycast.git flycast_xtreme
		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the flycast libretro git.  Is Internet active or did the git location change?  Stopping here."
		  exit 1
		fi
		cp patches/flycast-kmfd* flycast_xtreme/.
	  fi

	 cd flycast_xtreme/
	 
	 flycast_patches=$(find *.patch)
	 
	 if [[ ! -z "$flycast_patches" ]]; then
	  for patching in flycast-kmfd*
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

	  make platform=classic_armv8_a35 -j$(nproc)

	  if [[ $? != "0" ]]; then
		echo " "
		echo "There was an error while building the newest lr-km_xtreme_flycast core.  Stopping here."
		exit 1
	  fi

	  strip km_flycast_xtreme_libretro.so

	  if [ ! -d "../cores$bitness/" ]; then
		mkdir -v ../cores$bitness
	  fi

          cp km_flycast_xtreme_libretro.so ../cores$bitness/flycast_xtreme_libretro.so

	  gitcommit=$(git log | grep -m 1 commit | cut -c -14 | cut -c 8-)
	  echo $gitcommit > ../cores$bitness/$(basename $PWD)_libretro.so.commit

	  echo " "
	  echo "flycast_xtreme_libretro.so has been created and has been placed in the rk3326_core_builds/cores$bitness subfolder"
	fi
