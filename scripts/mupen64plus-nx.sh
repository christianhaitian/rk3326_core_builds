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

	# mupen64plus-nx libretro core build
	if [[ "$var" == "mupen64plus-nx" ]]; then
	 cd $cur_wd

	  # Now we'll start the clone and build of mupen64plus-nx
	  if [ ! -d "mupen64plus-nx/" ]; then
		git clone --recursive https://github.com/libretro/mupen64plus-libretro-nx.git mupen64plus-nx
		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the mupen64plus-nx libretro git.  Is Internet active or did the git location change?  Stopping here."
		  exit 1
		fi
		cp patches/mupen64plus-nx-patch* mupen64plus-nx/.
	  else
		echo " "
		echo "A mupen64plus-nx subfolder already exists.  Stopping here to not impact anything in the folder that may be needed.  If not needed, please remove the mupen64plus-nx folder and rerun this script."
		echo " "
		exit 1
	  fi

	 cd mupen64plus-nx
	 
	 mupen64plus_core_patches=$(find *.patch)
	 
	 if [[ ! -z "$mupen64plus_core_patches" ]]; then
	  for patching in mupen64plus-nx-patch*
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
	  sed -i '/rpi3/s//rk3326/' Makefile
	  sed -i '/rpi3_64/s//rk3326_64/' Makefile

	  if [[ "$bitness" == "64" ]]; then
	    make FORCE_GLES3=1 -j$(nproc)
	  else
	    make FORCE_GLES3=1 HAVE_NEON=1 -j$(nproc)
	  fi

	  if [[ $? != "0" ]]; then
		echo " "
		echo "There was an error while building the newest mupen64plus-nx libretro core.  Stopping here."
		exit 1
	  fi

	  strip mupen64plus_next_libretro.so

	  if [ ! -d "../cores$bitness/" ]; then
		mkdir -v ../cores$bitness
	  fi

	  cp mupen64plus_next_libretro.so ../cores$bitness/.

	  gitcommit=$(git log | grep -m 1 commit | cut -c -14 | cut -c 8-)
	  echo $gitcommit > ../cores$bitness/mupen64plus_next_libretro.so.commit
	  
	  echo " "
	  echo "mupen64plus_next_libretro.so executable has been created and has been placed in the rk3326_core_builds/cores$bitness subfolder"

	fi
