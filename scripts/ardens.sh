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

	# Libretro ardens build
	if [[ "$var" == "ardens" || "$var" == "all" ]] && [[ "$bitness" == "64" ]]; then
	 cd $cur_wd
	  if [ ! -d "Ardens/" ]; then
		git clone --recursive https://github.com/tiberiusbrown/Ardens
		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the libretro git.  Is Internet active or did the git location change?  Stopping here."
		  exit 1
		 fi
		cp patches/ardens-patch* Ardens/.
	  fi

	 cd Ardens/
	 
	 ardens_patches=$(find *.patch)
	 
	 if [[ ! -z "$ardens_patches" ]]; then
	  for patching in ardens-patch*
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
      cmake -DCMAKE_BUILD_TYPE=Release -DARDENS_LLVM=0 -DARDENS_DEBUGGER=0 -DARDENS_PLAYER=0 -DARDENS_LIBRETRO=1 -DCMAKE_POSITION_INDEPENDENT_CODE=TRUE ..
	  make -j$(nproc)

	  if [[ $? != "0" ]]; then
		echo " "
		echo "There was an error while building the newest lr-ardens core.  Stopping here."
		exit 1
	  fi

	  strip ardens_libretro.so

	  if [ ! -d "../../cores64/" ]; then
		mkdir -v ../../cores64
	  fi

	  cp ardens_libretro.so ../../cores64/.

      cd ..
	  gitcommit=$(git log | grep -m 1 commit | cut -c -14 | cut -c 8-)
	  echo $gitcommit > ../cores$(getconf LONG_BIT)/$(basename $PWD)_libretro.so.commit

	  echo " "
	  echo "ardens_libretro.so has been created and has been placed in the rk3326_core_builds/cores64 subfolder"
	fi
