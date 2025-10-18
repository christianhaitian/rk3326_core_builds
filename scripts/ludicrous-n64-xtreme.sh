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

	# ludicrous-2k22-xtreme-amped libretro core build
	if [[ "$var" == "ludicrous-n64-xtreme" ]]; then
	 cd $cur_wd

	  # Now we'll start the clone and build of ludicrous-2k22-xtreme-amped
	  if [ ! -d "ludicrous-2k22-xtreme-amped/" ]; then
		git clone --recursive https://github.com/KMFDManic/ludicrous-2k22-xtreme-amped.git
		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the ludicrous-2k22-xtreme-amped libretro git.  Is Internet active or did the git location change?  Stopping here."
		  exit 1
		fi
		cp patches/ludicrous-2k22-xtreme-amped-patch* ludicrous-2k22-xtreme-amped/.
	  else
		echo " "
		echo "A ludicrous-2k22-xtreme-amped subfolder already exists.  Stopping here to not impact anything in the folder that may be needed.  If not needed, please remove the ludicrous-2k22-xtreme-amped folder and rerun this script."
		echo " "
		exit 1
	  fi

	 cd ludicrous-2k22-xtreme-amped
	 
	 ludicrous_core_patches=$(find *.patch)
	 
	 if [[ ! -z "$ludicrous_core_patches" ]]; then
	  for patching in ludicrous-2k22-xtreme-amped-patch*
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

	  sed -i '/a53/s//a35/g' Makefile

	  if [[ "$bitness" == "64" ]]; then
	    make platform=odroid64 -j$(nproc)
	  else
	    make platform=rpi3 -j$(nproc)
	  fi

	  if [[ $? != "0" ]]; then
		echo " "
		echo "There was an error while building the newest ludicrous-2k22-xtreme-amped libretro core.  Stopping here."
		exit 1
	  fi

	  strip km_ludicrousn64_2k22_xtreme_amped_libretro.so

	  if [ ! -d "../cores$bitness/" ]; then
		mkdir -v ../cores$bitness
	  fi

	  cp km_ludicrousn64_2k22_xtreme_amped_libretro.so ../cores$bitness/.

	  gitcommit=$(git log | grep -m 1 commit | cut -c -14 | cut -c 8-)
	  echo $gitcommit > ../cores$bitness/km_ludicrousn64_2k22_xtreme_amped_libretro.so.commit
	  
	  echo " "
	  echo "km_ludicrousn64_2k22_xtreme_amped_libretro.so executable has been created and has been placed in the rk3326_core_builds/cores$bitness subfolder"

	fi
