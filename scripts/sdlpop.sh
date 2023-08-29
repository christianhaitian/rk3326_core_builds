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
SDLPoP_git="https://github.com/NagyD/SDLPoP.git"
bitness="$(getconf LONG_BIT)"

	# SDLPoP build
	if [[ "$var" == "sdlpop" ]] && [[ "$bitness" == "64" ]]; then
	 cd $cur_wd
	  if [ ! -d "SDLPoP/" ]; then
		git clone $SDLPoP_git
		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the SDLPoP git.  Is Internet active or did the git location change?  Stopping here."
		  exit 1
		fi
		cp patches/sdlpop-patch* SDLPoP/.
	  fi

	 cd SDLPoP/
	 
	 sdlpop_patches=$(find *.patch)
	 
	  if [[ ! -z "$sdlpop_patches" ]]; then
	  for patching in sdlpop-patch*
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

	  cd src
	  make all -j$(nproc)

	  if [[ $? != "0" ]]; then
		echo " "
		echo "There was an error while building the newest SDLPoP engine.  Stopping here."
		exit 1
	  fi

	  strip ../prince

	  if [ ! -d "../../SDLPoP-$bitness/" ]; then
		mkdir -v ../../SDLPoP-$bitness
	  fi

	  cp ../prince ../../SDLPoP-$bitness/.
	  cp -rf ../mods/ ../../SDLPoP-$bitness/
	  cp -rf ../data/ ../../SDLPoP-$bitness/

	  echo " "
	  echo "SDLPoP has been created and has been placed in the rk3326_core_builds/SDLPoP-$bitness subfolder"
	fi
