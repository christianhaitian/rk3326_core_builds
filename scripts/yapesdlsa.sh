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

	# yapesdl Standalone build
	if [[ "$var" == "yapesdlsa" ]]  && [[ "$bitness" == "64" ]]; then
	 cd $cur_wd

	  # Now we'll start the clone and build of yapesdl
	  if [ ! -d "yapesdlsa/" ]; then
		git clone --recursive https://github.com/calmopyrin/yapesdl.git yapesdlsa

		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the yapesdl standalone git.  Is Internet active or did the git location change?  Stopping here."
		  exit 1
		fi
		cp patches/yapesdlsa-patch* yapesdlsa/.
	  else
		echo " "
		echo "A yapesdlsa subfolder already exists.  Stopping here to not impact anything in the folder that may be needed.  If not needed, please remove the yapesdlsa folder and rerun this script."
		echo " "
		exit 1
	  fi

	 cd yapesdlsa

	 yapesdlsa_patches=$(find *.patch)

	 if [[ ! -z "$yapesdlsa_patches" ]]; then
	  for patching in yapesdlsa-patch*
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
		     echo "There was an error that occured while making the yapesdl standalone.  Stopping here."
             exit 1
           fi
           strip yapesdl

           if [ ! -d "../yapesdlsa-$bitness/" ]; then
	         mkdir -v ../yapesdlsa-$bitness
           fi

	   cp yapesdl ../yapesdlsa-$bitness/.

	   echo " "
	   echo "The yapesdlsa executable has been created and has been placed in the rk3326_core_builds/yapesdlsa-$bitness subfolder"

	fi
