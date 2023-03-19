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

	# fake08 Standalone build
	if [[ "$var" == "microvisionsa" ]]  && [[ "$bitness" == "64" ]]; then
	 cd $cur_wd

	  # Now we'll start the clone and build of fake08
	  if [ ! -d "microvisionsa/" ]; then
		git clone --recursive https://github.com/christianhaitian/Paul-Robson-s-Microvision-Emulation.git microvisionsa

		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the fake08 standalone git.  Is Internet active or did the git location change?  Stopping here."
		  exit 1
		fi
		cp patches/microvisionsa-patch* microvisionsa/.
	  else
		echo " "
		echo "A microvisionsa subfolder already exists.  Stopping here to not impact anything in the folder that may be needed.  If not needed, please remove the microvisionsa folder and rerun this script."
		echo " "
		exit 1
	  fi

	 cd microvisionsa

	 microvisionsa_patches=$(find *.patch)

	 if [[ ! -z "$microvisionsa_patches" ]]; then
	  for patching in microvisionsa-patch*
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

           make -j$(nproc)
           if [[ $? != "0" ]]; then
		     echo " "
		     echo "There was an error that occured while making the fake08 standalone.  Stopping here."
             exit 1
           fi
           strip mvem

           if [ ! -d "../microvisionsa-$bitness/" ]; then
	         mkdir -v ../microvisionsa-$bitness
           fi

	   cp mvem ../microvisionsa-$bitness/.
	   cp *.bmp ../microvisionsa-$bitness/.

	   echo " "
	   echo "The microvisionsa executable has been created and has been placed in the rk3326_core_builds/microvisionsa-$bitness subfolder"

	fi
