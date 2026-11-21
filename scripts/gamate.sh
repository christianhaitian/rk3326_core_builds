#!/bin/bash

##################################################################
# Created by Christian Haitian for use to easily update          #
# various standalone emulators, libretro cores, and other        #
# various programs for the RK3566 platform for various Linux     #
# based distributions.                                           #
# See the LICENSE.md file at the top-level directory of this     #
# repository.                                                    #
##################################################################

cur_wd="$PWD"
bitness="$(getconf LONG_BIT)"

	# superwhizkid libretro core build
	if [[ "$var" == "gamate"  || "$var" == "all" ]] && [[ "$bitness" == "64" ]]; then
	 cd $cur_wd

	  # Now we'll start the clone and build of superwhizkid
	  if [ ! -d "superwhizkid/" ]; then
		git clone --recursive https://github.com/ryanmsartor/superwhizkid.git
		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the superwhizkid libretro git.  Is Internet active or did the git location change?  Stopping here."
		  exit 1
		fi
		cp patches/superwhizkid-patch* superwhizkid/.
	  else
		echo " "
		echo "A superwhizkid subfolder already exists.  Stopping here to not impact anything in the folder that may be needed.  If not needed, please remove the superwhizkid folder and rerun this script."
		echo " "
		exit 1
	  fi

	 cd superwhizkid
	 
	 superwhizkid_core_patches=$(find *.patch)
	 
	 if [[ ! -z "$superwhizkid_core_patches" ]]; then
	  for patching in superwhizkid-patch*
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

	 cmake -S . -B build
	 cmake --build build -j$(nproc)

	  if [[ $? != "0" ]]; then
		echo " "
		echo "There was an error while building the newest superwhizkid libretro core.  Stopping here."
		exit 1
	  fi

	  strip build/superwhizkid_libretro.so

	  if [ ! -d "../cores$bitness/" ]; then
		mkdir -v ../cores$bitness
	  fi

	  cp build/superwhizkid_libretro.so ../cores$bitness/.

	  gitcommit=$(git log | grep -m 1 commit | cut -c -14 | cut -c 8-)
	  echo $gitcommit > ../cores$bitness/superwhizkid_libretro.so.commit
	  
	  echo " "
	  echo "superwhizkid_libretro.so executable has been created and has been placed in the rk3566_core_builds/cores$bitness subfolder"

	fi
