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
openbor_git="https://github.com/DCurrent/openbor.git"
bitness="$(getconf LONG_BIT)"

	# openbor build
	if [[ "$var" == "openbor" ]] && [[ "$bitness" == "64" ]]; then
	 cd $cur_wd
	  if [ ! -d "openbor/" ]; then
		git clone --recursive $openbor_git
		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the openbor git.  Is Internet active or did the git location change?  Stopping here."
		  exit 1
		fi
		cp patches/openbor-patch* openbor/.
	  fi

	 cd openbor/
	 
	 openbor_patches=$(find *.patch)
	 
	  if [[ ! -z "$openbor_patches" ]]; then
	  for patching in openbor-patch*
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

	  cd engine
	  chmod 777 version.sh
	  ./version.sh
	  make BUILD_LINUX_aarch64=1 -j$(nproc)

	  if [[ $? != "0" ]]; then
		echo " "
		echo "There was an error while building the newest openbor engine.  Stopping here."
		exit 1
	  fi

	  strip OpenBOR.elf

	  if [ ! -d "../../openbor-$bitness/" ]; then
		mkdir -v ../../openbor-$bitness
	  fi

	  cp OpenBOR.elf ../../openbor-$bitness/OpenBOR

	  echo " "
	  echo "openbor has been created and has been placed in the rk3326_core_builds/openbor-$bitness subfolder"
	fi
